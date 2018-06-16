unit IntervalArithmetic;
// Delphi XE Pascal unit version 3.6 for 32-bit Windows environment
// (C) Copyright 1998-2013 by Andrzej Marciniak
// Poznan University of Technology, Institute of Computing Science
// Note: Do not use this unit on 64-bit Windows environment!
interface
type interval = record
                  a, b : Extended
                end;
// Basic arithmetic operations for proper intervals
function int_width (const x : interval) : Extended;
function iadd (const x, y : interval) : interval;
function isub (const x, y : interval) : interval;
function imul (const x, y : interval) : interval;
function idiv (const x, y : interval) : interval;
// Basic arithmetic operations for directed (improper) intervals
// For a theory see
// http://www.cs.put.poznan.pl/amarciniak/KONF-referaty/DirectedArithmetic.pdf
function dint_width (const x : interval) : Extended;
function projection (const x : interval) : interval;
function opposite (const x : interval) : interval;
function inverse (const x : interval) : interval;
function diadd (const x, y : interval) : interval;
function disub (const x, y : interval) : interval;
function dimul (const x, y : interval) : interval;
function didiv (const x, y : interval) : interval;
// Data reading functions for proper intervals
function int_read (const sa : string) : interval;
function left_read (const sa : string) : Extended;
function right_read (const sa : string) : Extended;
// Data reading functions for directed (improper) intervals
function dleft_read (const sa : string) : Extended;
function dright_read (const sa : string) : Extended;
// A procedure for transforming ends of proper intervals into strings
procedure iends_to_strings (const x         : interval;
                            out left, right : string);
// Basic functions for proper intervals
function isin (const x : interval;
               out st  : Integer) : interval;
function icos (const x : interval;
               out st  : Integer) : interval;
function iexp (const x : interval;
               out st  : Integer) : interval;
function isqr (const x : interval;
               out st  : Integer) : interval;
// Interval constants (in the form of proper intervals)
function isqrt2 : interval;
function isqrt3 : interval;
function isqrt5 : interval;
function isqrt6 : interval;
function isqrt7 : interval;
function isqrt8 : interval;
function isqrt10 : interval;
function ipi : interval;

implementation
  uses System.SysUtils, System.Math, Vcl.Dialogs;
//  uses SysUtils, Math, Dialogs;  {in older versions of Delphi Pascal }
  type char_tab = array [1..80] of Char;
  const bit : array [0..7] of Byte = ($01, $02, $04, $08, $10, $20, $40, $80);
        ldi : array [0..63] of string =
{2^0}      ('1.000000000000000000000000000000000000000000000000000000000000000',
            '0.500000000000000000000000000000000000000000000000000000000000000',
            '0.250000000000000000000000000000000000000000000000000000000000000',
            '0.125000000000000000000000000000000000000000000000000000000000000',
            '0.062500000000000000000000000000000000000000000000000000000000000',
            '0.031250000000000000000000000000000000000000000000000000000000000',
            '0.015625000000000000000000000000000000000000000000000000000000000',
            '0.007812500000000000000000000000000000000000000000000000000000000',
            '0.003906250000000000000000000000000000000000000000000000000000000',
            '0.001953125000000000000000000000000000000000000000000000000000000',
{2^(-10)}   '0.000976562500000000000000000000000000000000000000000000000000000',
            '0.000488281250000000000000000000000000000000000000000000000000000',
            '0.000244140625000000000000000000000000000000000000000000000000000',
            '0.000122070312500000000000000000000000000000000000000000000000000',
            '0.000061035156250000000000000000000000000000000000000000000000000',
            '0.000030517578125000000000000000000000000000000000000000000000000',
            '0.000015258789062500000000000000000000000000000000000000000000000',
            '0.000007629394531250000000000000000000000000000000000000000000000',
            '0.000003814697265625000000000000000000000000000000000000000000000',
            '0.000001907348632812500000000000000000000000000000000000000000000',
{2^(-20)}   '0.000000953674316406250000000000000000000000000000000000000000000',
            '0.000000476837158203125000000000000000000000000000000000000000000',
            '0.000000238418579101562500000000000000000000000000000000000000000',
            '0.000000119209289550781250000000000000000000000000000000000000000',
            '0.000000059604644775390625000000000000000000000000000000000000000',
            '0.000000029802322387695312500000000000000000000000000000000000000',
            '0.000000014901161193847656250000000000000000000000000000000000000',
            '0.000000007450580596923828125000000000000000000000000000000000000',
            '0.000000003725290298461914062500000000000000000000000000000000000',
            '0.000000001862645149230957031250000000000000000000000000000000000',
{2^(-30)}   '0.000000000931322574615478515625000000000000000000000000000000000',
            '0.000000000465661287307739257812500000000000000000000000000000000',
            '0.000000000232830643653869628906250000000000000000000000000000000',
            '0.000000000116415321826934814453125000000000000000000000000000000',
            '0.000000000058207660913467407226562500000000000000000000000000000',
            '0.000000000029103830456733703613281250000000000000000000000000000',
            '0.000000000014551915228366851806640625000000000000000000000000000',
            '0.000000000007275957614183425903320312500000000000000000000000000',
            '0.000000000003637978807091712951660156250000000000000000000000000',
            '0.000000000001818989403545856475830078125000000000000000000000000',
{2^(-40)}   '0.000000000000909494701772928237915039062500000000000000000000000',
            '0.000000000000454747350886464118957519531250000000000000000000000',
            '0.000000000000227373675443232059478759765625000000000000000000000',
            '0.000000000000113686837721616029739379882812500000000000000000000',
            '0.000000000000056843418860808014869689941406250000000000000000000',
            '0.000000000000028421709430404007434844970703125000000000000000000',
            '0.000000000000014210854715202003717422485351562500000000000000000',
            '0.000000000000007105427357601001858711242675781250000000000000000',
            '0.000000000000003552713678800500929355621337890625000000000000000',
            '0.000000000000001776356839400250464677810668945312500000000000000',
{2^(-50)}   '0.000000000000000888178419700125232338905334472656250000000000000',
            '0.000000000000000444089209850062616169452667236328125000000000000',
            '0.000000000000000222044604925031308084726333618164062500000000000',
            '0.000000000000000111022302462515654042363166809082031250000000000',
            '0.000000000000000055511151231257827021181583404541015625000000000',
            '0.000000000000000027755575615628913510590791702270507812500000000',
            '0.000000000000000013877787807814456755295395851135253906250000000',
            '0.000000000000000006938893903907228377647697925567626953125000000',
            '0.000000000000000003469446951953614188823848962783813476562500000',
            '0.000000000000000001734723475976807094411924481391906738281250000',
{2^(-60)}   '0.000000000000000000867361737988403547205962240695953369140625000',
            '0.000000000000000000433680868994201773602981120347976684570312500',
            '0.000000000000000000216840434497100886801490560173988342285156250',
            '0.000000000000000000108420217248550443400745280086994171142578125');

  function int_width (const x : interval) : Extended;
  begin
    SetRoundMode (rmUp);
    Result:=x.b-x.a;
    SetRoundMode (rmNearest)
  end {int_width};

  function iadd (const x, y : interval) : interval;
  begin
    SetRoundMode (rmDown);
    Result.a:=x.a+y.a;
    SetRoundMode (rmUp);
    Result.b:=x.b+y.b;
    SetRoundMode (rmNearest)
  end {iadd};

  function isub (const x, y : interval) : interval;
  begin
    SetRoundMode (rmDown);
    Result.a:=x.a-y.b;
    SetRoundMode (rmUp);
    Result.b:=x.b-y.a;
    SetRoundMode (rmNearest)
  end {isub};

  function imul (const x, y : interval) : interval;
  var x1y1, x1y2, x2y1 : Extended;
  begin
    SetRoundMode (rmDown);
    x1y1:=x.a*y.a;
    x1y2:=x.a*y.b;
    x2y1:=x.b*y.a;
    with Result do
      begin
        a:=x.b*y.b;
        if x2y1<a
          then a:=x2y1;
        if x1y2<a
          then a:=x1y2;
        if x1y1<a
          then a:=x1y1
      end;
    SetRoundMode (rmUp);
    x1y1:=x.a*y.a;
    x1y2:=x.a*y.b;
    x2y1:=x.b*y.a;
    with Result do
      begin
        b:=x.b*y.b;
        if x2y1>b
          then b:=x2y1;
        if x1y2>b
          then b:=x1y2;
        if x1y1>b
          then b:=x1y1
      end;
    SetRoundMode (rmNearest)
  end {imul};

  function idiv (const x, y : interval) : interval;
  var x1y1, x1y2, x2y1 : Extended;
  begin
    if (y.a<=0) and (y.b>=0)
      then raise EZeroDivide.Create ('Division by an interval containing 0.')
      else begin
             SetRoundMode (rmDown);
             x1y1:=x.a/y.a;
             x1y2:=x.a/y.b;
             x2y1:=x.b/y.a;
             with Result do
               begin
                 a:=x.b/y.b;
                 if x2y1<a
                   then a:=x2y1;
                 if x1y2<a
                   then a:=x1y2;
                 if x1y1<a
                   then a:=x1y1
               end;
             SetRoundMode (rmUp);
             x1y1:=x.a/y.a;
             x1y2:=x.a/y.b;
             x2y1:=x.b/y.a;
             with Result do
               begin
                 b:=x.b/y.b;
                 if x2y1>b
                   then b:=x2y1;
                 if x1y2>b
                   then b:=x1y2;
                 if x1y1>b
                   then b:=x1y1
               end
           end;
    SetRoundMode (rmNearest)
  end {idiv};

  function dint_width (const x : interval) : Extended;
  var w1, w2 : Extended;
  begin
    SetRoundMode (rmUp);
    w1:=x.b-x.a;
    if w1<0
      then w1:=-w1;
    SetRoundMode (rmDown);
    w2:=x.b-x.a;
    if w2<0
      then w2:=-w2;
    if w1>w2
      then Result:=w1
      else Result:=w2;
    SetRoundMode (rmNearest)
  end {dint_width};

  function projection (const x : interval) : interval;
  var z : interval;
  begin
    if x.a>x.b
      then begin
             z:=x;
             Result.a:=z.b;
             Result.b:=z.a
           end
      else Result:=x
  end {projection};

  function opposite (const x : interval) : interval;
  begin
    Result.a:=-x.a;
    Result.b:=-x.b;
  end {opposite};

  function inverse (const x : interval) : interval;
  var z1, z2 : interval;
  begin
    SetRoundMode (rmDown);
    z1.a:=1/x.a;
    z2.b:=1/x.b;
    SetRoundMode (rmUp);
    z1.b:=1/x.b;
    z2.a:=1/x.a;
    if dint_width(z1)>=dint_width(z2)
      then Result:=z1
      else Result:=z2;
    SetRoundMode (rmNearest)
  end {inverse};

  function diadd (const x, y : interval) : interval;
  var z1, z2 : interval;
  begin
    if (x.a<=x.b) and (y.a<=y.b)
      then Result:=iadd(x,y)
      else begin
             SetRoundMode (rmDown);
             z1.a:=x.a+y.a;
             z2.b:=x.b+y.b;
             SetRoundMode (rmUp);
             z1.b:=x.b+y.b;
             z2.a:=x.a+y.a;
             if dint_width(z1)>=dint_width(z2)
               then Result:=z1
               else Result:=z2;
             SetRoundMode (rmNearest)
           end
  end {diadd};

  function disub (const x, y : interval) : interval;
  var z1, z2 : interval;
  begin
    if (x.a<=x.b) and (y.a<=y.b)
      then Result:=isub(x,y)
      else begin
             SetRoundMode (rmDown);
             z1.a:=x.a-y.b;
             z2.b:=x.b-y.a;
             SetRoundMode (rmUp);
             z1.b:=x.b-y.a;
             z2.a:=x.a-y.b;
             if dint_width(z1)>=dint_width(z2)
               then Result:=z1
               else Result:=z2;
             SetRoundMode (rmNearest)
           end
  end {disub};

  function dimul (const x, y : interval) : interval;
  var z1, z2               : interval;
      z                    : Extended;
      xn, xp, yn, yp, zero : Boolean;
  begin
    if (x.a<=x.b) and (y.a<=y.b)
      then Result:=imul(x,y)
      else begin
             xn:=(x.a<0) and (x.b<0);
             xp:=(x.a>0) and (x.b>0);
             yn:=(y.a<0) and (y.b<0);
             yp:=(y.a>0) and (y.b>0);
             zero:=False;
// A, B in H-T
             if (xn or xp) and (yn or yp)
               then if xp and yp
                      then begin
                             SetRoundMode (rmDown);
                             z1.a:=x.a*y.a;
                             z2.b:=x.b*y.b;
                             SetRoundMode (rmUp);
                             z1.b:=x.b*y.b;
                             z2.a:=x.a*y.a
                           end
                      else if xp and yn
                             then begin
                                    SetRoundMode (rmDown);
                                    z1.a:=x.b*y.a;
                                    z2.b:=x.a*y.b;
                                    SetRoundMode (rmUp);
                                    z1.b:=x.a*y.b;
                                    z2.a:=x.b*y.a
                                  end
                             else if xn and yp
                                    then begin
                                           SetRoundMode (rmDown);
                                           z1.a:=x.a*y.b;
                                           z2.b:=x.b*y.a;
                                           SetRoundMode (rmUp);
                                           z1.b:=x.b*y.a;
                                           z2.a:=x.a*y.b
                                         end
                                    else begin
                                           SetRoundMode (rmDown);
                                           z1.a:=x.b*y.b;
                                           z2.b:=x.a*y.a;
                                           SetRoundMode (rmUp);
                                           z1.b:=x.a*y.a;
                                           z2.a:=x.b*y.b
                                         end
// A in H-T, B in T
               else if (xn or xp)
                        and ((y.a<=0) and (y.b>=0) or (y.a>=0) and (y.b<=0))
                      then if xp and (y.a<=y.b)
                             then begin
                                    SetRoundMode (rmDown);
                                    z1.a:=x.b*y.a;
                                    z2.b:=x.b*y.b;
                                    SetRoundMode (rmUp);
                                    z1.b:=x.b*y.b;
                                    z2.a:=x.b*y.a
                                  end
                             else if xp and (y.a>y.b)
                                    then begin
                                           SetRoundMode (rmDown);
                                           z1.a:=x.a*y.a;
                                           z2.b:=x.a*y.b;
                                           SetRoundMode (rmUp);
                                           z1.b:=x.a*y.b;
                                           z2.a:=x.a*y.a
                                         end
                                    else if xn and (y.a<=y.b)
                                           then begin
                                                  SetRoundMode (rmDown);
                                                  z1.a:=x.a*y.b;
                                                  z2.b:=x.a*y.a;
                                                  SetRoundMode (rmUp);
                                                  z1.b:=x.a*y.a;
                                                  z2.a:=x.a*y.b
                                                end
                                           else begin
                                                  SetRoundMode (rmDown);
                                                  z1.a:=x.b*y.b;
                                                  z2.b:=x.b*y.a;
                                                  SetRoundMode (rmUp);
                                                  z1.b:=x.b*y.a;
                                                  z2.a:=x.b*y.b
                                                end
// A in T, B in H-T
                      else if ((x.a<=0) and (x.b>=0) or (x.a>=0) and (x.b<=0))
                               and (yn or yp)
                             then if (x.a<=x.b) and yp
                                    then begin
                                           SetRoundMode (rmDown);
                                           z1.a:=x.a*y.b;
                                           z2.b:=x.b*y.b;
                                           SetRoundMode (rmUp);
                                           z1.b:=x.b*y.b;
                                           z2.a:=x.a*y.b
                                         end
                                    else if (x.a<=0) and yn
                                           then begin
                                                  SetRoundMode (rmDown);
                                                  z1.a:=x.b*y.a;
                                                  z2.b:=x.a*y.a;
                                                  SetRoundMode (rmUp);
                                                  z1.b:=x.a*y.a;
                                                  z2.a:=x.b*y.a
                                                end
                                           else if (x.a>x.b) and yp
                                                  then begin
                                                         SetRoundMode (rmDown);
                                                         z1.a:=x.a*y.a;
                                                         z2.b:=x.b*y.a;
                                                         SetRoundMode (rmUp);
                                                         z1.b:=x.b*y.a;
                                                         z2.a:=x.a*y.a
                                                       end
                                                  else begin
                                                         SetRoundMode (rmDown);
                                                         z1.a:=x.b*y.b;
                                                         z2.b:=x.a*y.b;
                                                         SetRoundMode (rmUp);
                                                         z1.b:=x.a*y.b;
                                                         z2.a:=x.b*y.b
                                                       end
// A, B in Z-
                             else if (x.a>=0) and (x.b<=0) and (y.a>=0)
                                      and (y.b<=0)
                                   then begin
                                          SetRoundMode (rmDown);
                                          z1.a:=x.a*y.a;
                                          z:=x.b*y.b;
                                          if z1.a<z
                                            then z1.a:=z;
                                          z2.b:=x.a*y.b;
                                          z:=x.b*y.a;
                                          if z<z2.b
                                            then z2.b:=z;
                                          SetRoundMode (rmUp);
                                          z1.b:=x.a*y.b;
                                          z:=x.b*y.a;
                                          if z<z1.b
                                            then z1.b:=z;
                                          z2.a:=x.a*y.a;
                                          z:=x.b*y.b;
                                          if z2.a<z
                                            then z2.a:=z
                                        end
// A in Z and B in Z- or A in Z- and B in Z
                                   else zero:=True;
             if zero
               then begin
                      Result.a:=0;
                      Result.b:=0
                    end
               else if dint_width(z1)>=dint_width(z2)
                      then Result:=z1
                      else Result:=z2;
             SetRoundMode (rmNearest)
           end
  end {dimul};

  function didiv (const x, y : interval) : interval;
  var z1, z2               : interval;
      xn, xp, yn, yp, zero : Boolean;
  begin
    if (x.a<=x.b) and (y.a<=y.b)
      then Result:=idiv(x,y)
      else begin
             xn:=(x.a<0) and (x.b<0);
             xp:=(x.a>0) and (x.b>0);
             yn:=(y.a<0) and (y.b<0);
             yp:=(y.a>0) and (y.b>0);
             zero:=False;
// A, B in H-T
             if (xn or xp) and (yn or yp)
               then if xp and yp
                      then begin
                             SetRoundMode (rmDown);
                             z1.a:=x.a/y.b;
                             z2.b:=x.b/y.a;
                             SetRoundMode (rmUp);
                             z1.b:=x.b/y.a;
                             z2.a:=x.a/y.b
                           end
                      else if xp and yn
                             then begin
                                    SetRoundMode (rmDown);
                                    z1.a:=x.b/y.b;
                                    z2.b:=x.a/y.a;
                                    SetRoundMode (rmUp);
                                    z1.b:=x.a/y.a;
                                    z2.a:=x.b/y.b
                                  end
                           else if xn and yp
                                  then begin
                                         SetRoundMode (rmDown);
                                         z1.a:=x.a/y.a;
                                         z2.b:=x.b/y.b;
                                         SetRoundMode (rmUp);
                                         z1.b:=x.b/y.b;
                                         z2.a:=x.a/y.a
                                       end
                                  else begin
                                         SetRoundMode (rmDown);
                                         z1.a:=x.b/y.a;
                                         z2.b:=x.a/y.b;
                                         SetRoundMode (rmUp);
                                         z1.b:=x.a/y.b;
                                         z2.a:=x.b/y.a
                                       end
// A in T, B in H-T
               else if (x.a<=0) and (x.b>=0) or (x.a>=0) and (x.b<=0)
                        and (yn or yp)
                      then if (x.a<=x.b) and yp
                             then begin
                                    SetRoundMode (rmDown);
                                    z1.a:=x.a/y.a;
                                    z2.b:=x.b/y.a;
                                    SetRoundMode (rmUp);
                                    z1.b:=x.b/y.a;
                                    z2.a:=x.a/y.a
                                  end
                             else if (x.a<=x.b) and yn
                                    then begin
                                           SetRoundMode (rmDown);
                                           z1.a:=x.b/y.b;
                                           z2.b:=x.a/y.b;
                                           SetRoundMode (rmUp);
                                           z1.b:=x.a/y.b;
                                           z2.a:=x.b/y.b
                                         end
                                    else if (x.a>x.b) and yp
                                           then begin
                                                  SetRoundMode (rmDown);
                                                  z1.a:=x.a/y.b;
                                                  z2.b:=x.b/y.b;
                                                  SetRoundMode (rmUp);
                                                  z1.b:=x.b/y.b;
                                                  z2.a:=x.a/y.b
                                                end
                                           else begin
                                                  SetRoundMode (rmDown);
                                                  z1.a:=x.b/y.a;
                                                  z2.b:=x.a/y.a;
                                                  SetRoundMode (rmUp);
                                                  z1.b:=x.a/y.a;
                                                  z2.a:=x.b/y.a
                                                end
                      else zero:=True;
             if zero
               then raise EZeroDivide.Create ('Division by an interval '
                                              +'containing 0.')
               else if dint_width(z1)>=dint_width(z2)
                      then Result:=z1
                      else Result:=z2;
             SetRoundMode (rmNearest)
           end
  end {didiv};

  procedure to_fixed_point (const awzi      : char_tab;
                            var significand : string);
  var exponent              : Smallint;
      i, j, k, code         : Integer;
      remember, s1, s2, sum : Byte;
      short_sumz            : ShortString;
      sumz                  : string;
  begin
    exponent:=0;
    j:=1;
    for i:=16 downto 2 do
      begin
        if awzi[i]='1'
          then exponent:=exponent+j;
        j:=2*j
      end;
    exponent:=exponent-16383;
    for i:=80 downto 17 do
      if awzi[i]='1'
        then begin
               remember:=0;
               for j:=65 downto 3 do
                 begin
                   Val (significand[j], s1, code);
                   Val (ldi[i-17,j], s2, code);
                   sum:=s1+s2+remember;
                   Str (sum, short_sumz);
                   sumz:=string(short_sumz);
                   if sum>9
                     then begin
                            significand[j]:=sumz[2];
                            Val (sumz[1], remember, code);
                            if j=3
                              then begin
                                     Val (significand[1], s1, code);
                                     sum:=s1+remember;
                                     Str (sum, short_sumz);
                                     sumz:=string(short_sumz);
                                     significand[1]:=sumz[1]
                                   end
                          end
                     else begin
                            significand[j]:=sumz[1];
                            remember:=0
                          end
                 end;
               Val (significand[1], s1, code);
               Val (ldi[i-17,1], s2, code);
               sum:=s1+s2;
               Str (sum, short_sumz);
               sumz:=string(short_sumz);
               significand[1]:=sumz[1]
             end;
    if exponent>0
      then for i:=1 to exponent do
             begin
               j:=Length(significand);
               remember:=0;
               for k:=j downto j-62 do
                 begin
                   Val (significand[k], s1, code);
                   sum:=2*s1+remember;
                   Str (sum, short_sumz);
                   sumz:=string(short_sumz);
                   if sum>9
                     then begin
                            significand[k]:=sumz[2];
                            Val (sumz[1], remember, code)
                          end
                     else begin
                            significand[k]:=sumz[1];
                            remember:=0
                          end
                 end;
               for k:=j-64 downto 1 do
                 begin
                   Val (significand[k], s1, code);
                   sum:=2*s1+remember;
                   Str (sum, short_sumz);
                   sumz:=string(short_sumz);
                   if sum>9
                     then begin
                            significand[k]:=sumz[2];
                            Val (sumz[1], remember, code);
                            if k=1
                              then significand:=sumz[1]+significand
                          end
                     else begin
                            significand[k]:=sumz[1];
                            remember:=0
                          end
                 end
             end
      else if exponent<0
             then for i:=1 to Abs(exponent) do
                    begin
                      j:=Length(significand);
                      if significand[1]='1'
                        then begin
                               significand[1]:='0';
                               remember:=10
                             end
                        else remember:=0;
                      for k:=3 to j do
                        begin
                          Val (significand[k], s1, code);
                          sum:=remember+s1;
                          s1:=sum div 2;
                          Str (s1, short_sumz);
                          sumz:=string(short_sumz);
                          significand[k]:=sumz[1];
                          remember:=10*(sum mod 2);
                          if (k=j) and (remember<>0)
                            then significand:=significand+'5'
                        end
                    end;
    if awzi[1]='1'
      then significand:='-'+significand
      else significand:='+'+significand;
    if FormatSettings.DecimalSeparator=','
//    if DecimalSeparator=','   {for older versions of Delphi Pascal }
      then while (significand[Length(significand)]='0')
               and (significand[Length(significand)-1]<>',') do
             significand:=Copy(significand, 1, Length(significand)-1)
      else while (significand[Length(significand)]='0')
               and (significand[Length(significand)-1]<>'.') do
             significand:=Copy(significand, 1, Length(significand)-1)
  end {to_fixed_point};

  function int_read (const sa : string) : interval;
  var x, px, nx          : Extended;
      sx, sa1            : string;
      i, j               : Integer;
      tab                : array [1..10] of Byte absolute x;
      eps                : array [1..10] of Byte;
      epsx               : Extended absolute eps;
      epsw               : Word absolute eps;
      digits, rev_digits : char_tab;
      ix                 : interval;
      sep                : Char;
  begin
    sa1:=sa;
    if FormatSettings.DecimalSeparator=','
//    if DecimalSeparator=','   { for older versions of Delphi Pascal }
      then sep:=','
      else sep:='.';
    if (Pos('.', sa1)>0) and (FormatSettings.DecimalSeparator=',')
//    if (Pos('.', sa1)>0) and (DecimalSeparator=',')   { for older versions }
      then sa1[Pos('.', sa1)]:=',';
    x:=StrToFloat(sa1);
    if Pos('e', sa1)>0
      then sa1[Pos('e', sa1)]:='E';
    while sa1[1]=' ' do
      Delete (sa1, 1, 1);
    while sa1[Length(sa1)]=' ' do
      Delete (sa1, Length(sa1), 1);
    if (sa1[1]<>'-') and (sa1[1]<>'+')
      then Insert ('+', sa1, 1);
    while (sa1[2]='0') and (Length(sa1)>2) and (sa1[3]<>'e') and (sa1[3]<>'E')
        and (sa1[3]<>sep) do
      Delete (sa1, 2, 1);
    if (sa1[Length(sa1)]='E') or (sa1[Length(sa1)]='+')
        or (sa1[Length(sa1)]='-')
      then sa1:=sa1+'0'
      else if Pos('E', sa1)=0
             then sa1:=sa1+'E0';
    if Pos(sep, sa1)=0
      then Insert (sep+'0', sa1, Pos('E', sa1));
    sx:=Copy(sa1, Pos('E', sa1)+1, Length(sa1)-Pos('E', sa1));
    sa1:=Copy(sa1, 1, Pos('E', sa1)-1);
    j:=StrToInt(sx);
    if j>0
      then for i:=1 to j do
             begin
               Insert (sep, sa1, Pos(sep, sa1)+2);
               Delete (sa1, Pos(sep, sa1), 1);
               if Pos(sep, sa1)=Length(sa1)
                 then sa1:=sa1+'0'
             end
      else if j<0
             then for i:=j to -1 do
                    begin
                      Insert (sep, sa1, Pos(sep, sa1)-1);
                      Delete (sa1, Pos(sep, sa1)+2, 1);
                      if sa1[2]=sep
                        then Insert ('0', sa1, 2)
                    end;
    while (sa1[Length(sa1)]='0') and (sa1[Length(sa1)-1]<>sep) do
      sa1:=Copy(sa1, 1, Length(sa1)-1);
    for i:=1 to 10 do
      for j:=7 downto 0 do
        if tab[i] and bit[j] = bit[j]
          then digits[8*i-j]:='1'
          else digits[8*i-j]:='0';
    for i:=1 to 10 do
      for j:=1 to 8 do
        rev_digits[8*(i-1)+j]:=digits[80-8*i+j];
    sx:='0'+sep
        +'000000000000000000000000000000000000000000000000000000000000000';
    to_fixed_point (rev_digits, sx);
    if sa1=sx
      then begin
             ix.a:=x;
             ix.b:=x
           end
      else begin
             for i:=18 to 80 do
               rev_digits[i]:='0';
             rev_digits[17]:='1';
             rev_digits[1]:='0';
             for i:=1 to 2 do
               begin
                 eps[i]:=0;
                 for j:=1 to 8 do
                   if rev_digits[8*(i-1)+j]='1'
                     then eps[i]:=eps[i] or bit[8-j]
               end;
             epsw:=Swap(epsw);
             epsw:=epsw-63;
             epsw:=Swap(epsw);
             for i:=1 to 2 do
               for j:=7 downto 0 do
                 if eps[i] and bit[j] = bit[j]
                   then rev_digits[8*i-j]:='1'
                   else rev_digits[8*i-j]:='0';
             for i:=1 to 10 do
               for j:=1 to 8 do
                 digits[8*(i-1)+j]:=rev_digits[80-8*i+j];
             for i:=1 to 10 do
               begin
                 eps[i]:=0;
                 for j:=1 to 8 do
                   if digits[8*(i-1)+j]='1'
                     then eps[i]:=eps[i] or bit[8-j]
               end;
             px:=x-epsx;
             nx:=x+epsx;
             i:=Length(sa1)-Pos(sep, sa1);
             j:=Length(sx)-Pos(sep, sx);
             if j>i
               then i:=j;
             while Length(sa1)-Pos(sep, sa1)<i do
               sa1:=sa1+'0';
             while Length(sx)-Pos(sep, sx)<i do
               sx:=sx+'0';
             i:=Pos(sep, sa1);
             j:=Pos(sep, sx);
             if j>i
               then i:=j;
             while Pos(sep, sa1)<i do
               Insert ('0', sa1, 2);
             while Pos(sep, sx)<i do
               Insert ('0', sx, 2);
             if sx[1]='+'
               then if sa1<sx
                      then begin
                             ix.a:=px;
                             ix.b:=x
                           end
                      else begin
                             ix.a:=x;
                             ix.b:=nx
                           end
               else if sa1<sx
                      then begin
                             ix.a:=x;
                             ix.b:=nx
                           end
                      else begin
                             ix.a:=px;
                             ix.b:=x
                           end
           end;
    Result.a:=ix.a;
    Result.b:=ix.b
  end {int_read};

  function left_read (const sa : string) : Extended;
  var int_number : interval;
  begin
    int_number:=int_read(sa);
    Result:=int_number.a
  end {left_read};

  function right_read (const sa : string) : Extended;
  var int_number : interval;
  begin
    int_number:=int_read(sa);
    Result:=int_number.b
  end {right_read};

  function dleft_read (const sa : string) : Extended;
  var int_number : interval;
  begin
    int_number:=int_read(sa);
    Result:=int_number.b
  end {dleft_read};

  function dright_read (const sa : string) : Extended;
  var int_number : interval;
  begin
    int_number:=int_read(sa);
    Result:=int_number.a
  end {dright_read};

  procedure iends_to_strings (const x         : interval;
                              out left, right : string);
  procedure modify_mantissa (const i      : Integer;
                             var mantissa : string);
  var s, s1    : string;
      short_s1 : ShortString;
  begin
    if i>=0
      then Insert ('+', mantissa, 21)
      else Insert ('-', mantissa, 21);
    Str (Abs(i), short_s1);
    s1:=string(short_s1);
    if i<10
      then s:=string('000')+s1
      else if i<100
             then s:=string('00')+s1
             else if i<1000
                    then s:=string('0')+s1
                    else s:=s1;
    Insert (s, mantissa, 22)
  end;
  function take_up (var fl_str : string) : string;
  var s, s1      : string;
      short_s    : ShortString;
      code, i, k : Integer;
      finished   : Boolean;
  begin
    finished:=False;
    k:=19;
    repeat
      s:=Copy(fl_str, k, 1);
      Delete (fl_str, k, 1);
      Val (s, i, code);
      i:=i+1;
      if i<10
        then begin
               Str (i, short_s);
               s:=string(short_s);
               Insert (s, fl_str, k);
               finished:=True
             end
        else begin
               Insert ('0', fl_str, k);
               k:=k-1
             end
    until finished or (k<4);
    if not finished
      then begin
             s:=Copy(fl_str, 2, 1);
             Delete (fl_str, 2, 1);
             Val (s, i, code);
             i:=i+1;
             if i<10
               then begin
                      Str (i, short_s);
                      s:=string(short_s);
                      Insert (s, fl_str, 2)
                    end
               else begin
                      Insert ('1', fl_str, 2);
                      s:='0';
                      for k:=4 to 19 do
                        begin
                          s1:=Copy(fl_str, k, 1);
                          Delete (fl_str, k, 1);
                          Insert (s, fl_str, k);
                          s:=s1
                        end;
                      s:=Copy(fl_str, 21, 5);
                      Delete (fl_str, 21, 5);
                      Val (s, i, code);
                      i:=i-1;
                      modify_mantissa (i, fl_str)
                    end
           end;
    Result:=fl_str
  end;
  function take_down (var fl_str : string) : string;
  var s          : string;
      short_s    : ShortString;
      code, i, k : Integer;
      finished   : Boolean;
  begin
    finished:=False;
    k:=19;
    repeat
      s:=Copy(fl_str, k, 1);
      Delete (fl_str, k, 1);
      Val (s, i, code);
      i:=i-1;
      if i>-1
        then begin
               Str (i, short_s);
               s:=string(short_s);
               Insert (s, fl_str, k);
               finished:=True
             end
        else begin
               Insert ('9', fl_str, k);
               k:=k-1
             end
    until finished or (k<4);
    if not finished
      then begin
             s:=Copy(fl_str, 2, 1);
             Delete (fl_str, 2, 1);
             Val (s, i, code);
             i:=i-1;
             if i>0
               then begin
                      Str (i, short_s);
                      s:=string(short_s);
                      Insert (s, fl_str, 2)
                    end
               else begin
                      s:=Copy(fl_str, 4, 1);
                      Insert (s, fl_str, 2);
                      for k:=4 to 18 do
                        begin
                          s:=Copy(fl_str, k+1, 1);
                          Delete (fl_str, k+1, 1);
                          Insert (s, fl_str, k)
                        end;
                      Delete (fl_str, 19, 1);
                      Insert ('9', fl_str, 19);
                      s:=Copy(fl_str, 21, 5);
                      Delete (fl_str, 21, 5);
                      Val (s, i, code);
                      i:=i-1;
                      modify_mantissa (i, fl_str)
                    end
           end;
    Result:=fl_str
  end;
  var code                    : Integer;
      y, z                    : Extended;
      short_left, short_right : ShortString;
  begin
    if x.a<=x.b
      then if x.a>=0
             then begin
                    Str (x.a:26, short_left);
                    left:=string(short_left);
                    Delete (left, 20, 1);
                    Val (left, z, code);
                    if x.a<z
                      then left:=take_down(left);
                    Str (x.b:25, short_right);
                    right:=string(short_right);
                    y:=left_read(right);
                    Val (right, z, code);
                    if (x.b>=z) and (x.a<>x.b) and (y<>x.b)
                      then right:=take_up(right)
                  end
             else if x.b<=0
                    then begin
                           Str (x.a:25, short_left);
                           left:=string(short_left);
                           y:=right_read(left);
                           Val (left, z, code);
                           if (x.a<=z) and (x.a<>x.b) and (y<>x.a)
                             then left:=take_up(left);
                           Str (x.b:26, short_right);
                           right:=string(short_right);
                           Delete (right, 20, 1);
                           Val (right, z, code);
                           if x.b>z
                             then right:=take_down(right)
                         end
                    else begin
                           Str (x.a:25, short_left);
                           left:=string(short_left);
                           y:=right_read(left);
                           Val (left, z, code);
                           if (x.a<=z) and (y<>x.a)
                             then left:=take_up(left);
                           Str (x.b:25, short_right);
                           right:=string(short_right);
                           y:=left_read(right);
                           Val (right, z, code);
                           if (x.b>=z) and (y<>x.b)
                             then right:=take_up(right)
                         end
  end {iends_to_strings};

  function isin (const x : interval;
                 out st  : Integer) : interval;
  var is_even, finished : Boolean;
      k                 : Integer;
      d, s, w, w1, x2   : interval;
  begin
    if x.a>x.b
      then st:=1
      else begin
             s:=x;
             w:=x;
             x2:=imul(x,x);
             k:=1;
             is_even:=True;
             finished:=False;
             st:=0;
             repeat
               d.a:=(k+1)*(k+2);
               d.b:=d.a;
               s:=imul(s,idiv(x2,d));
               if is_even
                 then w1:=isub(w,s)
                 else w1:=iadd(w,s);
               if (w.a<>0) and (w.b<>0)
                 then if (Abs(w.a-w1.a)/Abs(w.a)<1e-18)
                          and (Abs(w.b-w1.b)/Abs(w.b)<1e-18)
                        then finished:=True
                        else
                 else if (w.a=0) and (w.b<>0)
                        then if (Abs(w.a-w1.a)<1e-18)
                                 and (Abs(w.b-w1.b)/Abs(w.b)<1e-18)
                               then finished:=True
                               else
                         else if w.a<>0
                                then if (Abs(w.a-w1.a)/Abs(w.a)<1e-18)
                                         and (Abs(w.b-w1.b)<1e-18)
                                       then finished:=True
                                       else
                                else if (Abs(w.a-w1.a)<1e-18)
                                         and (Abs(w.b-w1.b)<1e-18)
                                       then finished:=True;
               if finished
                 then begin
                        if w1.b>1
                          then begin
                                 w1.b:=1;
                                 if w1.a>1
                                   then w1.a:=1
                               end;
                        if w1.a<-1
                          then begin
                                 w1.a:=-1;
                                 if w1.b<-1
                                   then w1.b:=-1
                               end;
                        Result:=w1
                      end
                 else begin
                        w:=w1;
                        k:=k+2;
                        is_even:=not is_even
                      end
             until finished or (k>MaxInt/2);
             if not finished
               then st:=2
           end
  end {isin};

  function icos (const x : interval;
                 out st  : Integer) : interval;
  var is_even, finished : Boolean;
      k                 : Integer;
      d, c, w, w1, x2   : interval;
  begin
    if x.a>x.b
      then st:=1
      else begin
             c.a:=1;
             c.b:=1;
             w:=c;
             x2:=imul(x,x);
             k:=1;
             is_even:=True;
             finished:=False;
             st:=0;
             repeat
               d.a:=k*(k+1);
               d.b:=d.a;
               c:=imul(c,idiv(x2,d));
               if is_even
                 then w1:=isub(w,c)
                 else w1:=iadd(w,c);
               if (w.a<>0) and (w.b<>0)
                 then if (Abs(w.a-w1.a)/Abs(w.a)<1e-18)
                          and (Abs(w.b-w1.b)/Abs(w.b)<1e-18)
                        then finished:=True
                        else
                 else if (w.a=0) and (w.b<>0)
                        then if (Abs(w.a-w1.a)<1e-18)
                                 and (Abs(w.b-w1.b)/Abs(w.b)<1e-18)
                               then finished:=True
                               else
                         else if w.a<>0
                                then if (Abs(w.a-w1.a)/Abs(w.a)<1e-18)
                                         and (Abs(w.b-w1.b)<1e-18)
                                       then finished:=True
                                       else
                                else if (Abs(w.a-w1.a)<1e-18)
                                         and (Abs(w.b-w1.b)<1e-18)
                                       then finished:=True;
               if finished
                 then begin
                        if w1.b>1
                          then begin
                                 w1.b:=1;
                                 if w1.a>1
                                   then w1.a:=1
                               end;
                        if w1.a<-1
                          then begin
                                 w1.a:=-1;
                                 if w1.b<-1
                                   then w1.b:=-1
                               end;
                        Result:=w1
                      end
                 else begin
                        w:=w1;
                        k:=k+2;
                        is_even:=not is_even
                      end
             until finished or (k>MaxInt/2);
             if not finished
               then st:=2
           end
  end {icos};

  function iexp (const x : interval;
                 out st  : Integer) : interval;
  var finished    : Boolean;
      k           : Integer;
      d, e, w, w1 : interval;
  begin
    if x.a>x.b
      then st:=1
      else begin
             e.a:=1;
             e.b:=1;
             w:=e;
             k:=1;
             finished:=False;
             st:=0;
             repeat
               d.a:=k;
               d.b:=k;
               e:=imul(e,idiv(x,d));
               w1:=iadd(w,e);
               if (Abs(w.a-w1.a)/Abs(w.a)<1e-18)
                   and (Abs(w.b-w1.b)/Abs(w.b)<1e-18)
                 then begin
                        finished:=True;
                        Result:=w1
                      end
                 else begin
                        w:=w1;
                        k:=k+1
                      end
             until finished or (k>MaxInt/2);
             if not finished
               then st:=2
           end
  end {iexp};

  function isqr (const x : interval;
                 out st  : Integer) : interval;
  var minx, maxx : Extended;
  begin
    if x.a>x.b
      then st:=1
      else begin
             st:=0;
             if (x.a<=0) and (x.b>=0)
               then minx:=0
               else if x.a>0
                      then minx:=x.a
                      else minx:=x.b;
             if Abs(x.a)>Abs(x.b)
               then maxx:=Abs(x.a)
               else maxx:=Abs(x.b);
             SetRoundMode (rmDown);
             Result.a:=minx*minx;
             SetRoundMode (rmUp);
             Result.b:=maxx*maxx
           end
  end {isqr};

  function isqrt2 : interval;
  var i2 : string;
  begin
    i2:='1.414213562373095048';
    Result.a:=left_read(i2);
    i2:='1.414213562373095049';
    Result.b:=right_read(i2)
  end {isqrt2};

  function isqrt3 : interval;
  var i3 : string;
  begin
    i3:='1.732050807568877293';
    Result.a:=left_read(i3);
    i3:='1.732050807568877294';
    Result.b:=right_read(i3)
  end {isqrt3};

  function isqrt5 : interval;
  var i5 : string;
  begin
    i5:='2.236067977499789696';
    Result.a:=left_read(i5);
    i5:='2.236067977499789697';
    Result.b:=right_read(i5)
  end {isqrt5};

  function isqrt6 : interval;
  var i6 : string;
  begin
    i6:='2.449489742783178098';
    Result.a:=left_read(i6);
    i6:='2.449489742783178099';
    Result.b:=right_read(i6)
  end {isqrt6};

  function isqrt7 : interval;
  var i7 : string;
  begin
    i7:='2.645751311064590590';
    Result.a:=left_read(i7);
    i7:='2.645751311064590591';
    Result.b:=right_read(i7)
  end {isqrt7};

  function isqrt8 : interval;
  var i8 : string;
  begin
    i8:='2.828427124746190097';
    Result.a:=left_read(i8);
    i8:='2.828427124746190098';
    Result.b:=right_read(i8)
  end {isqrt8};

  function isqrt10 : interval;
  var i10 : string;
  begin
    i10:='3.162277660168379331';
    Result.a:=left_read(i10);
    i10:='3.162277660168379332';
    Result.b:=right_read(i10)
  end {isqrt10};

  function ipi : interval;
  var ipistr : string;
  begin
    ipistr:='3.141592653589793238';
    Result.a:=left_read(ipistr);
    ipistr:='3.141592653589793239';
    Result.b:=right_read(ipistr)
  end {ipi};

end.

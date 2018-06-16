unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MyJacobi, IntervalArithmetic32and64;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    Edit5: TEdit;
    Label7: TLabel;
    Edit6: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Label5: TLabel;
    Edit1: TEdit;
    Label8: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure JacobiZmiennopozycyjnie();
    procedure JacobiPrzedzialowo();
  private
    { Private declarations }
    przedzialowa: boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not przedzialowa then
    JacobiZmiennopozycyjnie()
  else
    JacobiPrzedzialowo()
end;

procedure TForm1.JacobiZmiennopozycyjnie();
var
  n: Integer; // liczba rownan oraz niewiadomych
  a: matrix;  // wartosci elementow macierzy
  b: vector;  // wartosci skladowych wektora
  mit: Integer; // maksymalna liczba iteracji
  eps: Extended;  // wzgledna dokladnosc rozwiazania
  x: vector;  // poczatkowe przyblizenia wartosci niewiadomych
  it: Integer;
  st: Integer;

  wspolczynnikiStringList: TStringList;    // wspó³czynniki jako stringi
  i: Integer;
  j: Integer;
begin
  // odczytaj liczbe rownan i inne
  n := Memo1.Lines.Count;
  mit := StrToInt(Edit5.Text);
  eps := StrToFloat(Edit6.Text);
  //it := 0;
  //st := 0;
  // wczytaj wartosci macierzy A
  SetLength(a, n+1);
  for i := 1 to n do
  begin
    SetLength(a[i], n+1);
    wspolczynnikiStringList := TStringList.Create;
    ExtractStrings([';'], [], PChar(Memo1.Lines[i-1]), wspolczynnikiStringList);
    for j := 1 to n do
    begin
      a[i][j] := StrToFloat(wspolczynnikiStringList[j-1]);
    end;
  end;
  // wczytaj wartosci wektora B
  SetLength(b, n+1);
  wspolczynnikiStringList := TStringList.Create;
  ExtractStrings([';'], [], PChar(Edit3.Text), wspolczynnikiStringList);
  for i := 1 to n do
  begin
    b[i] := StrToFloat(wspolczynnikiStringList[i-1]);
  end;
  // wczytaj wartosci wektora X
  SetLength(x, n+1);
  wspolczynnikiStringList := TStringList.Create;
  ExtractStrings([';'], [], PChar(Edit1.Text), wspolczynnikiStringList);
  for i := 1 to n do
  begin
    x[i] := StrToFloat(wspolczynnikiStringList[i-1]);
  end;

  // wykonaj obliczenia
  JacobiNormal(n, a, b, mit, eps, x, it, st);

  // zaprezentuj wynik
  Memo2.Clear;
  for i := 1 to High(x) do
  begin
    Memo2.Lines.Add('x[' + IntToStr(i) + '] = ' + FloatToStrF(x[i], ffExponent, 15, 4));
  end;
  Memo2.Lines.Add('it = ' + IntToStr(it));
  Memo2.Lines.Add('st = ' + IntToStr(st));
end;

procedure TForm1.JacobiPrzedzialowo();
var
  n: Integer; // liczba rownan oraz niewiadomych
  a: matrixInterval;  // wartosci elementow macierzy
  b: vectorInterval;  // wartosci skladowych wektora
  mit: Integer; // maksymalna liczba iteracji
  eps: Extended;  // wzgledna dokladnosc rozwiazania
  x: vectorInterval;  // poczatkowe przyblizenia wartosci niewiadomych
  it: Integer;
  st: Integer;

  wspolczynnikiStringList: TStringList;    // wspó³czynniki jako stringi
  i: Integer;
  j: Integer;
  left, right: String;
  tmp: String;
  tmpInt: Integer;
begin
  // odczytaj liczbe rownan i inne
  n := Memo1.Lines.Count;
  mit := StrToInt(Edit5.Text);
  eps := StrToFloat(Edit6.Text);
  // wczytaj wartosci macierzy A
  SetLength(a, n+1);
  for i := 1 to n do
  begin
    SetLength(a[i], n+1);
    wspolczynnikiStringList := TStringList.Create;
    ExtractStrings([';'], [], PChar(Memo1.Lines[i-1]), wspolczynnikiStringList);
    tmpInt := 1;
    j := 1;
    while tmpInt <= n do
    begin
      tmp := wspolczynnikiStringList[j-1];
      if tmp.StartsWith('[') then
      begin
        a[i][tmpInt].a := StrToFloat(tmp.Substring(1));
        tmp := wspolczynnikiStringList[j];
        a[i][tmpInt].b := StrToFloat(tmp.Substring(0, tmp.Length-1));
        j := j+2;
      end
      else begin
        a[i][tmpInt] := StrToFloat(tmp);
        j := j+1;
      end;
      tmpInt := tmpInt + 1;
    end;
  end;
  // wczytaj wartosci wektora B
  SetLength(b, n+1);
  wspolczynnikiStringList := TStringList.Create;
  ExtractStrings([';'], [], PChar(Edit3.Text), wspolczynnikiStringList);
  tmpInt := 1;
  i := 1;
  while tmpInt <= n do
  begin
    tmp := wspolczynnikiStringList[i-1];
    if tmp.StartsWith('[') then
    begin
      b[tmpInt].a := StrToFloat(tmp.Substring(1));
      tmp := wspolczynnikiStringList[i];
      b[tmpInt].b := StrToFloat(tmp.Substring(0, tmp.Length-1));
      i := i+2;
    end
    else begin
      b[tmpInt] := StrToFloat(tmp);
      i := i+1;
    end;
    tmpInt := tmpInt+1;
  end;
  // wczytaj wartosci wektora X
  SetLength(x, n+1);
  wspolczynnikiStringList := TStringList.Create;
  ExtractStrings([';'], [], PChar(Edit1.Text), wspolczynnikiStringList);
  tmpInt := 1;
  i := 1;
  while tmpInt <= n do
  begin
    tmp := wspolczynnikiStringList[i-1];
    if tmp.StartsWith('[') then
    begin
      x[tmpInt].a := StrToFloat(tmp.Substring(1));
      tmp := wspolczynnikiStringList[i];
      x[tmpInt].b := StrToFloat(tmp.Substring(0, tmp.Length-1));
      i := i+2;
    end
    else begin
      x[tmpInt] := StrToFloat(tmp);
      i := i+1;
    end;
    tmpInt := tmpInt+1;
  end;

  // wykonaj obliczenia
  JacobiInterval(n, a, b, mit, eps, x, it, st);

  // zaprezentuj wynik
  Memo2.Clear;
  for i := 1 to High(x) do
  begin
    iends_to_strings(x[i], left, right);
    Memo2.Lines.Add('x[' + IntToStr(i) + '] = [' + left + '; ' + right + '] szer=' + FloatToStr(int_width(x[i])));
  end;
  Memo2.Lines.Add('it = ' + IntToStr(it));
  Memo2.Lines.Add('st = ' + IntToStr(st));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  przedzialowa := true;
  Label2.Caption := 'przedzia³owa';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  przedzialowa := false;
  Label2.Caption := 'zmiennopozycyjna';
end;

procedure TForm1.FormCreate(Sender: TObject);
//var
  //x:Interval;
  //y:Interval;
begin
  Button3Click(Sender);
end;

end.

program jacobi;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  IntervalArithmetic in 'IntervalArithmetic.pas',
  MyJacobi in 'MyJacobi.pas',
  IntervalArithmetic32and64 in 'IntervalArithmetic32and64.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

program SSA;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  GdiPlusAPI in 'GdiPlusAPI.pas',
  ShadowForm in 'ShadowForm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

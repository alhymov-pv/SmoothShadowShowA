program SSA;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  GdiPlusAPI in 'GdiPlusAPI.pas',
  ShadowForm in 'ShadowForm.pas',
  GdiPlusManager in 'GdiPlusManager.pas',
  FadeThread in 'FadeThread.pas',
  OptionsManager in 'OptionsManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

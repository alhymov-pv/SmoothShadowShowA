unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation
uses
  ShadowForm;

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var
  Shadow: TShadowForm;
  Result: TModalResult;
begin
  Shadow := TShadowForm.Create(nil);
  try
    Result := Shadow.ShowModalShadow(Handle, 50, gsPillow, 2.5);
    if Result = mrOk then
      ShowMessage('Выбрано OK')
    else
      ShowMessage('Выбрано Отмена');
  finally
    Shadow.Free;
  end;
end;

end.

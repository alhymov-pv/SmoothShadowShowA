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
  ShadowForm, OptionsManager;

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var
  Options: TForm;
  Shadow: TShadowForm;
  ModalResult: TModalResult;
begin
  Options := TOptionsManager.CreateOptionsForm(Self);
  try
    Shadow := TShadowForm.Create(nil);
    try
      ModalResult := Shadow.ShowModalShadow(
        Handle,                    // Родительское окно
        Options,                   // Форма опций
        70,                      // Непрозрачность 70%
        gsSphere,                  // Форма градиента
        2.0                      // Время появления (сек)
      );

      case ModalResult of
        mrOk: ShowMessage('OK');
        mrCancel: ShowMessage('Отмена');
        else ShowMessage('Результат: ' + IntToStr(ModalResult));
      end;
    finally
      Shadow.Free;
    end;
  finally
    Options.Free;
  end;
end;


end.

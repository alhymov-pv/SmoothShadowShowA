unit OptionsManager;

interface

uses
  Forms, StdCtrls, Classes, Controls;  // Controls гарантирует доступ к mrOk

type
  TOptionsManager = class
  public
    class function CreateOptionsForm(Owner: TComponent): TForm;
    class procedure CenterFormRelativeTo(Form, ParentForm: TForm);
  end;

implementation

class function TOptionsManager.CreateOptionsForm(Owner: TComponent): TForm;
var
  Form: TForm;
  BtnOK, BtnCancel: TButton;
  Margin: Integer;
begin
  Form := TForm.Create(Owner);
  try
    Form.Caption := 'Опции';
    Form.BorderStyle := bsDialog;
    Form.FormStyle := fsStayOnTop;
    Form.Position := poDesigned;

    Margin := 16;

    // Кнопка OK
    BtnOK := TButton.Create(Form);
    BtnOK.Parent := Form;
    BtnOK.Caption := 'OK';
    BtnOK.ModalResult := mrOk;            // Теперь точно доступно
    BtnOK.Left := Form.ClientWidth - Margin - 80;
    BtnOK.Top := Form.ClientHeight - Margin - 32;
    BtnOK.Width := 80;

    // Кнопка Отмена
    BtnCancel := TButton.Create(Form);
    BtnCancel.Parent := Form;
    BtnCancel.Caption := 'Отмена';
    BtnCancel.ModalResult := mrCancel;    // Теперь точно доступно
    BtnCancel.Left := BtnOK.Left - 90;
    BtnCancel.Top := BtnOK.Top;
    BtnCancel.Width := 80;

    Form.Width := 300;
    Form.Height := 150;
    Form.Constraints.MinWidth := 200;
    Form.Constraints.MinHeight := 120;

  except
    Form.Free;
    raise;
  end;
  Result := Form;
end;

class procedure TOptionsManager.CenterFormRelativeTo(Form, ParentForm: TForm);
begin
  if Assigned(ParentForm) then
  begin
    Form.Left := ParentForm.Left + (ParentForm.Width div 2) - (Form.Width div 2);
    Form.Top := ParentForm.Top + (ParentForm.Height div 2) - (Form.Height div 2);
  end
  else
  begin
    Form.Position := poScreenCenter;
  end;
end;

end.


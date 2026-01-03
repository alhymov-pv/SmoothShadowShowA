unit OptionsManager;

interface

uses
  Forms, StdCtrls, Classes, Controls;

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
    BtnOK.ModalResult := mrOk;
    BtnOK.Left := Form.ClientWidth - Margin - 80;
    BtnOK.Top := Form.ClientHeight - Margin - 32;
    BtnOK.Width := 80;

    // Кнопка Отмена
    BtnCancel := TButton.Create(Form);
    BtnCancel.Parent := Form;
    BtnCancel.Caption := 'Отмена';
    BtnCancel.ModalResult := mrCancel;
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
var
  ParentClientWidth, ParentClientHeight: Integer;
  FormClientWidth, FormClientHeight: Integer;
  TitleBarHeight: Integer;
begin
  if not Assigned(ParentForm) then
  begin
    Form.Position := poScreenCenter;
    Exit;
  end;

  // Размеры клиентской области родителя (без рамки)
  ParentClientWidth := ParentForm.ClientWidth;
  ParentClientHeight := ParentForm.ClientHeight;

  // Размеры клиентской области дочерней формы
  FormClientWidth := Form.ClientWidth;
  FormClientHeight := Form.ClientHeight;

  // Примерная высота заголовка окна (зависит от темы ОС)
  TitleBarHeight := 30;


  // Центрирование по горизонтали
  Form.Left := ParentForm.Left + (ParentClientWidth - FormClientWidth) div 2;

  // Центрирование по вертикали (с поправкой на заголовок)
  Form.Top := ParentForm.Top + TitleBarHeight +
    (ParentClientHeight - FormClientHeight - TitleBarHeight) div 2;
end;

end.


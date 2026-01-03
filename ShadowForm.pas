unit ShadowForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  GdiPlusAPI, Threading;

type
  TGradientShape = (gsPillow, gsSphere, gsCone);

  TShadowForm = class(TForm)
  private
    FToken: Cardinal;
    FGraphics: TGpGraphics;
    FOpacity: Byte;        // 0..255
    FTargetOpacity: Byte;    // целевая непрозрачность (по умолчанию 128 = 50%)
    FGradientShape: TGradientShape;
    FFadeInTime: Double;    // сек
    FFadeOutTime: Double;   // сек
    FIsFading: Boolean;
    FOptionsResult: TModalResult;
    FThread: TThread;

    procedure InitGdiPlus;
    procedure DoneGdiPlus;
    procedure PaintGradient;
    procedure DoFadeIn;
    procedure DoFadeOut;
    procedure ThreadProc;
    procedure ShowOptions;
    procedure OptionsClosed(Sender: TObject; var Action: TCloseAction);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModalShadow(ParentWnd: HWND;
      OpacityPct: Integer = 50;
      Shape: TGradientShape = gsPillow;
      FadeInSec: Double = 2.5): TModalResult;
  end;

implementation

uses Dialogs, StdCtrls;

{ TShadowForm }

constructor TShadowForm.Create(AOwner: TComponent);
begin
  // Не вызываем inherited Create(AOwner) — это вызовет поиск DFM
  CreateNew(AOwner, 0); // Создаём форму без загрузки DFM

  BorderStyle := bsNone;
  Color := clBlack;
  TransparentColor := True;
  TransparentColorValue := clBlack;
  DoubleBuffered := True;
  Enabled := False;  // не ловить ввод
end;


destructor TShadowForm.Destroy;
begin
  DoneGdiPlus;
  inherited;
end;

procedure TShadowForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT or WS_EX_TOOLWINDOW or WS_EX_LAYERED;
  // WS_EX_LAYERED нужен для UpdateLayeredWindow
end;

procedure TShadowForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;  // не стирать
end;

procedure TShadowForm.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTTRANSPARENT;  // пропускать клики сквозь тень
end;

procedure TShadowForm.InitGdiPlus;
var
  Input: TGdiplusStartupInput;
begin
  Input.GdiplusVersion := 1;
  Input.DebugEventCallback := nil;
  Input.SuppressBackgroundThread := False;
  Input.SuppressExternalCodecs := False;
  if GdiplusStartup(FToken, @Input, nil) <> Ok then
    raise Exception.Create('Не удалось инициализировать GDI+');
  if GdipCreateFromHWND(Handle, FGraphics) <> Ok then
    raise Exception.Create('Не удалось создать GpGraphics');
end;

procedure TShadowForm.DoneGdiPlus;
begin
  if FGraphics <> nil then
    GdipDeleteGraphics(FGraphics);
  if FToken <> 0 then
    GdiplusShutdown(FToken);
end;

procedure TShadowForm.PaintGradient;
var
  Brush: TGpPathGradientBrush;
  Points: array[0..3] of TPointF;
  CenterColor, EdgeColor: Cardinal;
  Colors: array[0..0] of Cardinal;
  Count: Integer;
  R: TRect;
begin
  if FGraphics = nil then Exit;

  R := ClientRect;

  // Вершины прямоугольника (для PathGradient)
  Points[0].X := 0;       Points[0].Y := 0;
  Points[1].X := R.Right; Points[1].Y := 0;
  Points[2].X := R.Right; Points[2].Y := R.Bottom;
  Points[3].X := 0;       Points[3].Y := R.Bottom;

  if GdipCreatePathGradient(@Points[0], 4, 0, Brush) <> Ok then Exit;

  // Центр градиента
  CenterColor := $FF000000 or (FOpacity shl 24);  // ARGB: непрозрачность + чёрный
  GdipSetPathGradientCenterColor(Brush, CenterColor);

  // Края — полностью прозрачные
  EdgeColor := $00000000;
  Colors[0] := EdgeColor;
  Count := 1;
  GdipSetPathGradientSurroundColorsWithCount(Brush, @Colors[0], @Count);

  // Залить
  GdipFillRectangleI(FGraphics, Brush, 0, 0, R.Right, R.Bottom);
  GdipDeleteBrush(Brush);
end;

procedure TShadowForm.DoFadeIn;
var
  StartTime: DWORD;
  Elapsed: Double;
  NewOpacity: Byte;
begin
  FIsFading := True;
  StartTime := GetTickCount;  // Начальное время в мс

  try
    while FIsFading do
    begin
      // Вычисляем прошедшее время в секундах
      Elapsed := (GetTickCount - StartTime) / 1000.0;

      // Если время появления истекло — устанавливаем целевую непрозрачность
      if Elapsed >= FFadeInTime then
      begin
        FOpacity := FTargetOpacity;
        FIsFading := False;  // Завершаем цикл
      end
      else
      begin
        // Линейная интерполяция: 0 → FTargetOpacity за FFadeInTime секунд
        NewOpacity := Round(Elapsed / FFadeInTime * FTargetOpacity);
        FOpacity := NewOpacity;
      end;

      // Перерисовываем градиент с текущей непрозрачностью
      PaintGradient;

      // Обновляем окно (важно для WS_EX_TRANSPARENT)
      Update;

      // Даём системе обработать сообщения (чтобы окно реагировало)
      Sleep(10);
      Application.ProcessMessages;

      // Проверяем, не закрыли ли опции раньше времени
      // (если FIsFading был сброшен в OptionsClosed — выходим)
      if not FIsFading then
        Break;
    end;

    // После завершения появления показываем диалог опций
    if Visible then  // Убедимся, что форма ещё открыта
      ShowOptions;

  except
    on E: Exception do
    begin
      FIsFading := False;
      MessageDlg('Ошибка при появлении тени: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TShadowForm.DoFadeOut;
var
  StartTime: DWORD;
  Elapsed: Double;
  NewOpacity: Byte;
begin
  FIsFading := True;
  StartTime := GetTickCount;

  while FIsFading do
  begin
    Elapsed := (GetTickCount - StartTime) / 1000.0;
    if Elapsed >= FFadeOutTime then
    begin
      FOpacity := 0;
      FIsFading := False;
      Close;
    end
    else
    begin
      NewOpacity := Round((1 - Elapsed / FFadeOutTime) * FTargetOpacity);
      FOpacity := NewOpacity;
    end;

    PaintGradient;
    Update;

    // Даём системе обработать сообщения
    Sleep(10);
    Application.ProcessMessages;
  end;
end;

procedure TShadowForm.ThreadProc;
begin
  try
    DoFadeIn;
  except
    on E: Exception do
      MessageDlg('Ошибка в потоке тени: ' + E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TShadowForm.ShowOptions;
var
  OptionsForm: TForm;
  CB: TCheckBox;
  LB: TListBox;
  BtnOK, BtnCancel: TButton;
  Margin: Integer;
  ParentCenterX, ParentCenterY: Integer;
begin
  OptionsForm := TForm.Create(Self);
  try
    OptionsForm.Caption := 'Опции';
    OptionsForm.BorderStyle := bsDialog;
    OptionsForm.Parent := Self;  // Родитель — наша тень
    OptionsForm.FormStyle := fsStayOnTop;

    Margin := 16;

    // Элементы (как раньше)
    CB := TCheckBox.Create(OptionsForm);
    CB.Parent := OptionsForm;
    CB.Caption := 'Включить режим';
    CB.Left := Margin;
    CB.Top := Margin;

    LB := TListBox.Create(OptionsForm);
    LB.Parent := OptionsForm;
    LB.Left := Margin;
    LB.Top := CB.Top + CB.Height + 8;
    LB.Width := 150;
    LB.Height := 80;
    LB.Items.Add('Вариант 1');
    LB.Items.Add('Вариант 2');
    LB.Items.Add('Вариант 3');

    BtnOK := TButton.Create(OptionsForm);
    BtnOK.Parent := OptionsForm;
    BtnOK.Caption := 'OK';
    BtnOK.ModalResult := mrOk;
    BtnOK.Left := OptionsForm.ClientWidth - Margin - 80;
    BtnOK.Top := LB.Top + LB.Height + 16;
    BtnOK.Width := 80;

    BtnCancel := TButton.Create(OptionsForm);
    BtnCancel.Parent := OptionsForm;
    BtnCancel.Caption := 'Отмена';
    BtnCancel.ModalResult := mrCancel;
    BtnCancel.Left := BtnOK.Left - 90;
    BtnCancel.Top := BtnOK.Top;
    BtnCancel.Width := 80;

    // Расчёт размеров формы (как раньше)
    OptionsForm.Width := Margin + 150 + Margin;
    OptionsForm.Height := Margin +
                          CB.Height +
                          8 +
                          LB.Height +
                          16 +
                          BtnOK.Height +
                          Margin;

    OptionsForm.Constraints.MinWidth := 200;
    OptionsForm.Constraints.MinHeight := 180;
    OptionsForm.BorderIcons := [biSystemMenu];

    OptionsForm.OnClose := OptionsClosed;

    // --- Ключевое изменение: центрирование по родительскому окну ---
    ParentCenterX := Self.Left + (Self.Width div 2);
    ParentCenterY := Self.Top + (Self.Height div 2);

    OptionsForm.Left := ParentCenterX - (OptionsForm.Width div 2);
    OptionsForm.Top  := ParentCenterY - (OptionsForm.Height div 2);

    // ------------------------------------------------------------

    FOptionsResult := OptionsForm.ShowModal;

  finally
    OptionsForm.Free;
  end;
end;

procedure TShadowForm.OptionsClosed(Sender: TObject; var Action: TCloseAction);
begin
  // Если опции закрыты до завершения появления — останавливаем анимацию
  FIsFading := False;
  DoFadeOut;
end;

function TShadowForm.ShowModalShadow(ParentWnd: HWND;
  OpacityPct: Integer = 50; Shape: TGradientShape = gsPillow;
  FadeInSec: Double = 2.5): TModalResult;
var
  ParentRect: TRect;
begin
  // Параметры
  FTargetOpacity := Byte(Round(OpacityPct * 2.55)); // 0..255
  FGradientShape := Shape;
  FFadeInTime := FadeInSec;
  FFadeOutTime := 0.5;

  // Позиция и размер — по родительскому окну
  GetWindowRect(ParentWnd, ParentRect);
  SetBounds(ParentRect.Left, ParentRect.Top,
    ParentRect.Right - ParentRect.Left,
    ParentRect.Bottom - ParentRect.Top);

  // Инициализация GDI+
  InitGdiPlus;

  // Показываем форму (прозрачную)
  Show;
  Update;

  // Запускаем поток анимации появления
  FThread := TThread.CreateAnonymousThread(ThreadProc);
  FThread.FreeOnTerminate := False;
  FThread.Start;

  // Ждём закрытия формы (через DoFadeOut -> Close)
  try
    while Visible do
      Application.ProcessMessages;
  except
  end;

  Result := FOptionsResult;
end;

end.


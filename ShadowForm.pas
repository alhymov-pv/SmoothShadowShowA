unit ShadowForm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  OptionsManager, FadeThread;

type
  TGradientShape = (gsPillow, gsSphere, gsLinear);

  TShadowForm = class(TForm)
  private
    FTargetOpacity: Byte;
    FFadeInTime: Double;
    FFadeOutTime: Double;
    FGradientShape: TGradientShape;
    FOpacity: Byte;
    FOptionsForm: TForm;
    FOptionsResult: TModalResult;

    procedure OptionsClosed(Sender: TObject; var Action: TCloseAction);
    procedure StartFade(Direction: Integer);
    procedure PaintShadow; // Убрали override — теперь это просто метод
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModalShadow(ParentWnd: HWND; OptionsForm: TForm;
      OpacityPct: Integer = 50; Shape: TGradientShape = gsPillow;
      FadeInSec: Double = 2.5): TModalResult;
  end;

implementation
uses
  GdiPlusAPI,
  GdiPlusManager,
  SysUtils;

constructor TShadowForm.Create(AOwner: TComponent);
begin
  inherited;
  FOpacity := 0;
  BorderStyle := bsNone;
  TransparentColor := True;
  TransparentColorValue := clFuchsia;
  Color := clFuchsia;
end;

destructor TShadowForm.Destroy;
begin
  inherited;
end;

procedure TShadowForm.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $00020000;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
    WindowClass.Style := WindowClass.Style or CS_DROPSHADOW;
  end;
end;

procedure TShadowForm.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_PAINT, WM_ERASEBKGND:
    begin
      Paint;
      Message.Result := 0;
      Exit;
    end;
  end;
  inherited;
end;


procedure TShadowForm.PaintShadow;
var
  Graphics: TGPGraphics;
  LinearBrush: TGPLinearGradientBrush;
  RadialBrush: TGPRadialGradientBrush;
  Rect: TGPRect;
  RectF: TGPRectF;
  StartColor, EndColor: TGPColor;
  Colors: array[0..0] of Cardinal;  // 1 цвет
begin
  if not GlobalGdiPlus.IsInitialized then
    Exit;
  Graphics := GlobalGdiPlus.Graphics;
  try
    case FGradientShape of
      gsPillow, gsLinear: begin
        // Инициализируем TGPRect
        Rect := MakeRect(0, 0, Width, Height);
        StartColor := MakeARGB(0, 0, 0, 0);
        EndColor := MakeARGB(FOpacity, 0, 0, 0);
        // Создаём линейный градиент через GDI+
        if GdipCreateLineBrush(Rect, StartColor, EndColor, LinearGradientModeVertical, LinearBrush) = Ok
        then begin
          // Заливаем прямоугольник
          GdipFillRectangle(Graphics, LinearBrush, Rect.X, Rect.Y, Rect.Width, Rect.Height);
          GdipDeleteBrush(LinearBrush);  // Освобождаем ресурс
        end;
      end;
      gsSphere: begin
        RectF := MakeRectF(Width / 2, Height / 2, Width, Height);
        if GdipCreateRadialGradientBrush(RectF, RadialBrush) = Ok then begin
          GdipSetRadialGradientCenterColor(RadialBrush, MakeARGB(FOpacity, 0, 0, 0));
          Colors[0] := MakeARGB(0, 0, 0, 0);
          GdipSetRadialGradientSurroundColors(RadialBrush, @Colors[0], 1);
          GdipFillRectangle(Graphics, RadialBrush, RectF.X, RectF.Y, RectF.Width, RectF.Height);
          GdipDeleteBrush(RadialBrush);
        end;
      end;
    end;
  except
    // Обработка ошибок
  end;
end;

procedure TShadowForm.OptionsClosed(Sender: TObject; var Action: TCloseAction);
begin
  FOptionsResult := FOptionsForm.ModalResult;
  Action := caFree;
end;

procedure TShadowForm.StartFade(Direction: Integer);
var
  Thread: TFadeThread;
begin
  Thread := TFadeThread.Create(Self, Direction, FTargetOpacity,
    FFadeInTime, FFadeOutTime, @FOpacity);
  Thread.Start;
end;

function TShadowForm.ShowModalShadow(ParentWnd: HWND; OptionsForm: TForm;
  OpacityPct: Integer = 50; Shape: TGradientShape = gsPillow;
  FadeInSec: Double = 2.5): TModalResult;
var
  ParentRect: TRect;
begin
  if not GlobalGdiPlus.IsInitialized then
    if not GlobalGdiPlus.Initialize then
      raise Exception.Create('Не удалось инициализировать GDI+');

  FTargetOpacity := Byte(Round(OpacityPct * 2.55));
  FGradientShape := Shape;
  FFadeInTime := FadeInSec;
  FFadeOutTime := 0.5;

  GetWindowRect(ParentWnd, ParentRect);
  SetBounds(ParentRect.Left, ParentRect.Top,
    ParentRect.Right - ParentRect.Left,
    ParentRect.Bottom - ParentRect.Top);

  Show;
  Update;

  FOptionsForm := OptionsForm;
  if Assigned(FOptionsForm) then
  begin
    TOptionsManager.CenterFormRelativeTo(FOptionsForm, Self);
    FOptionsForm.OnClose := OptionsClosed;
    FOptionsForm.ShowModal;
  end
  else
    FOptionsResult := mrCancel;

  StartFade(1);

  while Visible do
    Application.ProcessMessages;

  Result := FOptionsResult;
end;

end.


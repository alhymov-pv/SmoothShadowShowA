unit GdiPlusAPI;

interface

uses Windows;

type
  TPointF = record
    X: Single;
    Y: Single;
  end;
  PPointF = ^TPointF;
  TGPStatus = Integer;
  TGpGraphics = Pointer;
  TGpPathGradientBrush = Pointer;
  PGdiplusStartupInput = ^TGdiplusStartupInput;
  TGdiplusStartupInput = record
    GdiplusVersion: Cardinal;
    DebugEventCallback: Pointer;
    SuppressBackgroundThread: Bool;
    SuppressExternalCodecs: Bool;
  end;


type
  TGPColor = Cardinal;
  TGPRect = record
    X, Y, Width, Height: Integer;
  end;
  TGPRectF = record  // если нужен для радиального градиента
    X, Y, Width, Height: Single;
  end;

  // Дескрипторы объектов GDI+
  TGPLinearGradientBrush = Pointer;
  TGPRadialGradientBrush = Pointer;

const
  Ok = 0;
  // Режимы градиента
  LinearGradientModeVertical   = 0;
  LinearGradientModeHorizontal = 1;
  LinearGradientModeForwardDiagonal  = 2;
  LinearGradientModeBackwardDiagonal = 3;

// Альфа‑канал: 0xAARRGGBB
function MakeARGB(A, R, G, B: Byte): TGPColor;
function MakeRect(X, Y, W, H: Integer): TGPRect;
function MakeRectF(X, Y, W, H: Single): TGPRectF;

// Прототипы функций GDI+ (упрощённые)

function GdiplusStartup(out Token: Cardinal; Input: PGdiplusStartupInput; Output: Pointer): TGPStatus; stdcall;
  external 'gdiplus.dll';

procedure GdiplusShutdown(Token: Cardinal); stdcall; external 'gdiplus.dll';

function GdipCreateFromHWND(hwnd: HWND; out Graphics: TGpGraphics): TGPStatus; stdcall; external 'gdiplus.dll';

procedure GdipDeleteGraphics(graphics: TGpGraphics); stdcall; external 'gdiplus.dll';

function GdipCreatePathGradient(Points: PPointF; Count: Integer; WrapMode: Integer; out Brush: TGpPathGradientBrush
  ): TGPStatus; stdcall; external 'gdiplus.dll';

function GdipSetPathGradientCenterColor(Brush: TGpPathGradientBrush; Color: Cardinal): TGPStatus; stdcall;
  external 'gdiplus.dll';

function GdipSetPathGradientSurroundColorsWithCount(Brush: TGpPathGradientBrush; Colors: PCardinal; Count: PInteger
  ): TGPStatus; stdcall; external 'gdiplus.dll';

function GdipFillRectangleI(Graphics: TGpGraphics; Brush: TGpPathGradientBrush; X, Y, Width, Height: Integer
  ): TGPStatus; stdcall; external 'gdiplus.dll';

procedure GdipDeleteBrush(Brush: TGpPathGradientBrush); stdcall; external 'gdiplus.dll';

// Создание линейного градиента
function GdipCreateLineBrush(  const Rect: TGPRect;  StartColor, EndColor: TGPColor;  Mode: Integer;
  var Brush: TGPLinearGradientBrush ): Integer; stdcall; external 'gdiplus.dll';

// Создание радиального градиента
function GdipCreateRadialGradientBrush(
  const FocusRect: TGPRectF;
  var Brush: TGPRadialGradientBrush
): Integer; stdcall; external 'gdiplus.dll';

// Установка центра цвета для радиального градиента
function GdipSetRadialGradientCenterColor(
  Brush: TGPRadialGradientBrush;
  Color: TGPColor
): Integer; stdcall; external 'gdiplus.dll';


// Установка цветов границы для радиального градиента
function GdipSetRadialGradientSurroundColors(
  Brush: TGPRadialGradientBrush;
  Colors: PCardinal;
  Count: Integer
): Integer; stdcall; external 'gdiplus.dll';


// Заливка прямоугольника градиентом
function GdipFillRectangle(
  Graphics: TGPGraphics;
  Brush: Pointer;  // TGPLinearGradientBrush или TGPRadialGradientBrush
  X, Y, Width, Height: Single
): Integer; stdcall; external 'gdiplus.dll';


implementation

function MakeARGB(A, R, G, B: Byte): TGPColor;
begin
  Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

function MakeRect(X, Y, W, H: Integer): TGPRect;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Width := W;
  Result.Height := H;
end;

function MakeRectF(X, Y, W, H: Single): TGPRectF;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Width := W;
  Result.Height := H;
end;


end.


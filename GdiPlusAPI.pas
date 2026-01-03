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

const
  Ok = 0;

function GdiplusStartup(out Token: Cardinal; Input: PGdiplusStartupInput; Output: Pointer): TGPStatus; stdcall; external 'gdiplus.dll';
procedure GdiplusShutdown(Token: Cardinal); stdcall; external 'gdiplus.dll';
function GdipCreateFromHWND(hwnd: HWND; out Graphics: TGpGraphics): TGPStatus; stdcall; external 'gdiplus.dll';
procedure GdipDeleteGraphics(graphics: TGpGraphics); stdcall; external 'gdiplus.dll';
function GdipCreatePathGradient(Points: PPointF; Count: Integer; WrapMode: Integer; out Brush: TGpPathGradientBrush): TGPStatus; stdcall; external 'gdiplus.dll';
function GdipSetPathGradientCenterColor(Brush: TGpPathGradientBrush; Color: Cardinal): TGPStatus; stdcall; external 'gdiplus.dll';
function GdipSetPathGradientSurroundColorsWithCount(Brush: TGpPathGradientBrush; Colors: PCardinal; Count: PInteger): TGPStatus; stdcall; external 'gdiplus.dll';
function GdipFillRectangleI(Graphics: TGpGraphics; Brush: TGpPathGradientBrush; X, Y, Width, Height: Integer): TGPStatus; stdcall; external 'gdiplus.dll';
procedure GdipDeleteBrush(Brush: TGpPathGradientBrush); stdcall; external 'gdiplus.dll';

implementation
end.


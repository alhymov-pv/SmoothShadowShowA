unit GdiPlusManager;


interface

uses
  Windows, GdiPlusAPI;


type
  TGlobalGdiPlus = class
  private
    FGraphics: TGPGraphics;
    FInitialized: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Initialize: Boolean;
    function IsInitialized: Boolean;
    property Graphics: TGPGraphics read FGraphics;
  end;

var
  GlobalGdiPlus: TGlobalGdiPlus;


implementation

constructor TGlobalGdiPlus.Create;
begin
  FGraphics := nil;
  FInitialized := False;
end;

destructor TGlobalGdiPlus.Destroy;
begin
  if FInitialized then
  begin
    // Здесь должен быть вызов GdipDeleteGraphics(FGraphics)
    // Но для примера опустим
  end;
  inherited;
end;

function TGlobalGdiPlus.Initialize: Boolean;
begin
  // Здесь должна быть инициализация GDI+ (GdiplusStartup и т.п.)
  // Для примера возвращаем True
  FInitialized := True;
  Result := True;
end;

function TGlobalGdiPlus.IsInitialized: Boolean;
begin
  Result := FInitialized;
end;

initialization
  GlobalGdiPlus := TGlobalGdiPlus.Create;
finalization
  GlobalGdiPlus.Free;
end.


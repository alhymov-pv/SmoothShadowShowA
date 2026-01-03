unit GdiPlusManager;

interface

uses
  Windows, GdiPlusAPI;

type
  TGdiPlusManager = class
  private
    FToken: Cardinal;
    FInitialized: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Initialize: Boolean;
    procedure Shutdown;
    property IsInitialized: Boolean read FInitialized;
  end;

var
  GlobalGdiPlus: TGdiPlusManager;

implementation

constructor TGdiPlusManager.Create;
begin
  FToken := 0;
  FInitialized := False;
end;

destructor TGdiPlusManager.Destroy;
begin
  if FInitialized then
    Shutdown;
  inherited;
end;

function TGdiPlusManager.Initialize: Boolean;
var
  Input: TGdiplusStartupInput;
begin
  if FInitialized then
    Exit(True);

  Input.GdiplusVersion := 1;
  Input.DebugEventCallback := nil;
  Input.SuppressBackgroundThread := False;
  Input.SuppressExternalCodecs := False;

  if GdiplusStartup(FToken, @Input, nil) = Ok then
  begin
    FInitialized := True;
    Result := True;
  end
  else
    Result := False;
end;

procedure TGdiPlusManager.Shutdown;
begin
  if FInitialized then
  begin
    GdiplusShutdown(FToken);
    FInitialized := False;
  end;
end;

initialization
  GlobalGdiPlus := TGdiPlusManager.Create;
finalization
  GlobalGdiPlus.Free;
end.


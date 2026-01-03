unit FadeThread;

interface

uses
  Classes, Controls, Forms, Types, Math;

type
  TFadeThread = class(TThread)
  private
    FForm: TCustomForm;
    FFadeDirection: Integer;
    FFadeInTime: Double;
    FFadeOutTime: Double;
    FTargetOpacity: Byte;
    FOpacityProp: PByte;

    // Вспомогательный метод для Synchronize
    procedure DoFormClose;
  protected
    procedure Execute; override;
  public
    constructor Create(AForm: TCustomForm; Direction: Integer;
      TargetOpacity: Byte; FadeInSec, FadeOutSec: Double; OpacityPtr: PByte);
  end;

implementation

constructor TFadeThread.Create(AForm: TCustomForm; Direction: Integer;
  TargetOpacity: Byte; FadeInSec, FadeOutSec: Double; OpacityPtr: PByte);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FForm := AForm;
  FFadeDirection := Direction;
  FTargetOpacity := TargetOpacity;
  FFadeInTime := FadeInSec;
  FFadeOutTime := FadeOutSec;
  FOpacityProp := OpacityPtr;
end;

procedure TFadeThread.DoFormClose;
begin
  if FFadeDirection = -1 then
    FForm.Close;
end;

procedure TFadeThread.Execute;
var
  StepTime: DWORD;
  Elapsed: Double;
  NewOpacity: Byte;
  StartTime: DWORD;
begin
  StartTime := GetTickCount;
  StepTime := 20; // 20 мс ≈ 50 FPS

  while not Terminated do
  begin
    Elapsed := (GetTickCount - StartTime) / 1000.0;

    if FFadeDirection = 1 then // Появление
      NewOpacity := Round(Elapsed / FFadeInTime * FTargetOpacity)
    else // Исчезновение
      NewOpacity := Round((1 - Elapsed / FFadeOutTime) * FTargetOpacity);

    // Ограничиваем значения
    NewOpacity := Min(Max(NewOpacity, 0), FTargetOpacity);

    FOpacityProp^ := NewOpacity;

    Synchronize(procedure
    begin
      FForm.Invalidate;
      FForm.Update;
    end);

    // Проверяем завершение (с правильными скобками!)
    if ((FFadeDirection = 1) and (NewOpacity >= FTargetOpacity)) or
       ((FFadeDirection = -1) and (NewOpacity <= 0)) then
    begin
      Synchronize(DoFormClose); // Вызываем метод вместо анонимной процедуры
      Exit;
    end;

    Sleep(StepTime);
    Application.ProcessMessages;
  end;
end;

end.


unit FadeThread;

interface

uses
  Classes, Controls, Forms, Windows, Messages, SysUtils;

type
  TFadeThread = class(TThread)
  private
    FForm: TCustomForm;
    FFadeDirection: Integer;
    FFadeInTime: Double;
    FFadeOutTime: Double;
    FTargetOpacity: Byte;
    FOpacityProp: PByte;  // Было: ^Byte → стало: PByte
  protected
    procedure Execute; override;
  public
    constructor Create(AForm: TCustomForm; Direction: Integer;
      TargetOpacity: Byte; FadeInSec, FadeOutSec: Double; OpacityPtr: PByte);  // PByte
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
  FOpacityProp := OpacityPtr;  // Сохраняем PByte
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
    begin
      NewOpacity := Round(Elapsed / FFadeInTime * FTargetOpacity);
      if NewOpacity >= FTargetOpacity then
        NewOpacity := FTargetOpacity;
    end
    else // Исчезновение
    begin
      NewOpacity := Round((1 - Elapsed / FFadeOutTime) * FTargetOpacity);
      if NewOpacity <= 0 then
        NewOpacity := 0;
    end;

    // Пишем через PByte
    FOpacityProp^ := NewOpacity;  // Разыменование PByte — корректно

    // Перерисовываем и обновляем
    Synchronize(procedure
    begin
      FForm.Invalidate;
      FForm.Update;
    end);

    // Проверяем завершение
    if (FFadeDirection = 1) and (NewOpacity >= FTargetOpacity) or
       (FFadeDirection = -1) and (NewOpacity <= 0) then
    begin
      Synchronize(procedure
      begin
        if FFadeDirection = -1 then
          FForm.Close;
      end);
      Exit;
    end;

    Sleep(StepTime);
    Application.ProcessMessages;
  end;
end;

end.


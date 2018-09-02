program calcdate;

{$APPTYPE CONSOLE}

uses
  SysUtils;
{
function IncMonth(const DateTime: TDateTime; NumberOfMonths: Integer): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  IncAMonth(Year, Month, Day, NumberOfMonths);
  Result := EncodeDate(Year, Month, Day);
  ReplaceTime(Result, DateTime);
end;

procedure IncAMonth(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
var
  DayTable: PDayTable;
  Sign: Integer;
begin
  if NumberOfMonths >= 0 then Sign := 1 else Sign := -1;
  Year := Year + (NumberOfMonths div 12);
  NumberOfMonths := NumberOfMonths mod 12;
  Inc(Month, NumberOfMonths);
  if Word(Month-1) > 11 then    // if Month <= 0, word(Month-1) > 11)
  begin
    Inc(Year, Sign);
    Inc(Month, -12 * Sign);
  end;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if Day > DayTable^[Month] then Day := DayTable^[Month];
end;

procedure ReplaceTime(var DateTime: TDateTime; const NewTime: TDateTime);
begin
  DateTime := Trunc(DateTime);
  if DateTime >= 0 then
    DateTime := DateTime + Abs(Frac(NewTime))
  else
    DateTime := DateTime - Abs(Frac(NewTime));
end;

procedure ReplaceDate(var DateTime: TDateTime; const NewDate: TDateTime);
var
  Temp: TDateTime;
begin
  Temp := NewDate;
  ReplaceTime(Temp, DateTime);
  DateTime := Temp;
end;
}

type
// TYpe de base de calcul
  baseType = (
    btYesterday,
    btToday,
    btTomorow,
    btWeekstart,
    btWeekend,
    btMonthstart,
    btMonthend,
    btYearstart,
    btYearend
  );

  incType = (
    itDay,
    itWeek,
    itMonth,
    itYear
  );

const
  basetypelib : array[basetype] of string =
  (
    'yesterday',
    'today',
    'tomorrow',
    'weekstart',
    'weekend',
    'monthstart',
    'monthend',
    'yearstart',
    'yearend'
  );

  incTypeLib : array[incType] of string =
  (
    'day',
    'week',
    'month',
    'year'
  );

var
  Buffer : string;
  currentDate : tdatetime;
  i : Integer;
  ResultOutput : string;
  myIter : baseType;


function ProcessOneFormula(Buffer : string) : Boolean;
var
  btIter : baseType;
  itIter : incType;
  Year, Month, Day, dow : word;
  DoIt : Boolean;
  Signe : Integer;
  Value : Integer;
  Code : Integer;

begin
  DoIt := False;
  currentDate := Now;
  for btIter := Low(baseType) to High(baseType) do
  begin
    // writeln('Item ' + IntToStr(Ord(btIter)) + ' - ' + baseTypeLib[btIter] + '.');
    if (not DoIt) and
       (copy(lowercase(Buffer),1,length(baseTypeLib[btIter]))=baseTypeLib[btIter]) and
       (
        (length(Buffer) = length(baseTypeLib[btIter])) or
        (Buffer[Succ(length(baseTypeLib[btIter]))] in ['+','-'])
       ) then
    begin
      Delete(Buffer,1,length(baseTypeLib[btIter]));
      // writeln('found: ' + IntToStr(Ord(btIter)) + ' - ' + baseTypeLib[btIter] + '.');
      DoIt := True;
      case btIter of
        btYesterday:
          CurrentDate := Now - 1;
        btToday:
          CurrentDate := Now;
        btTomorow:
          CurrentDate := Now + 1;
        btWeekstart:
        begin
          dow := DayOfWeek(Now)-1;
          if dow=0 then
            dow := 7;
          CurrentDate := Now - dow + 1;
        end;
        btWeekend:
        begin
          dow := DayOfWeek(Now)-1;
          if dow=0 then
            dow := 7;
          CurrentDate := Now + 7- dow;
        end;
        btMonthstart:
        begin
          DecodeDate(Now, Year, Month, Day);
          CurrentDate := EncodeDate(Year, Month, 1);
        end;
        btMonthend:
        begin
          DecodeDate(Now, Year, Month, Day);
          CurrentDate := EncodeDate(Year, Month, 28) + 4;
          DecodeDate(CurrentDate, Year, Month, Day);
          CurrentDate := EncodeDate(Year, Month, 1)-1;
        end;
        btYearstart:
        begin
          DecodeDate(Now, Year, Month, Day);
          CurrentDate := EncodeDate(Year, 01, 01);
        end;
        btYearend:
        begin
          DecodeDate(Now, Year, Month, Day);
          CurrentDate := EncodeDate(Year, 12, 31);
        end;
      end;
    end;
  end;
  if DoIt then
  begin
    // WriteLn('Date en cours : ' + FormatDateTime('dd/mm/yyyy', CurrentDate));
    if Length(Buffer)>0 then
    begin
      Signe := 0;
      case Buffer[1] of
        '-' : Signe := -1;
        '+' : Signe := 1;
        else DoIt := False;
      end;
      if DoIt then
      begin
        Delete(Buffer,1,1);
        Val(Buffer,Value,Code);
        if Code=0 then
        begin
          // writeln('Pas d''erreur et Value=' + IntToStr(Signe*Value));
          Buffer:=incTypeLib[itDay];
        end
        else
        begin
          // writeln('Erreur et Value=' + IntToStr(Signe*Value) + ' et code=' + IntToStr(Code));
          Delete(Buffer,1,Pred(Code));
          // writeln('reste ' + Buffer + ' a interpreter.');
        end;
        DoIt := False;
        for itIter := Low(incType) to High(incType) do
        begin
          if (not DoIt) and
             (
              (copy(lowercase(Buffer),1,length(incTypeLib[itIter]))=incTypeLib[itIter]) or
              (
               (length(Buffer) = 1) and
               (LowerCase(Buffer[1]) = incTypeLib[itIter][1])
              )
             ) then
          begin
            DoIt := True;
            case itIter of
              itDay:
              begin
                CurrentDate := currentDate + (Signe*Value);
              end;
              itMonth :
              begin
                currentDate := IncMonth(currentDate,Signe*Value);
              end;
              itWeek :
              begin
                CurrentDate := currentDate + (Signe*Value*7);;
              end;
              itYear :
              begin
                currentDate := IncMonth(currentDate, (Signe*Value)*12)
              end;
            end;
          end;
        end;
      end
      else
      begin
        writeLn('Operateur non reconnu.');
      end;
    end;
    Result := DoIt;
    if not DoIt then
    begin
      writeLn('Increment non reconnu.');
    end;
  end
  else
  begin
    writeLn('Base date non reconnue.');
    Result := False;
  end;
end;

begin
  WriteLn('[' + ExtractFileName(ParamStr(0)) +'] V1.3 - Marc Chauffour. Aout 2009.');
  if ParamCount=0 then
  begin
    Buffer := '';
    for myIter := Low(baseType) to High(baseType) do
      Buffer := Buffer + '        ' + baseTypeLib[myIter] + ',' + #13#10;
    Buffer[Length(Buffer)-2] := '.';
    WriteLn('Usage : ' + ExtractFileName(ParamStr(0)) + ' Formula Formula Formula');
    Writeln;
    WriteLn('        where formula is any value from ');
    Write(Buffer);
    writeln('        followed optionally by an operator [+|-] and');
    writeln('        a value nnn of [day|week|month|year] or [d|w|m|y]');
    Writeln;
    Writeln('Sample: ' + ExtractFileName(ParamStr(0)) + ' today-2week yesterday-1m weekstart-3week');
    Writeln;
  end
  else
  begin
    ResultOutput := '';
    for i:= 1 to ParamCount() do
    begin
      if ProcessOneFormula(ParamStr(i)) then
        ResultOutput := ResultOutput + FormatDateTime('dd/mm/yyyy', CurrentDate) + ' '
      else
        ResultOutput := ResultOutput + '00/00/0000 '
    end;
    Assign(Output,'');
    Rewrite(Output);
    WriteLn(Trim(ResultOutput));
  end;
end.


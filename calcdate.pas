program calcdate;
uses
 SysUtils;

type
// TYpe de base de calcul
  basetype = (
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

const
  basetypelib : array[basetype] of string =
  (
    'yesterday',
    'today',
    'tomorow',
    'weekstart',
    'weekend',
    'monthstart',
    'monthend',
    'yearstart',
    'yearend'
  );

var
  btIter : baseType;
  Buffer : string;
  currentDate : tdatetime;
  Year, Month, Day, dow : word;
  DoIt : Boolean;

begin
  Assign(Output,'');
  Rewrite(Output);
  if ParamCount<>1 then
  begin
    WriteLn('Usage : calcdate Formula');
    WriteLn('        where formula is [yesterday|today|tomorow|weekstart|weekend|monthstart|monthend|yearstart|yearend]');
    writeln('        optional [+|-]nnn[d|m|y]');
  end
  else
  begin
    DoIt := False;
    for btIter := Low(baseType) to High(baseType) do
    begin
      writeln('Item ' + IntToStr(Ord(btIter)) + ' - ' + baseTypeLib[btIter] + '.');
      if (not DoIt) and
         (copy(lowercase(ParamStr(1)),1,length(baseTypeLib[btIter]))=baseTypeLib[btIter]) and
         (
          (length(ParamStr(1)) = length(baseTypeLib[btIter])) or
          (ParamStr(1)[Succ(length(baseTypeLib[btIter]))] in ['+','-'])
         ) then
      begin
        writeln('found: ' + IntToStr(Ord(btIter)) + ' - ' + baseTypeLib[btIter] + '.');
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
    WriteLn('Date en cours : ' + FormatDateTime('dd/mm/yyyy', CurrentDate));
  end
  else
  begin
    writeLn('Commande non reconnue.');
    Halt(2);
  end;  
    
  end;
end.

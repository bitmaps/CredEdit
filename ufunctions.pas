unit uFunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db;


implementation

{procedure ShowDBTextFields(Sender: TField; var aText: string; DisplayText: Boolean);
var Str : string;
    i : integer;
//    CurrencyFormat : Byte;
begin
//  CurrencyFormat = LOCALE_ICURRENCY;
  str := Copy(Sender.AsString, 1, 50);

  if (Sender.FieldName = 'WITHDRAWAL')
  or (Sender.FieldName = 'TRANSAMOUNT')
  or (Sender.FieldName = 'AMOUNT')
  or (Sender.FieldName = 'VALUE')
  or (Sender.FieldName = 'BALANCE')
  or (Sender.FieldName = 'DEPOSIT') then
  begin
//    Str := FloatToStrF(Sender.AsFloat, ffCurrency, 4, 2);
    CurrencyString := '';
    Str := Format('%m', [Sender.AsFloat]);
    if Str = '0.00' then Str := '';
  end;
  aText := Str;
end;}

end.


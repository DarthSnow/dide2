unit u_ddemangle;

{$I u_defines.inc}

interface

uses
  Classes, SysUtils, process, forms,
  u_dexed_d;

// demangle a D name
function demangle(const value: string): string;
// demangle a list of D names
procedure demangle(values, output: TStrings);

implementation

function demangle(const value: string): string;
var
  s: pchar;
begin
  if (value.Length > 0) and (pos('_D', value) > 0) then
  begin
    s := pchar(value);
    // note, assign to result has for effect to alloc a FPC string
    // (by implicit convertion) so the D memory is not used.
    result := ddemangle(s);
  end
  else
    result := value;
end;

procedure demangle(values, output: TStrings);
var
  i: integer;
  value: string;
begin
  for i := 0 to values.Count-1 do
  begin
    value := values[i];
    if pos('_D', value) > 0 then
    value := demangle(PChar(value));
    output.AddStrings(value);
  end;
end;

end.

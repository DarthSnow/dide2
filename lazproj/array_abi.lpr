{$Mode objfpc}
{$ModeSwitch advancedrecords}
{$ModeSwitch ansistrings}
program array_abi;

type

  generic TFpcArray<T> = record
    type PT = ^T;
  public
    refCount: PtrInt;
    length: PtrInt;
    data: T;
    function getData: PT;
  end;

  TFpcString = specialize TFpcArray<char>;
  PFpcString = ^TFpcString;

  TFpcIntArray = specialize TFpcArray<integer>;
  PFpcIntArray = ^TFpcIntArray;

function TFpcArray.getData: PT;
begin
  result := PT(Pointer(@self) + 16)
end;

var
  s1: string;
  s2: PFpcString;
  i1: array of integer;
  i2: PFpcIntArray;
  i: integer;

begin
  s1 := 'hello world';
  s2 := PFpcString(Pointer(s1) - 16);
  writeln(s2^.getData());

  setLength(i1,4);
  for i := 0 to 4 do
    i1[i] := i;

  i2 := PFpcIntArray(Pointer(i1) - 16);
  for i := 0 to 4 do
    writeln(i2^.getData()[i]);
end.


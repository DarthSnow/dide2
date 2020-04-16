// ObjFPC counterpart for the libdexed-d library.
unit u_dexed_d;

{$I u_defines.inc}

interface

uses
  Classes, SysUtils;

type

  (**
   * Provides a view on D builtin dynamic arrays.
   *
   * Note that it is only partially read-only.
   * The content should never be modified as it's likely to be
   * allocated in D GC memory pool.
   *)
  generic TDArray<T> = record
  type
    PT = ^T;
  strict private
    fLength: PtrUInt;
    fPtr:    PT;
    function getItem(index: PtrUint): T;
  public
    // The count of elements
    property length: PtrUInt read fLength;
    // Pointer to the first element.
    property ptr: PT read fPtr;
    // overload "[]"
    property item[index: PtrUint]: T read getItem; default;
  end;

  // Give a view on D `char[]`
  TDString = specialize TDArray<char> ;

  // Give a view on D `char[][]`
  TDStrings = specialize TDArray<TDString>;

// Necessary to start the GC, run the static constructors, etc
procedure rt_init(); cdecl; external 'libdexed-d';
// Cleanup
procedure rt_term(); cdecl; external 'libdexed-d';
// Demangle a line possibly containing a D mangled name.
function ddemangle(const text: PChar): PChar; cdecl; external 'libdexed-d';
// Detects wether the source code for the module `src` contains the main() function.
function hasMainFun(const src: PChar): Boolean; cdecl; external 'libdexed-d';
// Returns the DDOC template for the declaration location at `caretLine` in the source code `src`.
function ddocTemplate(const src: PChar; caretLine: integer; plusComment: Boolean): PChar; cdecl; external 'libdexed-d';
// List the imports of the module represented by `src`.
function listImports(const src: PChar): TDStrings; cdecl; external 'libdexed-d';
// List the imports of the modules located in `files` (list of files joined with pathseparaotr and null terminated)
function listFilesImports(const files: PChar): TDStrings; cdecl; external 'libdexed-d';
// Get the variables necessary to compute the Halstead metrics of the functions within a module.
function halsteadMetrics(const src: PChar): PChar; cdecl; external 'libdexed-d';
// Get the list of declarations within a module.
function listSymbols(const src: PChar; deep: Boolean): PChar; cdecl; external 'libdexed-d';
// Get the TODO items located in `files` (list of files joined with pathseparaotr and null terminated)
function todoItems(joinedFiles: PChar): PChar; cdecl; external 'libdexed-d';

(**
 * Gets the module name and the imports of the source code located in
 * "source". The first line of "import" contains the module name, double quoted.
 * Each following line contain an import.
 *)
procedure getModuleImports(source, imports: TStrings);

(**
 * Gets the module names and the imports of the sources in "files".
 * source. Each line in "import" that contains double quoted text indicates
 * that a new group of import starts.
 *)
procedure getModulesImports(files: string; results: TStrings);

implementation

function TDArray.getItem(index: PtrUint): T;
begin
  result := (fPtr + index)^;
end;


procedure getModuleImports(source, imports: TStrings);
var
  i: TDStrings;
  e: TDstring;
  j: integer;
  s: string;
begin
  i := listImports(PChar(source.Text));
  for j := 0 to i.length-1 do
  begin
    e := i[j];
    s := e.ptr[0 .. e.length-1];
    imports.Add(s);
  end;
end;

procedure getModulesImports(files: string; results: TStrings);
var
  i: TDStrings;
  e: TDstring;
  j: integer;
  s: string;
begin
  i := listFilesImports(PChar(files));
  for j := 0 to i.length-1 do
  begin
    e := i[j];
    s := e.ptr[0 .. e.length-1];
    results.Add(s);
  end;
end;

initialization
  rt_init();
finalization
  rt_term();
end.

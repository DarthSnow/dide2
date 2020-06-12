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
    fLength: PtrInt;
    fPtr:    PT;
    function getItem(index: Ptrint): T;
  public
    // The count of elements
    property length: PtrInt read fLength;
    // Pointer to the first element.
    property ptr: PT read fPtr;
    // overload "[]"
    property item[index: Ptrint]: T read getItem; default;
  end;

  // Give a view on D `char[]`
  TDString = specialize TDArray<char> ;
  PDString = ^TDString;

  // Give a view on D `char[][]`
  TDStrings = specialize TDArray<TDString>;
  PDStrings = ^TDStrings;

{$IFDEF POSIX}
const
  libdexedd_name = 'libdexed-d';
{$ENDIF}
{$IFDEF WINDOWS}
const
  libdexedd_name = 'dexed-d';
{$ENDIF}

// Necessary to start the GC, run the static constructors, etc
function d_rt_init(): integer; cdecl; external libdexedd_name;
// Cleanup
function d_rt_term(): integer; cdecl; external libdexedd_name;
// Used to release memroy allocated in external D functions that are called in a thread,
// because managing the GC only works from the main thread.
// Memory is released every 32 calls.
// This function must be called from the main thread.
procedure minimizeGcHeap(); cdecl; external libdexedd_name;
// noop
procedure setRtOptions(); cdecl; external libdexedd_name;
// Demangle a line possibly containing a D mangled name.
function ddemangle(const text: PChar): PChar; cdecl; external libdexedd_name;
// Detects wether the source code for the module `src` contains the main() function.
function hasMainFun(const src: PChar): Boolean; cdecl; external libdexedd_name;
// Returns the DDOC template for the declaration location at `caretLine` in the source code `src`.
function ddocTemplate(const src: PChar; caretLine: integer; plusComment: Boolean): PChar; cdecl; external libdexedd_name;
// List the imports of the module represented by `src`.
function listImports(const src: PChar): PDStrings; cdecl; external libdexedd_name;
// List the imports of the modules located in `files` (list of files joined with pathseparaotr and null terminated)
function listFilesImports(const files: PChar): PDStrings; cdecl; external libdexedd_name;
// Get the variables necessary to compute the Halstead metrics of the functions within a module.
function halsteadMetrics(const src: PChar): PChar; cdecl; external libdexedd_name;
// Get the list of declarations within a module.
function listSymbols(const src: PChar; deep: Boolean): pointer; cdecl; external libdexedd_name;
// Get the TODO items located in `files` (list of files joined with pathseparaotr and null terminated)
function todoItems(joinedFiles: PChar): pointer; cdecl; external libdexedd_name;

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

function TDArray.getItem(index: Ptrint): T;
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
  i := listImports(PChar(source.Text))^;
  for j := 0 to i.length-1 do
  begin
    e := i[j];
    s := e.ptr[0 .. e.length-1];
    imports.Add(s);
  end;
  minimizeGcHeap();
end;

procedure getModulesImports(files: string; results: TStrings);
var
  i: TDStrings;
  e: TDstring;
  j: integer;
  s: string;
begin
  i := listFilesImports(PChar(files))^;
	for j := 0 to i.length-1 do
  begin
    e := i[j];
    s := e.ptr[0 .. e.length-1];
    results.Add(s);
  end;
  minimizeGcHeap();
end;

initialization
  setRtOptions();
  d_rt_init();
finalization
  {$IFDEF POSIX}
  d_rt_term();
  {$ENDIF}
end.

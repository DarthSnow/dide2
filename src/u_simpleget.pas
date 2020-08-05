unit u_simpleget;

{$I u_defines.inc}

interface

uses
  classes, fpjson, jsonparser, jsonscanner, fphttpclient,
  openssl, opensslsockets;

type
  PStream = ^TStream;

// Get the content of 'url' in the string 'data'
function simpleGet(url: string; var data: string): boolean; overload;
// Get the content of 'url' in the stream 'data'
function simpleGet(url: string; data: TStream): boolean; overload;
// Get the content of 'url' in the JSON 'data', supposed to be a nil instance.
function simpleGet(url: string; var data: TJSONData): boolean; overload;

const
  simpleGetErrMsg = 'no network or incompatible libssl';

implementation

function simpleGet(url: string; var data: string): boolean; overload;
begin
  result := true;
  with TFPHTTPClient.Create(nil) do
  try
    try
      AddHeader('User-Agent','Mozilla/5.0 (compatible; fpweb)');
      data := get(url);
    except
      result := false;
    end;
  finally
    free;
  end;
end;

function simpleGet(url: string; data: TStream): boolean; overload;
begin
  result := true;
  with TFPHTTPClient.Create(nil) do
  try
    try
      AddHeader('User-Agent','Mozilla/5.0 (compatible; fpweb)');
      get(url, data);
    except
      result := false;
    end;
  finally
    free;
  end;
end;

function simpleGet(url: string; var data: TJSONData): boolean; overload;
var
  s: string = '';
begin
  if not simpleGet(url, s) then
    exit(false);
  result := true;
  with TJSONParser.Create(s, [joUTF8, joIgnoreTrailingComma]) do
  try
    try
      data := Parse();
    except
      result := false;
    end;
  finally
    free;
  end;
end;

initialization
{$IFDEF POSIX}
  // openssl.DLLVersions[2] := '1.1.1';
{$ENDIF}
finalization
end.


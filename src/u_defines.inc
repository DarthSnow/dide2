{$MODE OBJFPC}{$H+}
{$INTERFACES CORBA}
{$MODESWITCH TYPEHELPERS}
{$MODESWITCH ADVANCEDRECORDS}
{$IFDEF UNIX}   {$DEFINE POSIX} {$ENDIF}
{$IFDEF DARWIN} {$DEFINE POSIX} {$ENDIF}

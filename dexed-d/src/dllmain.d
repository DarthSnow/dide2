module dllmain;

version(Windows)
{
    import core.sys.windows.windef;
    import core.sys.windows.dll;
    extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
    {
        return true;
    }
}
module release;

import core.thread.osthread : Thread;

import std.algorithm: each, all, any;
import std.datetime : Clock, DateTime, msecs;
import std.file     : chdir, readText;
import std.process  : pipeProcess, ProcessPipes, wait, Config, Redirect, tryWait, Pid;
import std.range    : iota;
import std.stdio    : File, write, writefln;
import std.string   : stripRight;
import std.traits   : isCallable, ReturnType;
import std.typecons : Flag, No, Yes;

version(unittest)               version = fix_root_dir;
else version(single_module)     version = fix_root_dir;

version(fix_root_dir) static this()
{
    // goto repo root when using dexed runnable
    chdir("..");
}

///
int main()
{
    log("begin building dexed release %s", getVersion(Yes.prefixed));

    // IDE
    {
        log("begin building libdexed-d...");
        ProcessPipes dub_pp = Process.dub(["build", "--root=dexed-d", "--build=release", "--compiler=ldc2"]);
        dub_pp.stdout.logOutput();
        dub_pp.stderr.logOutput();
        if (dub_pp.pid.wait() != 0)
            return 1;
        log("...done building libdexed-d");
    }
    {
        log("begin building dexed additional controls...");
        ProcessPipes laz_pp = Process.lazbuild(["-B", "dexeddesigncontrols.lpk"], "lazproj");
        laz_pp.stdout.logOutput();
        laz_pp.stderr.logOutput();
        if (laz_pp.pid.wait() != 0)
            return 1;
        log("...done building dexed additional controls");
    }
    {
        log("begin building dexed main application...");
        ProcessPipes laz_pp = Process.lazbuild(["-B", "dexed.lpi"], "lazproj");
        laz_pp.stdout.logOutput();
        laz_pp.stderr.logOutput();
        if (laz_pp.pid.wait() != 0)
            return 1;
        log("...done building dexed main application");
    }
    // DCD & D-scanner
    {
        log("begin cloning DCD & D-Scanner...");
        ProcessPipes git1 = Process.git(["clone", "https://github.com/dlang-community/dcd.git"]);
        ProcessPipes git2 = Process.git(["clone", "https://github.com/dlang-community/d-scanner.git"]);
        const success = [git1.pid, git2.pid].waitAll();
        git1.stdout.logOutput();
        git1.stderr.logOutput();
        git2.stdout.logOutput();
        git2.stderr.logOutput();
        if (!success)
            return 1;
    }
    {
        ProcessPipes git1 = Process.git(["submodule", "update", "--init"], "dcd");
        ProcessPipes git2 = Process.git(["submodule", "update", "--init"], "d-scanner");
        const success = [git1.pid, git2.pid].waitAll();
        git1.stdout.logOutput();
        git1.stderr.logOutput();
        git2.stdout.logOutput();
        git2.stderr.logOutput();
        if (!success)
            return 1;
    }
    {
        ProcessPipes git1 = Process.git(["checkout", getDdcCheckoutArg], "dcd");
        ProcessPipes git2 = Process.git(["checkout", getDScanerCheckoutArg], "d-scanner");
        const success = [git1.pid, git2.pid].waitAll();
        git1.stdout.logOutput();
        git1.stderr.logOutput();
        git2.stdout.logOutput();
        git2.stderr.logOutput();
        if (!success)
            return 1;
        log("...done cloning DCD & D-Scanner");
    }
    {
        // note: possible OOM depending on the mem available on the CI service
        log("begin building DCD & D-Scanner...");
        ProcessPipes mak1 = Process.make(["ldc"], "dcd");
        ProcessPipes mak2 = Process.make(["ldc"], "d-scanner");
        const success = [mak1.pid, mak2.pid].waitAll();
        mak1.stdout.logOutput();
        mak1.stderr.logOutput();
        mak2.stdout.logOutput();
        mak2.stderr.logOutput();
        if (!success)
            return 1;
        log("...done building DCD & D-Scanner");
    }

    log("done building dexed release %s", getVersion(Yes.prefixed));
    return 0;
}

/**
 * logs arguments `args` using `specifier` to format them.
 */
void log(A...)(const string specifier, A args)
{
    write    ('[', Clock.currTime.toSimpleString (), "]: ");
    writefln (specifier, args);
}

/**
 * Params : prefixed = indicates if the result contains the "v" prefix.
 * Returns: the string representing dexed version.
 */
string getVersion(Flag!"prefixed" p)
{
    __gshared string result;
    // reminder : stripRight because of those editors adding final LF...
    if (result.length == 0)
        result = readText("setup/version.txt").stripRight();
    const bool offset = p == No.prefixed;
    return result[offset .. $];
}

unittest
{
    assert(getVersion(Yes.prefixed)[0] == 'v');
    assert(getVersion(Yes.prefixed)[1] == '3');
    assert(getVersion(No.prefixed)[0] == '3');
    assert(getVersion(No.prefixed)[1] == '.');
    assert(getVersion(No.prefixed)[3] == '.');
}

/**
 * Writes file content to the standard output.
 */
void logOutput(File f)
{
    write('\n');
    f.byLineCopy.each!((line) => write('\t', line, '\n'));
    //write('\n');
}

/**
 * Utility allowing to start a process using its name as a function call.
 * The call argument are the process parameters as an array followed by the
 * optional working directory.
 */
struct Process
{
    ///
    static ProcessPipes opDispatch(string processName)(string[] parameters, string pwd = null)
    {
        return pipeProcess([processName] ~ parameters, Redirect.all, null, Config.none, pwd);
    }
}

/**
 * Waits until all processes passed as parameter terminate.
 * Params: pids = array of Pid.
 * Returns: true if all the processes terminated with a status of 0
 */
bool waitAll(Pid[] pids)
{
    alias RT = ReturnType!tryWait;
    RT[] results  = new RT[](pids.length);
    while (true)
    {
        if (results.all!(a => a.terminated))
            return results.all!(a => a.status == 0);
        iota(pids.length).each!((index) => results[index] = tryWait(pids[index]));
        Thread.sleep(100.msecs);
    }
}

/**
 * In case of problem with DCD ~master this gives the version to build
 */
string getDdcCheckoutArg() nothrow @nogc
{
    __gshared string result = "master";
    return result;
}

/**
 * In case of problem with D-Scanner ~master this gives the version to build
 */
string getDScanerCheckoutArg() nothrow @nogc
{
    __gshared string result = "master";
    return result;
}

private:

bool onlyFuncs() nothrow @nogc
{
    bool result = true;
    foreach (member; __traits(allMembers, mixin(__MODULE__)))
    {
        static if (is(typeof(mixin(member))))
            static if (__traits(getOverloads, mixin(__MODULE__), member, true).length == 0)
        {
            pragma(msg, "`", member, "` ", "is neither a type nor a function");
            result = false;
            break;
        }
    }
    return result;
}
static assert(onlyFuncs(), "this script must hide globals as local static variable in getters");

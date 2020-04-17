module ddemangle;

import core.demangle    : demangle;
import std.regex        : replaceAll, Captures, regex, Regex;
import core.stdc.string : strlen;
import std.string       : toStringz;

extern(C):

const(char)* ddemangle(const(char)* line)
{
    __gshared Regex!char reDemangle;
    __gshared bool reInit;
    if (!reInit)
    {
        reInit = true;
        reDemangle = regex(r"\b_?_D[0-9a-zA-Z_]+\b");
    }
    return replaceAll!(demangleMatch)(line[0 .. line.strlen], reDemangle).toStringz;
}

extern(D): private:

const(char)[] demangleMatch(Captures!(const(char)[]) m)
{
    // If the second character is an underscore, it may be a D symbol with double leading underscore;
    if (m.hit.length > 0 && m.hit[1] != '_')
    {
        return demangle(m.hit);
    }
    else
    {
        auto result = demangle(m.hit[1..$]);
        return result == m.hit[1..$] ? m.hit : result;
    }
}


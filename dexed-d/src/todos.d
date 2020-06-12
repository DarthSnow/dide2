module todos;

import
    std.stdio, std.string, std.algorithm, std.array, std.conv, std.traits,
    std.ascii, std.range, std.file;
import
    dparse.lexer;
import
    common;

export extern(C) FpcArray!(char)* todoItems(const(char)* joinedFiles)
{
    scope Appender!(char[]) stream;
    scope LexerConfig config = LexerConfig("", StringBehavior.source);
    scope StringCache cache  = StringCache(4096);
    stream.reserve(32);
    stream.put("object TTodoItems\ritems=<");
    foreach (fname; joinedFilesToFiles(joinedFiles))
    {
        stream.reserve(256);
        scope source = cast(ubyte[]) std.file.read(fname);
        DLexer(source, config, &cache)
            .filter!(a => a.type == tok!"comment")
            .each!(t => analyze(t, fname, stream));
    }
    stream.put(">end");
    return (FpcArray!char).fromArray(stream.data);
}

private void analyze(const(Token) token, const(char)[] fname, ref Appender!(char[]) stream)
{
    string text = token.text.strip.patchPascalString;
    string identifier;

    mixin(logCall);

    // always comment
    text.popFrontN(2);
    if (text.empty)
        return;
    // ddoc suffix
    if (text.front.among('/', '*', '+'))
    {
        text.popFront;
        if (text.empty)
            return;
    }
    // leading whites
    while (text.front.isWhite)
    {
        text.popFront;
        if (text.empty)
            return;
    }

    // "TODO|FIXME|NOTE"
    bool isTodoComment;
    while (!text.empty)
    {
        identifier ~= std.ascii.toUpper(text.front);
        text.popFront;
        if (identifier.among("TODO", "FIXME", "NOTE"))
        {
            isTodoComment = true;
            break;
        }
    }
    if (!isTodoComment) return;
    identifier = "";

    // splits "fields" and "description"
    bool isWellFormed;
    string fields;
    while (!text.empty)
    {
        auto front = text.front;
        identifier ~= front;
        text.popFront;
        if (front == ':')
        {
            if (identifier.length) fields = identifier;
            isWellFormed = text.length > 0;
            break;
        }
    }
    if (!isWellFormed) return;
    identifier = "";

    // parses "fields"
    string a, c, p, s;
    while (!fields.empty)
    {
        const dchar front = fields.front;
        fields.popFront;
        if ((front == '-' || fields.empty) && identifier.length > 2)
        {
            const string fieldContent = identifier[2..$].strip;
            switch(identifier[0..2].toUpper)
            {
                default: break;
                case "-A": a = fieldContent; break;
                case "-C": c = fieldContent; break;
                case "-P": p = fieldContent; break;
                case "-S": s = fieldContent; break;
            }
            identifier = "";
        }
        identifier ~= front;
    }

    if (text.length > 1 && text[$-2..$].among("*/", "+/"))
        text.length -=2;

    stream.put("\ritem\r");
    stream.put(format("filename='%s'\r", fname));
    stream.put(format("line='%s'\r", token.line));
    stream.put(format("text='%s'\r", text));
    if (c.length)
        stream.put(format("category='%s'\r", c));
    if (a.length)
        stream.put(format("assignee='%s'\r", a));
    if (p.length)
        stream.put(format("priority='%s'\r", p));
    if (s.length)
        stream.put(format("status='%s'\r", s));
    stream.put("end");
}

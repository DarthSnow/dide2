module symlist;

import
    core.stdc.string;
import
    std.array, std.conv, std.json, std.format,
    std.algorithm, std.string;
import
    iz.memory: construct, destruct, MustAddGcRange, TellRangeAdded, NoGc;
import
    iz.containers : Array;
import
    dparse.lexer, dparse.ast, dparse.parser, dparse.formatter : Formatter;
import
    dparse.rollback_allocator;
import
    common;

/**
 * Visit and enumerate all the declaration of a module.
 *
 * Params:
 *      src     = The module to visit, as source code.
 *      deep    = Defines if the nested declarations are visited.
 * Returns:
 *      The serialized symbols, as a C string.
 */
export extern(C) FpcArray!char* listSymbols(const(char)* src, bool deep)
{
    Appender!(AstErrors) errors;

    void handleErrors(string fname, size_t line, size_t col, string message, bool err)
    {
        errors ~= construct!(AstError)(cast(ErrorType) err, message, line, col);
    }

    LexerConfig config;
    RollbackAllocator rba;
    StringCache sCache = StringCache(StringCache.defaultBucketCount);

    auto mod = src[0 .. src.strlen]
                .getTokensForParser(config, &sCache)
                .parseModule("", &rba, &handleErrors);

    alias SL = SymbolListBuilder!(ListFmt.Pas);
    SL sl = construct!(SL)(errors, deep);
    scope(exit)
    {
        destruct(sl);
        destroy(errors);
        destroy(sCache);
        destroy(rba);
    }

    sl.visit(mod);
    return sl.serialize();
}

private:

enum ListFmt
{
    Pas,
    Json
}

enum SymbolType
{
    _alias,
    _class,
    _enum,
    _error,
    _function,
    _interface,
    _import,
    _mixin, // (template decl)
    _struct,
    _template,
    _union,
    _unittest,
    _variable,
    _warning
}

string makeSymbolTypeArray()
{
    import std.traits : EnumMembers;
    string result = "string[SymbolType.max + 1] symbolTypeStrings = [";
    foreach(st; EnumMembers!SymbolType)
        result ~= `"` ~ to!string(st) ~ `",`;
    result ~= "];";
    return result;
}

mixin(makeSymbolTypeArray);

static assert (!MustAddGcRange!(SymbolListBuilder!(ListFmt.Pas)));

@TellRangeAdded final class SymbolListBuilder(ListFmt Fmt): ASTVisitor
{
    private immutable bool _deep;

    static if (Fmt == ListFmt.Pas)
    {
        Array!char pasStream;
    }
    else
    {
        JSONValue json;
        JSONValue* jarray;
    }

    Array!char funcNameApp;
    Formatter!(Array!char*) fmtVisitor;
    uint utc;

    this(Appender!(AstErrors) errors, bool deep)
    {
        _deep = deep;
        static if (Fmt == ListFmt.Pas)
        {
            pasStream.put("object TSymbolList\rsymbols=<");
        }
        else
        {
            json = parseJSON("[]");
            jarray = &json;
        }
        fmtVisitor = construct!(typeof(fmtVisitor))(&funcNameApp);
        addAstErrors(errors.data);
    }

    ~this()
    {
        destruct(funcNameApp);
        destruct(fmtVisitor);
        static if (Fmt == ListFmt.Pas)
        {
            destruct(pasStream);
        }
    }

    alias visit = ASTVisitor.visit;

    void addAstErrors(AstErrors errors)
    {
        foreach(error; errors)
        {
            string type = (error.type == ErrorType.error) ?
                symbolTypeStrings[SymbolType._error] :
                symbolTypeStrings[SymbolType._warning];
            static if (Fmt == ListFmt.Pas)
            {
                pasStream.put("\ritem\r");
                pasStream.put(format("line=%d\r", error.line));
                pasStream.put(format("col=%d\r", error.column));
                pasStream.put(format("name='%s'\r", patchPascalString!100(error.message)));
                pasStream.put(format("symType=%s\r", type));
                pasStream.put("end");
            }
            else
            {
                JSONValue item = parseJSON("{}");
                item["line"] = JSONValue(error.line);
                item["col"]  = JSONValue(error.column);
                item["name"] = JSONValue(error.message);
                item["type"] = JSONValue(type);
                jarray.array ~= item;
            }
        }
    }

    FpcArray!char* serialize()
    {
        static if (Fmt == ListFmt.Pas)
        {
            pasStream.put(">\rend");
            return (FpcArray!char).fromArray(pasStream);
        }
        else
        {
            JSONValue result = parseJSON("{}");
            result["items"] = json;
            version (assert)
                return result.toPrettyString.toStringz;
            else
                return result.toString.toStringz;
        }
    }

    /// visitor implementation if the declaration has a "name".
    void namedVisitorImpl(DT, SymbolType st, bool dig = true)(const(DT) dt)
    if (__traits(hasMember, DT, "name"))
    {
        static if (Fmt == ListFmt.Pas)
        {
            pasStream.put("\ritem\r");
            pasStream.put(format("line=%d\r", dt.name.line));
            pasStream.put(format("col=%d\r", dt.name.column));
            static if (is(DT == FunctionDeclaration))
            {
                if (dt.parameters && dt.parameters.parameters &&
                    dt.parameters.parameters.length)
                {
                    funcNameApp.length = 0;
                    fmtVisitor.format(dt.parameters);
                    pasStream.put(format("name='%s%s'\r", dt.name.text, patchPascalString(funcNameApp[])));
                }
                else pasStream.put(format("name='%s'\r", dt.name.text));
            }
            else
            {
                pasStream.put(format("name='%s'\r", dt.name.text));
            }
            pasStream.put("symType=" ~ symbolTypeStrings[st] ~ "\r");
            static if (dig) if (_deep)
            {
                pasStream.put("subs = <");
                dt.accept(this);
                pasStream.put(">\r");
            }
            pasStream.put("end");
        }
        else
        {
            JSONValue item = parseJSON("{}");
            item["line"] = JSONValue(dt.name.line);
            item["col"]  = JSONValue(dt.name.column);
            static if (is(DT == FunctionDeclaration))
            {
                if (dt.parameters && dt.parameters.parameters &&
                    dt.parameters.parameters.length)
                {
                    import dparse.formatter : fmtNode = format;
                    funcNameApp.length = 0;
                    fmtVisitor.format(dt.parameters);
                    item["name"] = JSONValue(dt.name.text ~ app.funcNameApp[]);
                }
                else item["name"] = JSONValue(dt.name.text);
            }
            else
            {
                item["name"] = JSONValue(dt.name.text);
            }
            item["type"] = JSONValue(symbolTypeStrings[st]);
            static if (dig) if (_deep)
            {
                JSONValue subs = parseJSON("[]");
                const JSONValue* old = jarray;
                jarray = &subs;
                dt.accept(this);
                item["items"] = subs;
                jarray = old;
            }
            json.array ~= item;
        }
    }

    /// visitor implementation for special cases.
    void otherVisitorImpl(DT, bool dig = true)
        (const(DT) dt, SymbolType st, string name, size_t line, size_t col)
    {
        static if (Fmt == ListFmt.Pas)
        {
            pasStream.put("\ritem\r");
            pasStream.put(format("line=%d\r", line));
            pasStream.put(format("col=%d\r", col));
            pasStream.put(format("name='%s'\r", name));
            pasStream.put("symType=" ~ symbolTypeStrings[st] ~ "\r");
            static if (dig)
            {
                pasStream.put("subs = <");
                dt.accept(this);
                pasStream.put(">\r");
            }
            pasStream.put("end");
        }
        else
        {
            JSONValue item = parseJSON("{}");
            item["line"] = JSONValue(line);
            item["col"]  = JSONValue(col);
            item["name"] = JSONValue(name);
            item["type"] = JSONValue(symbolTypeStrings[st]);
            static if (dig)
            {
                JSONValue subs = parseJSON("[]");
                const JSONValue* old = jarray;
                jarray = &subs;
                dt.accept(this);
                item["items"] = subs;
                jarray = old;
            }
            json.array ~= item;
        }
    }

    override void visit(const AliasDeclaration decl)
    {
        if (decl.initializers.length)
            namedVisitorImpl!(AliasInitializer, SymbolType._alias)(decl.initializers[0]);
    }

    override void visit(const AnonymousEnumMember decl)
    {
        namedVisitorImpl!(AnonymousEnumMember, SymbolType._enum)(decl);
    }

    override void visit(const AutoDeclarationPart decl)
    {
        otherVisitorImpl(decl, SymbolType._variable, decl.identifier.text,
            decl.identifier.line, decl.identifier.column);
    }

    override void visit(const ClassDeclaration decl)
    {
        namedVisitorImpl!(ClassDeclaration, SymbolType._class)(decl);
    }

    override void visit(const Constructor decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "ctor", decl.line, decl.column);
    }

    override void visit(const Destructor decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "dtor", decl.line, decl.column);
    }

    override void visit(const EnumDeclaration decl)
    {
        namedVisitorImpl!(EnumDeclaration, SymbolType._enum)(decl);
    }

    override void visit(const EponymousTemplateDeclaration decl)
    {
        namedVisitorImpl!(EponymousTemplateDeclaration, SymbolType._template)(decl);
    }

    override void visit(const FunctionDeclaration decl)
    {
        namedVisitorImpl!(FunctionDeclaration, SymbolType._function)(decl);
    }

    override void visit(const InterfaceDeclaration decl)
    {
        namedVisitorImpl!(InterfaceDeclaration, SymbolType._interface)(decl);
    }

    override void visit(const ImportDeclaration decl)
    {
        foreach (const(SingleImport) si; decl.singleImports)
        {
            if (!si.identifierChain.identifiers.length)
                continue;

            otherVisitorImpl(decl, SymbolType._import,
                si.identifierChain.identifiers.map!(a => a.text).join("."),
                si.identifierChain.identifiers[0].line,
                si.identifierChain.identifiers[0].column);
        }
        if (decl.importBindings) with (decl.importBindings.singleImport)
            otherVisitorImpl(decl, SymbolType._import,
                identifierChain.identifiers.map!(a => a.text).join("."),
                identifierChain.identifiers[0].line,
                identifierChain.identifiers[0].column);
    }

    override void visit(const Invariant decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "invariant", decl.line, 0);
    }

    override void visit(const MixinTemplateDeclaration decl)
    {
        namedVisitorImpl!(TemplateDeclaration, SymbolType._mixin)(decl.templateDeclaration);
    }

    override void visit(const Postblit pb)
    {
        otherVisitorImpl(pb, SymbolType._function, "postblit", pb.line, pb.column);
        pb.accept(this);
    }

    override void visit(const StructDeclaration decl)
    {
        namedVisitorImpl!(StructDeclaration, SymbolType._struct)(decl);
    }

    override void visit(const TemplateDeclaration decl)
    {
        namedVisitorImpl!(TemplateDeclaration, SymbolType._template)(decl);
    }

    override void visit(const UnionDeclaration decl)
    {
        namedVisitorImpl!(UnionDeclaration, SymbolType._union)(decl);
    }

    override void visit(const Unittest decl)
    {
        otherVisitorImpl(decl, SymbolType._unittest, format("test%.4d",utc++),
            decl.line, decl.column);
    }

    override void visit(const VariableDeclaration decl)
    {
        if (decl.declarators)
            foreach (elem; decl.declarators)
                namedVisitorImpl!(Declarator, SymbolType._variable, false)(elem);
        else if (decl.autoDeclaration)
            visit(decl.autoDeclaration);
    }

    override void visit(const StaticConstructor decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "static ctor", decl.line, decl.column);
    }

    override void visit(const StaticDestructor decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "static dtor", decl.line, decl.column);
    }

    override void visit(const SharedStaticConstructor decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "shared static ctor", decl.line, decl.column);
    }

    override void visit(const SharedStaticDestructor decl)
    {
        otherVisitorImpl(decl, SymbolType._function, "shared static dtor", decl.line, decl.column);
    }

    override void visit(const AliasInitializer)     {}
    override void visit(const AlignAttribute)       {}
    override void visit(const ArrayInitializer)     {}
    override void visit(const AsmStatement)         {}
    override void visit(const AtAttribute)          {}
    override void visit(const Attribute)            {}
    override void visit(const AttributeDeclaration) {}
    override void visit(const BaseClassList)        {}
    override void visit(const BreakStatement)       {}
    override void visit(const Catches)              {}
    override void visit(const Constraint)           {}
    override void visit(const ContinueStatement)    {}
    override void visit(const Deprecated)           {}
    override void visit(const Expression)           {}
    override void visit(const ExpressionNode)       {}
    override void visit(const ExpressionStatement)  {}
    override void visit(const FunctionAttribute)    {}
    override void visit(const FunctionContract)     {}
    override void visit(const GotoStatement)        {}
    override void visit(const Initializer)          {}
    override void visit(const LabeledStatement)     {}
    override void visit(const MemberFunctionAttribute){}
    override void visit(const MixinDeclaration)     {}
    override void visit(const NamespaceList)        {}
    override void visit(const PragmaStatement)      {}
    override void visit(const ReturnStatement)      {}
    override void visit(const StaticAssertDeclaration){}
    override void visit(const StaticAssertStatement){}
    override void visit(const StructInitializer)    {}
    override void visit(const SynchronizedStatement){}
    override void visit(const ThrowStatement)       {}
    override void visit(const Type)                 {}
    override void visit(const Type2)                {}
}


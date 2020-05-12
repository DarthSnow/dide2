module imports;

import
    core.stdc.string;
import
    std.algorithm, std.array, std.file, std.functional;
import
    iz.memory;
import
    dparse.lexer, dparse.ast, dparse.parser, dparse.rollback_allocator;
import
    common;

private alias moduleDeclarationToText = (ModuleDeclaration md) => md.moduleName
    .identifiers
    .map!(a => a.text)
    .join(".");

/**
 * Lists the modules imported by a module
 *
 * On the first line writes the module name or # between double quotes then
 * each import is written on a new line. Import detection is not accurate,
 * the imports injected by a mixin template or by a string variable are not detected,
 * the imports deactivated by a static condition neither.
 *
 * The results are used by to automatically detect the static libraries used by a
 * dexed runnable module.
 */
extern(C) string[] listImports(const(char)* src)
{
    string[] result;
    LexerConfig config;
    RollbackAllocator rba;
    StringCache sCache = StringCache(StringCache.defaultBucketCount);

    scope mod = src[0 .. src.strlen]
                .getTokensForParser(config, &sCache)
                .parseModule("", &rba, &ignoreErrors);
    if (auto md = mod.moduleDeclaration)
        result ~= '"' ~ moduleDeclarationToText(md) ~ '"';
    else
        result ~= "\"#\"";

    ImportLister il = construct!(ImportLister)(&result);
    scope (exit) destruct(il);

    il.visit(mod);
    return result;
}

/**
 * Lists the modules imported by several modules
 *
 * The output consists of several consecutive lists, as formated for
 * listImports. When no moduleDeclaration is available, the first line of
 * a list matches the filename.
 *
 * The results are used by to build a key value store linking libraries to other
 * libraries, which is part of dexed "libman".
 */
extern(C) string[] listFilesImports(const(char)* joinedFiles)
{
    string[] result;
    RollbackAllocator rba;
    StringCache sCache  = StringCache(StringCache.defaultBucketCount);
    LexerConfig config  = LexerConfig("", StringBehavior.source);
    ImportLister il     = construct!(ImportLister)(&result);

    scope(exit)
    {
        destruct(il);
        destroy(sCache);
        destroy(rba);
    }

    foreach(fname; joinedFilesToFiles(joinedFiles))
    {
        scope mod = readText(fname)
                    .getTokensForParser(config, &sCache)
                    .parseModule("", &rba, &ignoreErrors);
        if (auto md = mod.moduleDeclaration)
            result ~= '"' ~ moduleDeclarationToText(md) ~ '"';
        else
            result ~= '"' ~ cast(string)fname ~ '"';

        il.visit(mod);
    }

    return result;
}

static assert(!MustAddGcRange!ImportLister);

@TellRangeAdded
private final class ImportLister: ASTVisitor
{
    alias visit = ASTVisitor.visit;
    size_t mixinDepth;
    @NoGc string[]* results;

    this(string[]* results)
    {
        assert(results);
        this.results = results;
    }

    override void visit(const(Module) mod)
    {
        mixinDepth = 0;
        mod.accept(this);
    }

    override void visit(const ConditionalDeclaration decl)
    {
        bool acc = true;
        if (decl.compileCondition)
        {
            const ver = decl.compileCondition.versionCondition;
            if (ver && ver.token.text in badVersions)
                acc = false;
        }
        if (acc)
            decl.accept(this);
    }

    override void visit(const(ImportDeclaration) decl)
    {
        foreach (const(SingleImport) si; decl.singleImports)
        {
            if (!si.identifierChain.identifiers.length)
                continue;
            *results ~= si.identifierChain.identifiers.map!(a => a.text).join(".");
        }
        if (decl.importBindings) with (decl.importBindings.singleImport)
            *results ~= identifierChain.identifiers.map!(a => a.text).join(".");
    }

    override void visit(const(MixinExpression) mix)
    {
        ++mixinDepth;
        mix.accept(this);
        --mixinDepth;
    }

    override void visit(const PrimaryExpression primary)
    {
        if (mixinDepth && primary.primary.type.isStringLiteral)
        {
            assert(primary.primary.text.length > 1);

            size_t startIndex = 1;
            startIndex += primary.primary.text[0] == 'q';
            auto il = parseAndVisit!(ImportLister)(primary.primary.text[startIndex..$-1], results);
            destruct(il);
        }
        primary.accept(this);
    }
}


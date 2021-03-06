module mainfun;

import
    std.stdio, std.algorithm;
import
    iz.memory, iz.sugar;
import
    core.stdc.string;
import
    dparse.lexer, dparse.parser, dparse.ast, dparse.rollback_allocator;
import
    common;

/**
 * Params:
 *      src = The source code for the module, as a null terminated string.
 * Returns:
 *      wether a module contains the main function.
 */
export extern(C) bool hasMainFun(const(char)* src)
{
    scope LexerConfig config;
    scope RollbackAllocator rba;
    scope StringCache sCache = StringCache(StringCache.defaultBucketCount);

    scope mod = src[0 .. src.strlen]
                .getTokensForParser(config, &sCache)
                .parseModule("", &rba, &ignoreErrors);

    MainFunctionDetector mfd = construct!(MainFunctionDetector);
    mfd.visit(mod);
    const bool result = mfd.hasMain;
    destruct(mfd);
    destroy(sCache);
    destroy(rba);
    return result;
}

static assert(!MustAddGcRange!MainFunctionDetector);

@TellRangeAdded
private final class MainFunctionDetector: ASTVisitor
{
    alias visit = ASTVisitor.visit;

    bool hasMain;

    override void visit(const ConditionalDeclaration decl)
    {
        bool acc = true;
        if (const VersionCondition vc = safeAccess(decl).compileCondition.versionCondition)
        {
            if (vc.token.text in badVersions())
                acc = false;
        }
        if (acc)
            decl.accept(this);
    }

    override void visit(const(FunctionDeclaration) decl)
    {
        if (decl.name.text == "main")
            hasMain = true;
    }

    override void visit(const(Unittest))            {}
    override void visit(const(ClassDeclaration))    {}
    override void visit(const(StructDeclaration))   {}
    override void visit(const(InterfaceDeclaration)){}
    override void visit(const(UnionDeclaration))    {}
    override void visit(const(FunctionBody))        {}
}


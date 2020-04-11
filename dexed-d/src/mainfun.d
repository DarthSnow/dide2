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
extern(C) bool hasMainFun(const(char)* src)
{
    LexerConfig config;
    RollbackAllocator rba;
    StringCache sCache = StringCache(StringCache.defaultBucketCount);

    scope mod = src[0 .. src.strlen]
                .getTokensForParser(config, &sCache)
                .parseModule("", &rba, &ignoreErrors);

    MainFunctionDetector mfd = construct!(MainFunctionDetector);
    scope (exit) destruct(mfd);

    mfd.visit(mod);
    return mfd.hasMain;
}

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

    override void visit(const(Unittest)){}
    override void visit(const(ClassDeclaration)){}
    override void visit(const(StructDeclaration)){}
    override void visit(const(InterfaceDeclaration)){}
    override void visit(const(FunctionBody)){}
}


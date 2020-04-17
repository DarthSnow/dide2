module ddoc_template;

import
    core.stdc.string;
import
    std.array, std.conv, std.string;
import
    iz.memory, iz.sugar;
import
    dparse.ast, dparse.lexer, dparse.parser, dparse.rollback_allocator;
import
    common;

/**
 * Finds the declaration at caretLine and write its ddoc template
 * and returns its DDOC template as a C string.
 *
 * Params:
 *      src = the module source code, as a C string.
 *      caretLine = the line where the declaration is located.
 *      plusComment = indicates if the template use the "*" or the "+" decoration.
 */
extern(C) const(char)* ddocTemplate(const(char)* src, int caretLine, bool plusComment)
{
    LexerConfig config;
    RollbackAllocator rba;
    StringCache sCache = StringCache(StringCache.defaultBucketCount);

    scope mod = src[0 .. src.strlen]
                .getTokensForParser(config, &sCache)
                .parseModule("", &rba, &ignoreErrors);

    DDocTemplateGenerator dtg = construct!DDocTemplateGenerator(caretLine, plusComment);
    scope(exit) destruct(dtg);
    dtg.visit(mod);

    return dtg.result;
}

private void putLine(T...)(ref Appender!string a, T t)
{
    static foreach (i; 0 .. T.length)
        a.put(t[i].to!string);
    a.put("\n");
}

final class DDocTemplateGenerator: ASTVisitor
{
    alias visit = ASTVisitor.visit;

private:

    immutable int _caretline;
    immutable char c1;
    immutable char[2] c2;
    Appender!string app;
    bool _throws;

public:

    this(int caretline, bool plusComment)
    {
        _caretline = caretline;
        c1 = plusComment ? '+' : '*';
        c2 = plusComment ? "++" : "**";
    }

    const(char)* result() { return app.data.toStringz(); }

    override void visit(const(ThrowStatement) ts)
    {
        _throws = true;
    }

    override void visit(const(Catch) c)
    {
        _throws = false;
    }

    override void visit(const(FunctionDeclaration) decl)
    {
        _throws = false;
        if (decl.name.line == _caretline)
        {
            decl.accept(this);
            app.putLine("/", c2, "\n ", c1, " <short description> \n ", c1, " \n ", c1, " <detailed description>", c1);

            const TemplateParameterList tpl = safeAccess(decl).templateParameters.templateParameterList;
            if ((tpl && tpl.items.length) ||
                (decl.parameters && decl.parameters.parameters.length))
            {
                app.putLine(" ", c1, " \n ", c1, " Params:");

                if (tpl)
                {
                    foreach(const TemplateParameter p;  tpl.items)
                    {
                        if (p.templateAliasParameter)
                            app.putLine(" ", c1, "     ", p.templateAliasParameter.identifier.text, " = <description>");
                        else if (p.templateTupleParameter)
                            app.putLine(" ", c1, "     ", p.templateTupleParameter.identifier.text, " = <description>");
                        else if (p.templateTypeParameter)
                            app.putLine(" ", c1, "     ", p.templateTypeParameter.identifier.text, " = <description>");
                        else if (p.templateValueParameter)
                            app.putLine(" ", c1, "     ", p.templateValueParameter.identifier.text, " = <description>");
                    }
                }
                if (decl.parameters)
                {
                    foreach(i, const Parameter p; decl.parameters.parameters)
                    {
                        if (p.name.text != "")
                            app.putLine(" ", c1, "     ", p.name.text, " = <description>");
                        else
                            app.putLine(" ", c1, "     __param", i, " = <description>");
                    }
                }
            }

            if (const Type2 tp2 = safeAccess(decl).returnType.type2)
            {
                if (tp2.builtinType != tok!"void")
                    app.putLine(" ", c1, " \n ", c1, " Returns: <return description>");
            }

            if (_throws)
            {
                app.putLine(" ", c1, " \n ", c1, " Throws: <exception type as hint for catch>");
            }

            app.putLine(" ", c1, "/");

        }
        else if (decl.name.line > _caretline)
            return;
    }

    override void visit(const(TemplateDeclaration) decl)
    {
        visitTemplateOrAggregate(decl);
    }

    override void visit(const(ClassDeclaration) decl)
    {
        visitTemplateOrAggregate(decl);
    }

    override void visit(const(StructDeclaration) decl)
    {
        visitTemplateOrAggregate(decl);
    }

    override void visit(const(UnionDeclaration) decl)
    {
        visitTemplateOrAggregate(decl);
    }

    override void visit(const(AutoDeclarationPart) decl)
    {
        if (decl.templateParameters)
            visitTemplateOrAggregate(decl);
    }

    private void visitTemplateOrAggregate(T)(const(T) decl)
    {
        size_t line;
        static if (__traits(hasMember, T, "name"))
            line = decl.name.line;
        else
            line = decl.identifier.line;

        if (_caretline == line)
        {
            app.putLine("/", c2, "\n ", c1, " <short description> \n ", c1, " \n ", c1, " <detailed description>", c1);

            const TemplateParameterList tpl = safeAccess(decl).templateParameters.templateParameterList;
            if (tpl && tpl.items.length)
            {
                app.putLine(" ", c1, " \n ", c1, " Params:");

                foreach(const TemplateParameter p;  tpl.items)
                {
                    if (p.templateAliasParameter)
                        app.putLine(" ", c1, "     ", p.templateAliasParameter.identifier.text, " = <description>");
                    else if (p.templateTupleParameter)
                        app.putLine(" ", c1, "     ", p.templateTupleParameter.identifier.text, " = <description>");
                    else if (p.templateTypeParameter)
                        app.putLine(" ", c1, "     ", p.templateTypeParameter.identifier.text, " = <description>");
                    else if (p.templateValueParameter)
                        app.putLine(" ", c1, "     ", p.templateValueParameter.identifier.text, " = <description>");
                }
            }
            app.putLine(" ", c1, "/");

        }
        else if (line > _caretline)
            return;
        decl.accept(this);
    }
}


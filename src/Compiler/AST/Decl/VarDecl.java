package Compiler.AST.Decl;

import Compiler.AST.Statement.Expression.Expression;
import Compiler.AST.Statement.Statement;
import Compiler.AST.Symbol;
import Compiler.AST.Type.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class VarDecl implements Declaration, Statement {
    public Type type;
    public Symbol name;
    public Expression init;

    public VarDecl(Type t, Symbol n) {
        type = t;
        name = n;
        init = null;
    }

    public VarDecl(Type t, Symbol n, Expression i) {
        type = t;
        name = n;
        init = i;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "VarDecl\n";
        string += type.toString(d + 1);
        string += name.toString(d + 1);
        if (init != null) string += init.toString(d + 1);
        return string;
    }
}

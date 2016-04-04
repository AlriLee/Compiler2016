package Compiler.AST.Statement;

import Compiler.AST.Statement.Expression.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ReturnStatement implements Statement {
    public Expression expr;

    public ReturnStatement() {
        expr = null;
    }

    public ReturnStatement(Expression e) {
        expr = e;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ReturnStatement\n";
        if (expr != null) {
            string += expr.toString(d + 1);
        }
        return string;
    }
}

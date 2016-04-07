package Compiler.AST.Statement;

import Compiler.AST.Statement.Expression.Expression;
import Compiler.AST.Type.BoolType;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class WhileLoop implements Statement {
    public Expression condition;
    public Statement body;

    public WhileLoop(Expression cond, Statement b) {
        if (!(cond.type instanceof BoolType)) {
            throw new CompileError("A BoolType expression is expected in WhileLoop.");
        }
        condition = cond;
        body = b;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "WhileLoop\n";
        string += condition.toString(d + 1);
        string += body.toString(d + 1);
        return string;
    }
}

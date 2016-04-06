package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.LvalueType;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class PostSelfDecrement extends Expression {
    public Expression body;

    public PostSelfDecrement(Expression b) {
        if (!(b.type instanceof LvalueType)) {
            throw new CompileError("Non lvalue used as operand of decrement operator.");
        }
        body = b;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "PostSelfDecrement\n" + body.toString(d + 1);
    }
}

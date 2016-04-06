package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.IntType;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class PostSelfIncrement extends Expression {
    public Expression body;

    public PostSelfIncrement(Expression b) {
        if (!(b.type.isLvalue())) {
            throw new CompileError("Non lvalue used as operand of increment operator.");
        }
        if (!(b.type instanceof IntType)) {
            throw new CompileError("Non int-type object used as operand of increment operator." + body.toString(0));
        }
        body = b;
        type = new IntType();
    }

    @Override
    public String toString(int d) {
        return indent(d) + "PostSelfIncrement\n" + body.toString(d + 1);
    }
}

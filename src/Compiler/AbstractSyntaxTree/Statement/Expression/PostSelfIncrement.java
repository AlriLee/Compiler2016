package Compiler.AbstractSyntaxTree.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class PostSelfIncrement extends Expression {
    public Expression body;

    public PostSelfIncrement(Expression b) {
        body = b;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "PostSelfIncrement\n" + body.toString(d + 1);
    }
}

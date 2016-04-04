package Compiler.AbstractSyntaxTree.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class PostSelfDecrement extends Expression {
    public Expression body;

    public PostSelfDecrement(Expression b) {
        body = b;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "PostSelfDecrement\n" + body.toString(d + 1);
    }
}

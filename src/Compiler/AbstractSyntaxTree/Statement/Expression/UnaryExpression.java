package Compiler.AbstractSyntaxTree.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class UnaryExpression extends Expression {
    public UnaryOp op;
    public Expression expression;

    public UnaryExpression(UnaryOp o, Expression e) {
        op = o;
        expression = e;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "UnaryExpression\n";
        string = string + indent(d + 1) + op.toString();
        string += expression.toString(d + 1);
        return string;
    }
}

package Compiler.AST.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class BinaryExpression extends Expression {
    public Expression left;
    public BinaryOp op;
    public Expression right;

    public BinaryExpression(Expression l, BinaryOp o, Expression r) {

        left = l;
        op = o;
        right = r;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "BinaryExpression\n"
                + left.toString(d + 1)
                + indent(d + 1)
                + op.toString()
                + right.toString(d + 1)
                ;
    }
}

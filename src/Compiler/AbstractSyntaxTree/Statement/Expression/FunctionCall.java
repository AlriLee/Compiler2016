package Compiler.AbstractSyntaxTree.Statement.Expression;

import Compiler.AbstractSyntaxTree.ExpressionList;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class FunctionCall extends Expression {
    public Expression functionBody;
    public ExpressionList arguments;

    public FunctionCall(Expression fb) {
        functionBody = fb;
        arguments = null;
    }

    public FunctionCall(Expression fb, ExpressionList arg) {
        functionBody = fb;
        arguments = arg;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "FunctionCall\n";
        string += functionBody.toString(d + 1);
        if (arguments != null) {
            string += arguments.toString(d + 1);
        }
        return string;
    }
}

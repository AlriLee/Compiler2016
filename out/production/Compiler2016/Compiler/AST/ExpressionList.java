package Compiler.AST;

import Compiler.AST.Statement.Expression.Expression;

/**
 * Created by Alri on 16/4/3.
 */
public class ExpressionList extends ASTNode {
    private Expression expression;
    private ExpressionList expressionList;

    public ExpressionList(Expression e) {
        expression = e;
        expressionList = null;
    }

    public ExpressionList(Expression e, ExpressionList el) {
        expression = e;
        expressionList = el;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ExpressionList\n";
        string += expression.toString(d+1);
        if (expressionList != null)
            string += expressionList.toString(d+1);
        return string;
    }
}

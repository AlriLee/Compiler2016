package Compiler.AbstractSyntaxTree.Statement;

import Compiler.AbstractSyntaxTree.Statement.Expression.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/30.
 */
public class IfStatement implements Statement {
    public Expression condition;
    public Statement consequence;
    public Statement alternative;

    public IfStatement(Expression cond, Statement conse) {
        condition = cond;
        consequence = conse;
        alternative = null;
    }

    public IfStatement(Expression cond, Statement conse, Statement alter) {
        condition = cond;
        consequence = conse;
        alternative = alter;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "IfStatement\n" + condition.toString(d + 1) + consequence.toString(d + 1);
        if (alternative != null) {
            string += alternative.toString(d + 1);
        }
        return string;
    }
}

package Compiler.AST.Statement;

import Compiler.AST.Statement.Expression.Expression;
import Compiler.AST.Type.BoolType;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ForLoop implements Statement {
    public Expression initExpression;
    public Expression conditionExpression;
    public Expression incrementExpression;
    public Statement forStatement;

    public ForLoop(Expression init, Expression cond, Expression incre, Statement state) {
        if (!(cond.type instanceof BoolType)) {
            throw new CompileError("A BoolType expression is expected.");
        }
        initExpression = init;
        conditionExpression = cond;
        incrementExpression = incre;
        forStatement = state;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ForLoop\n";
        if (initExpression != null) {
            string += initExpression.toString(d + 1);
        }
        if (conditionExpression != null) {
            string += conditionExpression.toString(d + 1);
        }
        if (incrementExpression != null) {
            string += incrementExpression.toString(d + 1);
        }
        string += forStatement.toString(d + 1);

        return string;
    }
}

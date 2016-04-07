package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.BoolType;
import Compiler.AST.Type.IntType;
import Compiler.Error.CompileError;

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
        switch (op) {
            case NOT: {
                if (!(e.type instanceof BoolType)) {
                    throw new CompileError("Type error.");
                }
                type = e.type;
                break;
            }
            case PLUS:
            case MINUS:
            case TILDE: {
                if (!(e.type instanceof IntType)) {
                    throw new CompileError("Type error.");
                }
                type = e.type;
                break;
            }
            case INC:
            case DEC: {
                if (!e.lvalue) {
                    throw new CompileError("UnaryExpression " + op.toString() + " used on non-lvalue expression " + expression.toString(0));
                }
                if (!(e.type instanceof IntType)) {
                    throw new CompileError("UnaryExpression " + op.toString() + " used on non-int type expression " + e.type.toString(0));
                }
                type = e.type;
                break;
            }
        }
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "UnaryExpression\n";
        string = string + indent(d + 1) + op.toString();
        string += expression.toString(d + 1);
        return string;
    }
}

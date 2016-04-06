package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.BoolType;
import Compiler.AST.Type.IntType;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class BinaryExpression extends Expression {
    public Expression left;
    public BinaryOp op;
    public Expression right;

    public BinaryExpression(Expression l, BinaryOp o, Expression r) {
        // Type checking
        switch (o) {
            case ASSIGN: {
                if (!(l.type.isLvalue()))
                    throw new CompileError("Assign something to non-lvalue.");
                if (l.type.equal(r.type))
                    throw new CompileError("Type conflict between lhs and rhs of " + o.toString() + " operator.");
                type = l.type;
                break;
            }
            case LOGICAL_AND:
            case LOGICAL_OR: {
                if (!(l.type instanceof BoolType))
                    throw new CompileError("Non-boolean expr used on left-hand-side of " + o.toString());
                if (!(r.type instanceof BoolType))
                    throw new CompileError("Non-boolean expr used on right-hand-side of " + o.toString());
                type = new BoolType();
                break;
            }
            case OR:
            case XOR:
            case AND:
            case NEQ:
            case EQ:
            case LT:
            case GT:
            case LEQ:
            case GEQ:
            case SHL:
            case SHR:
            case ADD:
            case SUB:
            case MUL:
            case DIV:
            case MOD: {
                if (!(l.type instanceof IntType))
                    throw new CompileError("Non-int expr used on left-hand-side of " + o.toString());
                if (!(r.type instanceof IntType))
                    throw new CompileError("Non-int expr used on right-hand-side of " + o.toString());
                type = new IntType();
                break;
            }
        }
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

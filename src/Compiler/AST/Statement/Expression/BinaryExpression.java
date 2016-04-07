package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.BoolType;
import Compiler.AST.Type.IntType;
import Compiler.AST.Type.StringType;
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
                if (!(l.lvalue))
                    throw new CompileError("Assign something to non-lvalue.");
                if (!l.type.equal(r.type))
                    throw new CompileError("Type conflict between lhs and rhs of " + o.toString() + " operator.");
                type = l.type;
                lvalue = true;
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
            case AND: {
                if (!(l.type instanceof IntType))
                    throw new CompileError("Non-int expr used on left-hand-side of " + o.toString());
                if (!(r.type instanceof IntType))
                    throw new CompileError("Non-int expr used on right-hand-side of " + o.toString());
                type = new IntType();
                break;
            }
//  !!! type equal
            case NEQ:
            case EQ: {
                if (!l.type.equal(r.type)) {
                    throw new CompileError("Type conflict between two sides of " + o.toString());
                }
                type = new BoolType();
                break;
            }
//  !!! int / string
            case LT:
            case GT:
            case LEQ:
            case GEQ: {
                if (!l.type.equal(r.type)) {
                    throw new CompileError("Type conflict between two sides of " + o.toString());
                }
                if (!(l.type instanceof IntType) && !(l.type instanceof StringType)) {
                    throw new CompileError("Type of left hand side of " + o.toString() + " is neither int nor string.");
                }
                if (!(r.type instanceof IntType) && !(r.type instanceof StringType)) {
                    throw new CompileError("Type of right hand side of " + o.toString() + " is neither int nor string.");
                }
                type = new BoolType();
                break;
            }
            case ADD: {
                if (l.type == null) {
                    if (l instanceof FunctionCall) {
                        throw new CompileError("");
                    }
                }
                if (!l.type.equal(r.type)) {
                    throw new CompileError("Type conflict between two sides of " + o.toString());
                }
                if (!(l.type instanceof IntType) && !(l.type instanceof StringType)) {
                    throw new CompileError("Type of left hand side of " + o.toString() + " is neither int nor string.");
                }
                if (!(r.type instanceof IntType) && !(r.type instanceof StringType)) {
                    throw new CompileError("Type of right hand side of " + o.toString() + " is neither int nor string.");
                }
                type = l.type;
                break;
            }
            case SHL:
            case SHR:
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
        // How to decide whether this object is lvalue?
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

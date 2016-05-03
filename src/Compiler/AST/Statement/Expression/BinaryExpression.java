package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.*;
import Compiler.ControlFlowGraph.Instruction.*;
import Compiler.Error.CompileError;
import Compiler.Operand.Address;
import Compiler.Operand.Immediate;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class BinaryExpression extends Expression {
    public Expression left;
    public BinaryOp op;
    public Expression right;

    public BinaryExpression(Expression l, BinaryOp o, Expression r) {
        boolean sameType = l.type.equal(r.type);
        if (l.type instanceof NullType) {
            if (r.type instanceof NullType || r.type instanceof ClassType || r.type instanceof ArrayType) {
                sameType = true;
            }
        }
        if (r.type instanceof NullType) {
            if (l.type instanceof NullType || l.type instanceof ClassType || l.type instanceof ArrayType) {
                sameType = true;
            }
        }
        if (!sameType) {
            throw new CompileError("type error");
        }

        // Type checking
        switch (o) {
            case ASSIGN: {
                if (!(l.lvalue))
                    throw new CompileError("Assign something to non-lvalue.");
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
                type = new BoolType();
                break;
            }
//  !!! int / string
            case LT:
            case GT:
            case LEQ:
            case GEQ: {
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
    }

    @Override
    public void emit(List<Instruction> instructions) {
        this.operand = new Register();
        switch (op) {
            case ASSIGN: {
                left.emit(instructions);
                right.emit(instructions);
                right.load(instructions);
                if (left.operand instanceof Address) {
                    instructions.add(new StoreInstruction((Address) left.operand, right.operand));
                } else {
                    instructions.add(new MoveInstruction((Register) left.operand, right.operand));
                }
                this.operand = left.operand;
                break;
            }
            case LOGICAL_AND: {
                left.emit(instructions);
                left.load(instructions);
                LabelInstruction logicalTrue = new LabelInstruction("logicalTrue");
                LabelInstruction logicalFalse = new LabelInstruction("logicalFalse");
                LabelInstruction logicalMerge = new LabelInstruction("logicalMerge");
                JumpInstruction logicalMergeJump = new JumpInstruction(logicalMerge);
                instructions.add(new ConditionBranchInstruction(left.operand, logicalTrue, logicalFalse));
                instructions.add(logicalTrue);
                right.emit(instructions);
                right.load(instructions);
                instructions.add(new MoveInstruction((Register) operand, right.operand));
                instructions.add(logicalMergeJump);
                //instructions.add(new BinaryInstruction(op, (Register) this.operand, left.operand, right.operand));
                instructions.add(logicalFalse);
                instructions.add(new MoveInstruction((Register) operand, new Immediate(0)));
                instructions.add(logicalMergeJump);
                instructions.add(logicalMerge);
                break;
            }
            case LOGICAL_OR: {
                left.emit(instructions);
                left.load(instructions);
                LabelInstruction logicalTrue = new LabelInstruction("logicalTrue");
                LabelInstruction logicalFalse = new LabelInstruction("logicalFalse");
                LabelInstruction logicalMerge = new LabelInstruction("logicalMerge");
                JumpInstruction logicalMergeJump = new JumpInstruction(logicalMerge);
                instructions.add(new ConditionBranchInstruction(left.operand, logicalTrue, logicalFalse));
                instructions.add(logicalTrue);
                instructions.add(new MoveInstruction((Register) operand, new Immediate(1)));
                instructions.add(logicalMergeJump);
                instructions.add(logicalFalse);
                right.emit(instructions);
                right.load(instructions);
                //instructions.add(new BinaryInstruction(op, (Register) this.operand, left.operand, right.operand));
                instructions.add(new MoveInstruction((Register) operand, right.operand));
                instructions.add(logicalMergeJump);
                instructions.add(logicalMerge);
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
            case ADD:
            case SHL:
            case SHR:
            case SUB:
            case MUL:
            case DIV:
            case MOD: {
                left.emit(instructions);
                right.emit(instructions);
                left.load(instructions);
                right.load(instructions);
                instructions.add(new BinaryInstruction(op, (Register) this.operand, left.operand, right.operand));
                break;
            }
        }
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

    @Override
    public void load(List<Instruction> instructions) {
        if (operand instanceof Address) {
            Address srcAddr = (Address) operand;
            operand = new Register();
            instructions.add(new LoadInstruction((Register) operand, srcAddr));
        }
    }
}

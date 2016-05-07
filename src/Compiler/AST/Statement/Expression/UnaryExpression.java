package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.BoolType;
import Compiler.AST.Type.IntType;
import Compiler.ControlFlowGraph.Instruction.BinaryInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.StoreInstruction;
import Compiler.ControlFlowGraph.Instruction.UnaryInstruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Address;
import Compiler.Operand.Immediate;
import Compiler.Operand.Register;

import java.util.List;

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
    public void emit(List<Instruction> instructions) {
        expression.emit(instructions);
        switch (op) {
            case NOT: {
                expression.load(instructions);
                operand = new Register();
                instructions.add(new UnaryInstruction(op, (Register) operand, expression.operand));
                break;
            }
            case PLUS: {
                expression.load(instructions);
                operand = expression.operand;
                break;
            }
            case MINUS: {
                expression.load(instructions);
                operand = new Register();
                instructions.add(new UnaryInstruction(op, (Register) operand, expression.operand));
                break;
            }
            case TILDE: {
                expression.load(instructions);
                operand = new Register();
                instructions.add(new UnaryInstruction(op, (Register) operand, expression.operand));
                break;
            }
            case INC: {
                if (expression.operand instanceof Address) {
                    Address address = (Address) expression.operand;
                    address = new Address(address.baseAddress, address.offSet, address.size);
                    expression.load(instructions);
                    operand = expression.operand;
                    instructions.add(new BinaryInstruction(BinaryOp.ADD, (Register) operand, (Register) operand, new Immediate(1)));
                    instructions.add(new StoreInstruction(address, operand));
                } else {
                    expression.load(instructions);
                    operand = expression.operand;
                    instructions.add(new BinaryInstruction(BinaryOp.ADD, (Register) operand, (Register) operand, new Immediate(1)));
                }
                break;
            }
            case DEC: {
                if (expression.operand instanceof Address) {
                    Address address = (Address) expression.operand;
                    address = new Address(address.baseAddress, address.offSet, address.size);
                    expression.load(instructions);
                    operand = expression.operand;
                    instructions.add(new BinaryInstruction(BinaryOp.SUB, (Register) operand, (Register) operand, new Immediate(1)));
                    instructions.add(new StoreInstruction(address, operand));
                } else {
                    operand = expression.operand;
                    instructions.add(new BinaryInstruction(BinaryOp.SUB, (Register) operand, (Register) operand, new Immediate(1)));
                }
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

    @Override
    public void load(List<Instruction> instructions) {

    }
}

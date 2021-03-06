package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.IntType;
import Compiler.ControlFlowGraph.Instruction.BinaryInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.MoveInstruction;
import Compiler.ControlFlowGraph.Instruction.StoreInstruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Address;
import Compiler.Operand.Immediate;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class PostSelfDecrement extends Expression {
    public Expression body;

    public PostSelfDecrement(Expression b) {
        if (!(b.lvalue)) {
            throw new CompileError("Non lvalue used as operand of decrement operator.");
        }
        if (!(b.type instanceof IntType)) {
            throw new CompileError("Non int-type object used as operand of decrement operator." + body.toString(0));
        }
        body = b;
        type = new IntType();
    }

    @Override
    public String toString(int d) {
        return indent(d) + "PostSelfDecrement\n" + body.toString(d + 1);
    }

    @Override
    public void emit(List<Instruction> instructions) {
        body.emit(instructions);
        operand = new Register();
        if (body.operand instanceof Address) {
            Address address = (Address) body.operand;
            address = new Address(address.baseAddress, address.offSet, address.size);
            body.load(instructions);
            instructions.add(new MoveInstruction((Register) operand, address));
            Register after = new Register();
            instructions.add(new BinaryInstruction(BinaryOp.SUB, after, operand, new Immediate(1)));
            instructions.add(new StoreInstruction(address, after));
        } else {
            instructions.add(new MoveInstruction((Register) operand, body.operand));
            instructions.add(new BinaryInstruction(BinaryOp.SUB, (Register) body.operand, body.operand, new Immediate(1)));
        }
    }

    @Override
    public void load(List<Instruction> instructions) {

    }
}

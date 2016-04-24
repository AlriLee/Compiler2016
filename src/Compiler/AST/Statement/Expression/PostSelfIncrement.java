package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.IntType;
import Compiler.ControlFlowGraph.Instruction.BinaryInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.MoveInstruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Immediate;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class PostSelfIncrement extends Expression {
    public Expression body;

    public PostSelfIncrement(Expression b) {
        if (!b.lvalue) {
            throw new CompileError("Non lvalue used as operand of increment operator.");
        }
        if (!(b.type instanceof IntType)) {
            throw new CompileError("Non int-type object used as operand of increment operator.");
        }
        body = b;
        type = new IntType();
    }

    @Override
    public String toString(int d) {
        return indent(d) + "PostSelfIncrement\n" + body.toString(d + 1);
    }

    @Override
    public void emit(List<Instruction> instructions) {
        body.emit(instructions);
        operand = new Register();
        instructions.add(new MoveInstruction((Register) operand, body.operand));
        instructions.add(new BinaryInstruction(BinaryOp.ADD, (Register) body.operand, body.operand, new Immediate(1)));
    }
}

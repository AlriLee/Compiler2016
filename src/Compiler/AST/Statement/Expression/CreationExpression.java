package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.Type;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.MoveInstruction;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class CreationExpression extends Expression {
    public CreationExpression(Type t) {
        type = t;
    }

    @Override
    public void emit(List<Instruction> instructions) {
        operand = new Register();
        MoveInstruction moveInstruction = new MoveInstruction((Register) operand, type.alloc(instructions));
        instructions.add(moveInstruction);
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "CreationExpression\n";
        string += type.toString(d + 1);
        return string;
    }

    @Override
    public void load(List<Instruction> instructions) {

    }
}

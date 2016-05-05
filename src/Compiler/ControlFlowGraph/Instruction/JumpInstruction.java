package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Operand;

import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class JumpInstruction extends Instruction {
    public LabelInstruction dest;

    public JumpInstruction(LabelInstruction d) {
        dest = d;
    }

    @Override
    public String toString() {
        return "jump " + dest.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return null;
    }

    @Override
    public List<Operand> getDefinedOp() {
        return null;
    }
}

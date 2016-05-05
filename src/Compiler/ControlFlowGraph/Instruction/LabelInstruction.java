package Compiler.ControlFlowGraph.Instruction;

import Compiler.ControlFlowGraph.BasicBlock.BasicBlock;
import Compiler.Operand.Operand;

import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class LabelInstruction extends Instruction {
    public static int labelCount = 0;
    public String label;
    public int labelIndex;
    public BasicBlock block;

    public LabelInstruction(String l) {
        label = l;
        labelIndex = labelCount++;
        block = null;
    }

    @Override
    public String toString() {
        return "%" + label + String.valueOf(labelIndex);
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

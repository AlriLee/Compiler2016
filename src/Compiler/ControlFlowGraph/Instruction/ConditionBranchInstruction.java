package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Operand;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class ConditionBranchInstruction extends Instruction {
    public Operand src;
    public LabelInstruction tar1, tar2;

    public ConditionBranchInstruction(Operand s, LabelInstruction t1, LabelInstruction t2) {
        src = s;
        tar1 = t1;
        tar2 = t2;
    }

    @Override
    public String toString() {
        return "br " + src.toString() + " " + tar1.toString() + " " + tar2.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return Collections.singletonList(src);
    }

    @Override
    public List<Operand> getDefinedOp() {
        return null;
    }
}

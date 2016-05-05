package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class MoveInstruction extends Instruction {
    public Register rDest;
    public Operand src;

    public MoveInstruction(Register d, Operand s) {
        rDest = d;
        src = s;
    }

    @Override
    public String toString() {
        return rDest.toString() + " = move " + src.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return Collections.singletonList(src);
    }

    @Override
    public List<Operand> getDefinedOp() {
        return Collections.singletonList(rDest);
    }
}

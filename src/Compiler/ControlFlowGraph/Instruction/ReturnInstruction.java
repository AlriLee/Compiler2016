package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Operand;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/25.
 */
public class ReturnInstruction extends Instruction {
    public Operand returnOperand;

    public ReturnInstruction(Operand ro) {
        returnOperand = ro;
    }

    @Override
    public String toString() {
        return "ret " + returnOperand.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return Collections.singletonList(returnOperand);
    }

    @Override
    public List<Operand> getDefinedOp() {
        return null;
    }
}

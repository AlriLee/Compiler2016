package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/24.
 */
public class AllocInstruction extends Instruction {
    public Register address;
    public Register allocSize;

    public AllocInstruction(Register ad, Register as) {
        address = ad;
        allocSize = as;
    }

    @Override
    public String toString() {
        return address.toString() + " = alloc " + allocSize.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return Collections.singletonList(allocSize);
    }

    @Override
    public List<Operand> getDefinedOp() {
        return Collections.singletonList(address);
    }
}

package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Address;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class LoadInstruction extends Instruction {
    public Register dest;
    public Address src;

    public LoadInstruction(Register d, Address s) {
        dest = d;
        src = s;
    }

    // $dest = load size $addr offset
    @Override
    public String toString() {
        return dest.toString() + " = load " + src.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return Collections.singletonList(src);
    }

    @Override
    public List<Operand> getDefinedOp() {
        return Collections.singletonList(dest);
    }
}

package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Address;
import Compiler.Operand.Operand;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/28.
 */
public class StoreInstruction extends Instruction {
    public Address dest;
    public Operand src;

    public StoreInstruction(Address d, Operand s) {
        dest = d;
        src = s;
    }

    //store size $addr $src offset
    @Override
    public String toString() {
        return "store "
                + String.valueOf(dest.size) + " "
                + dest.baseAddress.toString() + " "
                + src.toString() + " "
                + dest.offSet.toString();
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

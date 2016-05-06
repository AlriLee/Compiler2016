package Compiler.ControlFlowGraph.Instruction;

import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public abstract class Instruction {
    public abstract List<Operand> getUsedOp();

    public abstract List<Operand> getDefinedOp();

    public List<Register> getUsedReg() {
        List<Operand> usedOp = getUsedOp();
        if (usedOp == null)
            return Collections.emptyList();
        List<Register> usedReg = new ArrayList<>();
        for (int i = 0; i < usedOp.size(); ++i) {
            if (usedOp.get(i) instanceof Register) {
                usedReg.add((Register) usedOp.get(i));
            }
        }
        return usedReg;
    }

    public List<Register> getDefinedReg() {
        List<Operand> definedOp = getDefinedOp();
        if (definedOp == null)
            return Collections.emptyList();
        List<Register> definedReg = new ArrayList<>();
        for (int i = 0; i < definedOp.size(); ++i) {
            if (definedOp.get(i) instanceof Register) {
                definedReg.add((Register) definedOp.get(i));
            }
        }
        return definedReg;
    }
}

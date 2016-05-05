package Compiler.ControlFlowGraph.BasicBlock;

import Compiler.ControlFlowGraph.Instruction.ConditionBranchInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.JumpInstruction;
import Compiler.ControlFlowGraph.Instruction.LabelInstruction;
import Compiler.Operand.Register;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by Alri on 16/4/24.
 */
public class BasicBlock {
    public LabelInstruction blockLabel;
    public List<Instruction> blockInstruction;
    public LiveAnalysis liveAnalysis;
    public List<BasicBlock> successor;
    public List<BasicBlock> predecessor;

    public BasicBlock(LabelInstruction bl) {
        bl.block = this;
        blockLabel = bl;
        blockInstruction = new ArrayList<>();
        liveAnalysis = new LiveAnalysis();
        successor = new ArrayList<>();
        predecessor = new ArrayList<>();
    }

    public void addInstruction(Instruction i) {
        blockInstruction.add(i);
    }

    public void analyseLiveness() {
        for (int i = 0; i < blockInstruction.size(); ++i) {
            List<Register> usedReg = blockInstruction.get(i).getUsedReg();
            if (usedReg != null) {
                for (int j = 0; j < usedReg.size(); ++j) {
                    if (liveAnalysis.varKill.contains(usedReg.get(j)))
                        continue;
                    liveAnalysis.ueVar.add(usedReg.get(j));
                }
            }
            //liveAnalysis.ueVar.addAll(blockInstruction.get(i).getUsedReg());
            if (blockInstruction.get(i).getDefinedReg() != null)
                liveAnalysis.varKill.addAll(blockInstruction.get(i).getDefinedReg());
        }
    }

    public void getSuccessor() {
        if (blockInstruction.size() == 0) {
            System.out.println("Null blockInstruction");
            return;
        }
        Instruction lastInstruction = blockInstruction.get(blockInstruction.size() - 1);
        if (lastInstruction instanceof JumpInstruction) {
            successor.add(((JumpInstruction) lastInstruction).dest.block);
        } else if (lastInstruction instanceof ConditionBranchInstruction) {
            successor.add(((ConditionBranchInstruction) lastInstruction).tar1.block);
            successor.add(((ConditionBranchInstruction) lastInstruction).tar2.block);
        }
    }

    public void getPredecessor() {
        //getSuccessor();
        for (int i = 0; i < successor.size(); ++i) {
            successor.get(i).predecessor.add(this);
        }
    }

    /*
        public boolean liveOut() {
            boolean changed = false;
            for (int i = 0; i < successor.size(); ++i) {
                for (int j = 0; j < successor.get(i).liveAnalysis.ueVar.size(); ++j) {
                    if (!liveAnalysis.liveOut.contains(successor.get(i).liveAnalysis.ueVar.get(j))) {
                        liveAnalysis.liveOut.add(successor.get(i).liveAnalysis.ueVar.get(j));
                        changed = true;
                    }
                }
                for (Register liveOutM: successor.get(i).liveAnalysis.liveOut) {
                    if (!successor.get(i).liveAnalysis.varKill.contains(liveOutM)) {
                        liveAnalysis.liveOut.add(liveOutM);
                        changed = true;
                    }
                }
            }
            return changed;
        }
    */
    public String toString() {
        String basicBlock;
        basicBlock = blockLabel.toString() + ":\n";
        for (int i = 0; i < blockInstruction.size(); ++i) {
            basicBlock = basicBlock + blockInstruction.get(i).toString() + "\n";
        }
        return basicBlock;
    }

    public String livenessToString() {
        String livenessString = blockLabel.toString() + "\n";
        livenessString = livenessString + "ueVar:\n";
        for (Register ueVarReg : liveAnalysis.ueVar) {
            livenessString = livenessString + ueVarReg.toString() + "\n";
        }
        livenessString = livenessString + "varKill:\n";
        for (Register varKillReg : liveAnalysis.varKill) {
            livenessString = livenessString + varKillReg.toString() + "\n";
        }
        livenessString = livenessString + "liveOut:\n";
        for (Register liveOutReg : liveAnalysis.liveOut) {
            livenessString = livenessString + liveOutReg.toString() + "\n";
        }
        return livenessString;
    }

    public class LiveAnalysis {
        public Set<Register> ueVar, varKill;
        public Set<Register> liveIn, liveOut;

        public LiveAnalysis() {
            ueVar = new HashSet<>();
            varKill = new HashSet<>();
            liveIn = new HashSet<>();
            liveOut = new HashSet<>();
        }
    }
}

package Compiler.GlobalRegisterAllocator;

import Compiler.ControlFlowGraph.BasicBlock.BasicBlock;
import Compiler.ControlFlowGraph.ControlFlowGraph;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Operand.Register;

import java.util.*;

/**
 * Created by Alri on 16/5/4.
 */
public class GlobalRegisterAllocator {
    public Map<Register, MIPSRegister> allocMapping;
    public Map<Register, Set<Register>> interferenceGraph;
    public Set<Register> vertices;
    public Set<Register> liveNow;

    public GlobalRegisterAllocator(ControlFlowGraph cfg) {
        allocMapping = new HashMap<>();
        interferenceGraph = new HashMap<>();
        vertices = new HashSet<>();
        liveNow = new HashSet<>();

        for (BasicBlock basicBlock : cfg.basicBlockList) {
            if (basicBlock.liveAnalysis.liveOut.isEmpty())
                continue;
            liveNow.addAll(basicBlock.liveAnalysis.liveOut);
            for (Instruction instruction : cfg.instruction) {
                List<Register> definedReg = instruction.getDefinedReg();
                List<Register> usedReg = instruction.getUsedReg();
                if (definedReg != null) {
                    for (Register defined : definedReg) {
                        //System.out.println("definedReg:\n" + defined.toString());
                        for (Register liveNowReg : liveNow) {
                            addEdge(liveNowReg, defined);
                        }
                        liveNow.remove(defined);
                        //System.out.println("liveNow size after removing: " + liveNow.size());
                    }
                }
                if (usedReg != null) {
                    for (Register used : usedReg) {
                        //System.out.println("usedReg:\n" + used.toString());
                        liveNow.add(used);
                        //System.out.println("liveNow size after adding: " + liveNow.size());
                    }
                }
                //System.out.println("liveNow size: " + liveNow.size());
            }
        }
    }

    public void addEdge(Register u, Register v) {
        if (!interferenceGraph.containsKey(u)) {
            interferenceGraph.put(u, new HashSet<>());
        }
        // A vertice cannot be mapped to itself, otherwise colouring is impossible.
        if (u == v)
            return;
        if (!interferenceGraph.containsKey(v)) {
            interferenceGraph.put(v, new HashSet<>());
        }
        //System.out.println("add edge:\n" + u.toString() + " " + v.toString());
        interferenceGraph.get(u).add(v);
        interferenceGraph.get(v).add(u);
    }

    public String interferenceGraphToString() {
        String interferenceGraphEdge = "interferenceGraphEdge:\n";
        for (Register u : interferenceGraph.keySet()) {
            interferenceGraphEdge = interferenceGraphEdge + u.toString() + " TO ";
            for (Register v : interferenceGraph.get(u)) {
                interferenceGraphEdge = interferenceGraphEdge + v.toString() + " ";
            }
            interferenceGraphEdge += "\n";
        }
        return interferenceGraphEdge;
    }
}














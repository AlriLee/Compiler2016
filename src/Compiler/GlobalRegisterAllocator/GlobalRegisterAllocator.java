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
    public static List<MIPSRegister> physicalRegister = new ArrayList<MIPSRegister>() {{
        add(MIPSRegister.t0);
        add(MIPSRegister.t1);
        add(MIPSRegister.t2);
        add(MIPSRegister.t3);
        add(MIPSRegister.t4);
        add(MIPSRegister.t5);
        add(MIPSRegister.t6);
        add(MIPSRegister.t7);
        add(MIPSRegister.s0);
        add(MIPSRegister.s1);
        add(MIPSRegister.s2);
        add(MIPSRegister.s3);
        add(MIPSRegister.s4);
        add(MIPSRegister.s5);
        add(MIPSRegister.s6);
        add(MIPSRegister.s7);
        add(MIPSRegister.t8);
        add(MIPSRegister.t9);
        add(MIPSRegister.k0);
        add(MIPSRegister.k1);
        add(MIPSRegister.gp);
        add(MIPSRegister.fp);
    }};
    public static MIPSRegister temperary1 = MIPSRegister.v1, temperary2 = MIPSRegister.a3;
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

    public void removeNode(Map.Entry<Register, Set<Register>> node) {
        for (Register v : node.getValue()) {
            interferenceGraph.get(v).remove(node.getKey());
        }
        interferenceGraph.remove(node.getKey());
    }

    public void addNode(Map.Entry<Register, Set<Register>> node) {
        for (Register v : node.getValue()) {
            addEdge(node.getKey(), v);
        }
    }

    public boolean colourNode(Map.Entry<Register, Set<Register>> node) {
        /*for (int i = 1; i <= 25; ++i) {
            MIPSRegister mipsRegister = MIPSRegister.getRegister(i);
            for (Register v: node.getValue()) {
                if (allocMapping.containsKey(v)) {
// TODO
                }
            }
        }*/
        return false;
    }

    public boolean allocPhysicalReg(long registerNum) {
        Stack<Map.Entry<Register, Set<Register>>> stack = new Stack<>();
        while (!interferenceGraph.isEmpty()) {
            boolean degreeLTk = false;
            for (Map.Entry<Register, Set<Register>> n : interferenceGraph.entrySet()) {
                if (n.getValue().size() < registerNum) {
                    stack.push(n);
                    degreeLTk = true;
                }
                removeNode(n);
            }
            if (!degreeLTk) {
                for (Map.Entry<Register, Set<Register>> n : interferenceGraph.entrySet()) {
                    stack.push(n);
                    removeNode(n);
                }
            }
        }
        while (!stack.isEmpty()) {
            Map.Entry<Register, Set<Register>> node = stack.pop();
            if (!colourNode(node)) {
                return false;
            }
            addNode(node);
        }
        return true;
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














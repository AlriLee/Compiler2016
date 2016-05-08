package Compiler.GlobalRegisterAllocator;

import Compiler.AST.Type.IntType;
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
        //add(MIPSRegister.t0);
        //add(MIPSRegister.t1);
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
    public Map<Register, MIPSRegister> allocMapping;
    public Map<Register, Set<Register>> interferenceGraph;
    public Set<Register> liveNow;
    public Map<Register, Integer> neighbour;
    public Set<Register> vertices;

    public Set<MIPSRegister> mipsRegisterInUse;

    public GlobalRegisterAllocator(ControlFlowGraph cfg) {
        allocMapping = new HashMap<>();
        interferenceGraph = new HashMap<>();

        neighbour = new HashMap<>();
        vertices = new HashSet<>();
        mipsRegisterInUse = new HashSet<>();

        for (BasicBlock basicBlock : cfg.basicBlockList) {
            for (Instruction instruction : basicBlock.blockInstruction) {
                for (Register register : instruction.getUsedReg()) {
                    if (register.type == Register.registerType.TEMPERARY) {
                        vertices.add(register);
                    }
                }
                for (Register register : instruction.getDefinedReg()) {
                    if (register.type == Register.registerType.TEMPERARY) {
                        vertices.add(register);
                    }
                }
            }
        }
        for (Register register : vertices) {
            interferenceGraph.put(register, new HashSet<>());
            neighbour.put(register, 0);
        }

        for (BasicBlock basicBlock : cfg.basicBlockList) {
            liveNow = new HashSet<>();
            liveNow.addAll(basicBlock.liveAnalysis.liveOut);
            for (int i = cfg.instruction.size() - 1; i >= 0; --i) {
                Instruction instruction = cfg.instruction.get(i);
                List<Register> definedReg = instruction.getDefinedReg();
                List<Register> usedReg = instruction.getUsedReg();
                if (definedReg != null) {
                    for (Register defined : definedReg) {
                        for (Register liveNowReg : liveNow) {
                            addEdge(liveNowReg, defined);
                        }
                    }
                }
                if (definedReg != null) {
                    for (Register defined : definedReg) {
                        liveNow.remove(defined);
                    }
                }
                if (usedReg != null) {
                    for (Register used : usedReg) {
                        liveNow.add(used);
                    }
                }
            }
            allocPhysicalReg(20);
        }
    }

    public void addEdge(Register u, Register v) {
        if (!(u.type == Register.registerType.TEMPERARY && v.type == Register.registerType.TEMPERARY)) {
            return;
        }
        // A vertice cannot be mapped to itself, otherwise colouring is impossible.
        if (u == v)
            return;

        if (!interferenceGraph.containsKey(u)) {
            interferenceGraph.put(u, new HashSet<>());
            vertices.add(u);
        }
        if (!interferenceGraph.containsKey(v)) {
            interferenceGraph.put(v, new HashSet<>());
            vertices.add(v);
        }
        interferenceGraph.get(u).add(v);
        interferenceGraph.get(v).add(u);
        neighbour.put(u, interferenceGraph.get(u).size());
        neighbour.put(v, interferenceGraph.get(v).size());
    }

    public void removeNode(Register node) {
        if (node.type != Register.registerType.TEMPERARY)
            return;
        for (Register v: interferenceGraph.get(node)) {
            if (!vertices.contains(v)) continue;
            neighbour.put(node, neighbour.get(node) - 1);
            neighbour.put(v, neighbour.get(v) - 1);
            if (neighbour.get(v) == 0) {
                vertices.remove(v);
            }
        }
        vertices.remove(node);
    }

    public void addNode(Register node) {
        if (node.type != Register.registerType.TEMPERARY)
            return;
        for (Register v: interferenceGraph.get(node)) {
            neighbour.put(node, neighbour.get(node) + 1);
            neighbour.put(v, neighbour.get(v) + 1);
            if (!vertices.contains(v)) {
                vertices.add(v);
            }
        }
        vertices.add(node);
    }

    public boolean colourNode(Register node) {
        if (node.type != Register.registerType.TEMPERARY)
            return false;
        for (MIPSRegister colour: physicalRegister) {
            boolean used = false;
            for (Register v: interferenceGraph.get(node)) {
                if (allocMapping.get(v) == colour) {
                    used = true;
                    break;
                }
            }
            if (!used) {
                allocMapping.put(node, colour);
                mipsRegisterInUse.add(colour);
                return true;
            }
        }
        return false;
    }

    public boolean allocPhysicalReg(int registerNum) {
        Stack<Register> stack = new Stack<>();
        while (!vertices.isEmpty()) {
            boolean degreeLTk = false;
            Set<Register> verticesBackUp = new HashSet<>();
            verticesBackUp.addAll(vertices);
            for (Register n: verticesBackUp) {
                if (!vertices.contains(n)) {
                    continue;
                }
                if (neighbour.get(n) <= registerNum) {
                    stack.push(n);
                    degreeLTk = true;
                    removeNode(n);
                }
            }
            if (!degreeLTk) {
                for (Register n: verticesBackUp) {
                    if (!vertices.contains(n)) {
                        continue;
                    }
                    stack.push(n);
                    removeNode(n);
                }
            }
        }
        boolean allocAll = true;
        while (!stack.isEmpty()) {
            Register node = stack.pop();
            if (!colourNode(node)) {
                allocAll = false;
                continue;
            }
            addNode(node);
        }
        return allocAll;
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
    public String neighbourToString() {
        String neighbourString = "neighbour:\n";
        for (Register u: neighbour.keySet()) {
            neighbourString = neighbourString + u.toString() + "has" + String.valueOf(neighbour.get(u)) + "neighbours\n";
        }
        return neighbourString;
    }

    public String verticesToString() {
        String ver = "vertices:\n";
        for (Register u: vertices) {
            ver = ver + u.toString() + " is in the graph.\n";
        }
        return ver;
    }

    public String registerAllocationToString() {
        String a = "allocMapping:\n";
        for (Register u: allocMapping.keySet()) {
            a = a + u.toString() + " is maped to " + allocMapping.get(u).toString() + "\n";
        }
        return a;
    }
}














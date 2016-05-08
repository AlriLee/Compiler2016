package Compiler.ControlFlowGraph;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.ControlFlowGraph.BasicBlock.BasicBlock;
import Compiler.ControlFlowGraph.Instruction.*;
import Compiler.Error.CompileError;
import Compiler.GlobalRegisterAllocator.GlobalRegisterAllocator;
import Compiler.GlobalRegisterAllocator.MIPSRegister;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.*;

/**
 * Created by Alri on 16/4/23.
 */
public class ControlFlowGraph {
    public List<Instruction> instruction;
    public List<BasicBlock> basicBlockList;
    public FunctionDecl function;
    public GlobalRegisterAllocator allocator;
    public Frame frame;

    public boolean isLeafFunction; // does it call other functions?

    public ControlFlowGraph(FunctionDecl f) {
        instruction = new ArrayList<>();
        basicBlockList = new ArrayList<>();
        function = f;
        allocator = new GlobalRegisterAllocator(this);
        frame = new Frame();
        isLeafFunction = true;
    }

    public void analyseFrame() {
        frame.size += 128;
        Set<Register> temporary = new HashSet<>();
        for (Instruction i : instruction) {
            for (Register used : i.getUsedReg()) {
                if (used.type == Register.registerType.TEMPERARY) {
                    temporary.add(used);
                }
            }
            for (Register defined : i.getDefinedReg()) {
                if (defined.type == Register.registerType.TEMPERARY) {
                    temporary.add(defined);
                }
            }
        }
        for (Register register : temporary) {
            frame.temperaryRegisterOffset.put(register, frame.size);
            frame.size += 4;
        }
        for (Operand operand : function.parameterOperand) {
            frame.parameterOffset.put((Register) operand, frame.size);
            frame.size += 4;
        }
    }

    public void buildBasicBlock() {
        List<Instruction> backup = instruction;
        instruction = new ArrayList<>();
        for (int i = 0; i < backup.size(); ++i) {
            instruction.add(backup.get(i));
            if (i + 1 < backup.size() && backup.get(i) instanceof LabelInstruction && backup.get(i + 1) instanceof LabelInstruction) {
                instruction.add(new JumpInstruction((LabelInstruction) backup.get(i + 1)));
            }
        }

        Instruction ins;
        boolean reachable = true;
        boolean hasEnd = true;
        for (int i = 0; i < instruction.size(); ++i) {
            ins = instruction.get(i);
            if (ins instanceof CallInstruction) { // if there is any callInstruction in this CFG, then the function of this CFG is a leafFunction
                isLeafFunction = false;
            }
            if (ins instanceof LabelInstruction) {
                reachable = true;
                if (!hasEnd) {
                    basicBlockList.get(basicBlockList.size() - 1).addInstruction(new JumpInstruction((LabelInstruction) ins));
                    hasEnd = true;
                }
                BasicBlock basicBlock = new BasicBlock((LabelInstruction) ins);
                basicBlockList.add(basicBlock);
                continue;
            } else if (!reachable) continue;
            basicBlockList.get(basicBlockList.size() - 1).addInstruction(ins);
            hasEnd = false;
            if (ins instanceof JumpInstruction || ins instanceof ConditionBranchInstruction) {
                reachable = false;
                hasEnd = true;
            }
        }

        for (int i = 0; i < basicBlockList.size(); ++i) {
            basicBlockList.get(i).analyseLiveness();
            basicBlockList.get(i).getSuccessor();
            //System.out.println(basicBlockList.get(i).livenessToString());
        }

        while (true) {
            boolean modified = false;

            for (BasicBlock block : basicBlockList) {
                block.liveAnalysis.liveIn = new HashSet<>();
                block.liveAnalysis.liveOut.forEach(block.liveAnalysis.liveIn::add);
                block.liveAnalysis.varKill.forEach(block.liveAnalysis.liveIn::remove);
                block.liveAnalysis.ueVar.forEach(block.liveAnalysis.liveIn::add);
            }

            for (BasicBlock block : basicBlockList) {
                Set<Register> liveOut = block.liveAnalysis.liveOut;
                block.liveAnalysis.liveOut = new HashSet<>();
                for (BasicBlock successor : block.successor) {
                    block.liveAnalysis.liveOut.addAll(successor.liveAnalysis.liveIn);
                }
                if (!block.liveAnalysis.liveOut.equals(liveOut)) {
                    modified = true;
                }
            }

            if (!modified) {
                break;
            }
        }

        /*for (int i = 0; i < basicBlockList.size(); ++i) {
            System.out.println(basicBlockList.get(i).livenessToString());
        }*/
    }

    public String basicBlockToString() {
        String basicBlockString = "";
        for (int i = 0; i < basicBlockList.size(); ++i) {
            basicBlockString += basicBlockList.get(i).toString();
        }
        return basicBlockString;
    }

    public class Frame {
        public Map<Register, Integer> parameterOffset, temperaryRegisterOffset;
        //public Map<MIPSRegister, Integer> physicalRegisterOffset;
        public int size;

        public Frame() {
            parameterOffset = new HashMap<>();
            temperaryRegisterOffset = new HashMap<>();
            //physicalRegisterOffset = new HashMap<>();
        }

        public int getOffset(Register r) {
            if (r.type == Register.registerType.PARAMETER) {
                return parameterOffset.get(r);
            } else if (r.type == Register.registerType.TEMPERARY) {
                return temperaryRegisterOffset.get(r);
            }
            throw new CompileError("Unable to get offset of register " + r.toString());
        }

        public int getOffset(MIPSRegister r) {
            switch (r.registerName) {
                case "$zero":
                    return 0;
                case "$at":
                    return 4;
                case "$v0":
                    return 8;
                case "$v1":
                    return 12;
                case "$a0":
                    return 16;
                case "$a1":
                    return 20;
                case "$a2":
                    return 24;
                case "$a3":
                    return 28;
                case "$t0":
                    return 32;
                case "$t1":
                    return 36;
                case "$t2":
                    return 40;
                case "$t3":
                    return 44;
                case "$t4":
                    return 48;
                case "$t5":
                    return 52;
                case "$t6":
                    return 56;
                case "$t7":
                    return 60;
                case "$s0":
                    return 64;
                case "$s1":
                    return 68;
                case "$s2":
                    return 72;
                case "$s3":
                    return 76;
                case "$s4":
                    return 80;
                case "$s5":
                    return 84;
                case "$s6":
                    return 88;
                case "$s7":
                    return 92;
                case "$t8":
                    return 96;
                case "$t9":
                    return 100;
                case "$k0":
                    return 104;
                case "$k1":
                    return 108;
                case "$gp":
                    return 112;
                case "$sp":
                    return 116;
                case "$ra":
                    return 120;
                case "$fp":
                    return 124;
            }
            throw new InternalError();
        }
    }
}

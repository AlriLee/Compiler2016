package Compiler.AST.Statement;

import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.JumpInstruction;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class BreakStatement implements Statement {
    public LoopStatement loop;

    public BreakStatement(LoopStatement l) {
        loop = l;
    }
    @Override
    public String toString(int d) {
        return indent(d) + "BreakStatement\n";
    }

    @Override
    public void emit(List<Instruction> instruction) {
        if (loop instanceof WhileLoop) instruction.add(new JumpInstruction(((WhileLoop) loop).whileLoopLabel));
        if (loop instanceof ForLoop) instruction.add(new JumpInstruction(((ForLoop) loop).forLoopLabel));
    }
}

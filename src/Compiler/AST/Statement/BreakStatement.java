package Compiler.AST.Statement;

import Compiler.ControlFlowGraph.Instruction.Instruction;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class BreakStatement implements Statement {
    @Override
    public String toString(int d) {
        return indent(d) + "BreakStatement\n";
    }

    @Override
    public void emit(List<Instruction> instruction) {

    }
}

package Compiler.AST.Statement;

import Compiler.AST.ASTNode;
import Compiler.ControlFlowGraph.Instruction.Instruction;

import java.util.List;

/**
 * Created by Alri on 16/4/3.
 */
public interface Statement extends ASTNode {
    void emit(List<Instruction> instruction);
}

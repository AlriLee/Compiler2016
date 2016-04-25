package Compiler.AST.Type;

import Compiler.AST.ASTNode;
import Compiler.AST.Symbol;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Operand.Operand;

import java.util.List;

/**
 * Created by Alri on 16/3/31.
 */
public interface Type extends ASTNode {
    boolean equal(Type rhs);

    long pointerSize();

    Operand alloc(List<Instruction> instructions);

    Type getMemberType(Symbol memberSymbol);
}

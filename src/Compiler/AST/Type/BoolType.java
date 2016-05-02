package Compiler.AST.Type;

import Compiler.AST.Symbol;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Operand;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class BoolType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "BoolType\n";
    }

    @Override
    public Type getMemberType(Symbol memberSymbol) {
        throw new CompileError("no member");
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof BoolType)
            return true;
        else return false;
    }

    @Override
    public long pointerSize() {
        return 4;
    }

    @Override
    public Operand alloc(List<Instruction> instructions) {
        throw new CompileError("Unable to new a boolType.");
    }
}

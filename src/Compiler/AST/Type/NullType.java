package Compiler.AST.Type;

import Compiler.AST.Symbol;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Operand;

import java.util.List;

import static Compiler.Tool.Tool.indent;
/**
 * Created by Alri on 16/4/6.
 */
public class NullType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "NullType\n";
    }

    @Override
    public Type getMemberType(Symbol memberSymbol) {
        return null;
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof NullType)
            return true;
        else return false;
    }

    @Override
    public long pointerSize() {
        throw new CompileError("Unable to get the pointerSize of a nullType.");
    }

    @Override
    public Operand alloc(List<Instruction> instructions) {
        throw new CompileError("Unable to alloc a nullType.");
    }
}

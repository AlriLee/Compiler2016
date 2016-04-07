package Compiler.AST.Type;

import Compiler.AST.Symbol;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class VoidType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "VoidType\n";
    }

    @Override
    public Type getMemberType(Symbol memberSymbol) {
        throw new CompileError("no member");
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof VoidType)
            return true;
        else return false;
    }
}

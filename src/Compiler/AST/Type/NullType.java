package Compiler.AST.Type;

import Compiler.AST.Symbol;

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
    public long size() {
        throw new Error();
    }
}

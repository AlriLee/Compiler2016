package Compiler.AST.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class IntType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "IntType\n";
    }

    public boolean equal(Type rhs) {
        if (rhs instanceof IntType)
            return true;
        else
            return false;
    }

    @Override
    public boolean isLvalue() {
        if (lvalue) return true;
        else return false;
    }
}

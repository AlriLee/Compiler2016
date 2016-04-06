package Compiler.AST.Type;

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
    public boolean equal(Type rhs) {
        if (rhs instanceof BoolType)
            return true;
        else return false;
    }

    @Override
    public boolean isLvalue() {
        if (lvalue) return true;
        else return false;
    }
}

package Compiler.AST.Type;

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
    public boolean equal(Type rhs) {
        if (rhs instanceof VoidType)
            return true;
        else return false;
    }
}

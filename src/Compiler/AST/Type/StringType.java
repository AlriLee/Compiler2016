package Compiler.AST.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class StringType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "StringType\n";
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof StringType)
            return true;
        else return false;
    }
}

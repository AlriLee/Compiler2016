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
}

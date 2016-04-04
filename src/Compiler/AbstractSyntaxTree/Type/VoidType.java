package Compiler.AbstractSyntaxTree.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class VoidType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "VoidType\n";
    }
}

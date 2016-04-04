package Compiler.AbstractSyntaxTree.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class StringType extends BasicType {
    @Override
    public String toString(int d) {
        return indent(d) + "StringType\n";
    }
}

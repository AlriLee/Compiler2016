package Compiler.AST.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class IntType implements Type {
    @Override
    public String toString(int d) {
        return indent(d) + "IntType\n";
    }
}

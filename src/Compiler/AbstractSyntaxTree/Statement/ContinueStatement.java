package Compiler.AbstractSyntaxTree.Statement;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ContinueStatement implements Statement {
    @Override
    public String toString(int d) {
        return indent(d) + "ContinueStatement\n";
    }
}

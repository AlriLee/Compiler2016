package Compiler.AbstractSyntaxTree.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class NullConst extends Expression {
    @Override
    public String toString(int d) {
        return indent(d) + "NullConst\n";
    }
}

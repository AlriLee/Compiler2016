package Compiler.AbstractSyntaxTree.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class IntConst extends Expression {
    public int intValue;

    public IntConst(int i) {
        intValue = i;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "IntConst\n";
    }
}

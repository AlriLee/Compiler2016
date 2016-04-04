package Compiler.AST.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class BoolConst extends Expression {
    public boolean value;

    public BoolConst(boolean v) {
        value = v;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "BoolConst" + value + '\n';
    }
}

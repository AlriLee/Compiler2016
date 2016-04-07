package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.BoolType;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class BoolConst extends Expression {
    public boolean value;

    public BoolConst(boolean v) {
        value = v;
        type = new BoolType();
    }

    @Override
    public String toString(int d) {
        return indent(d) + "BoolConst" + value + '\n';
    }
}

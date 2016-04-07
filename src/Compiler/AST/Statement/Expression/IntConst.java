package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.IntType;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class IntConst extends Expression {
    public long intValue;

    public IntConst(long i) {
        intValue = i;
        type = new IntType();
        ((IntType) type).lvalue = false;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "IntConst\n";
    }
}

package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.NullType;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class NullConst extends Expression {
    public NullConst() {
        type = new NullType();
    }
    @Override
    public String toString(int d) {
        return indent(d) + "NullConst\n";
    }
}

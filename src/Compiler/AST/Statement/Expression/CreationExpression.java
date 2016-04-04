package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.Type;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class CreationExpression extends Expression {
    public Type type;

    public CreationExpression(Type t) {
        type = t;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "CreationExpression\n";
        string += type.toString(d + 1);
        return string;
    }
}

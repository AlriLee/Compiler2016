package Compiler.AST.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ArrayAccess extends Expression {
    public Expression arrayBody;
    public Expression arrayIndex;

    public ArrayAccess() {
        arrayBody = null;
        arrayIndex = null;
    }

    public ArrayAccess(Expression ab, Expression ai) {
        arrayBody = ab;
        arrayIndex = ai;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ArrayAccess\n";
        if (arrayBody != null) string += arrayBody.toString(d + 1);
        if (arrayIndex != null) string += arrayIndex.toString(d + 1);
        return string;
    }
}

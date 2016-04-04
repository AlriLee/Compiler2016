package Compiler.AbstractSyntaxTree.Type;

import Compiler.AbstractSyntaxTree.Statement.Expression.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ArrayType implements Type {
    public Type baseType;
    public Expression arraySize;

    public ArrayType() {
        baseType = null;
        arraySize = null;
    }

    public ArrayType(Type bt) {
        baseType = bt;
        arraySize = null;
    }

    public ArrayType(Type bt, Expression as) {
        baseType = bt;
        arraySize = as;
    }

    public void changeSize(Expression as) {
        arraySize = as;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ArrayType\n";
        if (baseType != null) string += baseType.toString(d + 1);
        if (arraySize != null) string += arraySize.toString(d + 1);
        return string;
    }
}

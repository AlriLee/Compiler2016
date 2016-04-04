package Compiler.AbstractSyntaxTree.Type;

import Compiler.AbstractSyntaxTree.Symbol;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ClassType extends BasicType {
    public Symbol className;

    public ClassType(Symbol className) {
        this.className = className;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ClassType\n" + indent(d + 1);
        if (className != null)
            string += className.toString();
        else
            string += "null\n";
        return string;
    }
}

package Compiler.AbstractSyntaxTree.Statement.Expression;

import Compiler.AbstractSyntaxTree.Symbol;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class ClassAccess extends Expression {
    public Expression className;
    public Symbol attribute;

    public ClassAccess(Expression cn, Symbol at) {
        className = cn;
        attribute = at;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "ClassAccess\n" + className.toString(d + 1) + attribute.toString(d + 1);
    }
}

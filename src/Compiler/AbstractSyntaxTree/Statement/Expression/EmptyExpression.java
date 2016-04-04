package Compiler.AbstractSyntaxTree.Statement.Expression;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class EmptyExpression extends Expression {
    @Override
    public String toString(int d) {
        return indent(d) + "EmptyExpression\n";
    }
}

package Compiler.AST.Statement.Expression;

import Compiler.AST.Symbol;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class Identifier extends Expression {
    public Symbol symbol;

    public Identifier(Symbol s) {
        symbol = s;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "Identifier\n" + symbol.toString(d + 1);
    }
}

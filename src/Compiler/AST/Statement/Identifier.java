package Compiler.AST.Statement;

import Compiler.AST.Symbol;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class Identifier implements Statement {
    public Symbol symbol;

    public Identifier() {
        symbol = null;
    }

    public Identifier(Symbol s) {
        symbol = s;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "Identifier\n";
        string += symbol.toString(d + 1);
        return string;
    }
}

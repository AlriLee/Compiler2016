package Compiler.AST;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class Symbol implements ASTNode {
    private static java.util.Dictionary dict = new java.util.Hashtable();
    public String name;

    private Symbol(String n) {
        name = n;
    }

    public static Symbol getSymbol(String n) {
        String unique = n.intern();
        Symbol symbol = (Symbol) dict.get(unique);
        if (symbol == null) {
            symbol = new Symbol(unique);
            dict.put(unique, symbol);
        }
        return symbol;
    }

    public String toString() {
        return name;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + name;
        return string;
    }
}

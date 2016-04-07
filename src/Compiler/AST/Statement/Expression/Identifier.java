package Compiler.AST.Statement.Expression;

import Compiler.AST.Symbol;
import Compiler.Environment.SymbolTable;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class Identifier extends Expression {
    public Symbol symbol;

    public Identifier(Symbol s) {
        symbol = s;
        if (SymbolTable.getType(s) == null) {
            throw new CompileError("no symbol named \"" + symbol.name + "\"");
        }
        type = SymbolTable.getType(s);
        lvalue = true;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "Identifier\n" + symbol.toString(d + 1);
    }
}

package Compiler.Listener;

import Compiler.AST.Parser.MagBaseListener;
import Compiler.AST.Parser.MagParser;
import Compiler.AST.Symbol;
import Compiler.AST.Type.ClassType;
import Compiler.Environment.SymbolTable;

/**
 * Created by Alri on 16/4/4.
 */
public class ClassDeclListener extends MagBaseListener {
    @Override
    public void exitClassDeclaration(MagParser.ClassDeclarationContext ctx) {
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());

        SymbolTable.addSymbol(symbol, new ClassType(symbol));
    }
}

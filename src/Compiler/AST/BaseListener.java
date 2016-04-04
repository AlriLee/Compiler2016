package Compiler.AST;

import Compiler.AST.Parser.MagBaseListener;
import org.antlr.v4.runtime.ParserRuleContext;

public class BaseListener extends MagBaseListener {
    public static int currentRow, currentColumn;

    @Override
    public void exitEveryRule(ParserRuleContext ctx) {
        currentRow = ctx.getStart().getLine();
        currentColumn = ctx.getStart().getCharPositionInLine();
    }
}

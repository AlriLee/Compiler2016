package Compiler.AST.Statement;

import Compiler.AST.StatementList;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class CompoundStatement implements Statement {
    public StatementList statementBlock;

    public CompoundStatement() {
        statementBlock = null;
    }

    public CompoundStatement(StatementList sb) {
        statementBlock = sb;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "CompoundStatement\n";
        if (statementBlock != null) {
            string += statementBlock.toString(d + 1);
        }
        return string;
    }
}

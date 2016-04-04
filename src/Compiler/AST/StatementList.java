package Compiler.AST;

import Compiler.AST.Statement.Statement;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class StatementList implements ASTNode {
    public Statement statement;
    public StatementList statementList;

    public StatementList(Statement s) {
        statement = s;
        statementList = null;
    }

    public StatementList(Statement s, StatementList sl) {
        statement = s;
        statementList = sl;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "StatementList\n";
        string += statement.toString(d + 1);
        if (statementList != null) {
            string += statementList.toString(d + 1);
        }
        return string;
    }
}

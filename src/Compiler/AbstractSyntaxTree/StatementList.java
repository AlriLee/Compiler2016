package Compiler.AbstractSyntaxTree;

import Compiler.AbstractSyntaxTree.Statement.Statement;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class StatementList implements ASTNode {
    public Statement statement;
    public StatementList statementList;

    StatementList(Statement s) {
        statement = s;
        statementList = null;
    }

    StatementList(Statement s, StatementList sl) {
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

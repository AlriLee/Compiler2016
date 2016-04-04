package Compiler.AST;

import Compiler.AST.Decl.VarDecl;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class VarDeclList implements ASTNode {
    public VarDecl varDecl;
    public VarDeclList varDeclList;

    public VarDeclList(VarDecl varDecl) {
        this.varDecl = varDecl;
        this.varDeclList = null;
    }

    public VarDeclList(VarDecl varDecl, VarDeclList varDeclList) {
        this.varDecl = varDecl;
        this.varDeclList = varDeclList;
    }

    public String toString(int d) {
        String string = indent(d) + "VarDeclList" + "\n" + varDecl.toString(d + 1);
        if (varDeclList != null)
            string += varDeclList.toString(d + 1);
        return string;
    }
}

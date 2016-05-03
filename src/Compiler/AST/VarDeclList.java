package Compiler.AST;

import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Type.NullType;
import Compiler.AST.Type.Type;
import Compiler.Error.CompileError;
import javafx.util.Pair;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class VarDeclList implements ASTNode {
    public VarDecl varDecl;
    public VarDeclList varDeclList;
    public long varDeclSize;

    public VarDeclList(VarDecl varDecl) {
        this.varDecl = varDecl;
        this.varDeclList = null;
        varDeclSize = 1;
    }

    public VarDeclList(VarDecl varDecl, VarDeclList varDeclList) {
        this.varDecl = varDecl;
        this.varDeclList = varDeclList;
        //if (varDeclList == null) System.out.println("The varDeclList is null.\n" + varDecl.toString(0));
        if (varDeclList != null)
            varDeclSize = varDeclList.varDeclSize + 1;
        else varDeclSize = 1;
    }

    public static VarDeclList getVarDeclList(List<Pair<String, Type>> parameters) {
        VarDeclList varDeclList = null;
        for (int i = parameters.size() - 1; i >= 0; --i) {
            Pair<String, Type> parameter = parameters.get(i);
            Symbol symbol = Symbol.getSymbol(parameter.getKey());
            varDeclList = new VarDeclList(new VarDecl(parameter.getValue(), symbol), varDeclList);
        }
        return varDeclList;
    }

    public void checkDuplicated() {
        Symbol symbol = varDecl.name;
        if (varDeclList != null && varDeclList.hasVariable(symbol)) {
            throw new CompileError("duplicated");
        }
        if (varDeclList != null) {
            varDeclList.checkDuplicated();
        }
    }

    public boolean hasVariable(Symbol variableSymbol) {
        if (varDecl.name.equals(variableSymbol)) return true;
        if (varDeclList != null) return varDeclList.hasVariable(variableSymbol);
        return false;
    }

    public Type getVariableType(Symbol variableSymbol) {
        if (varDecl.name.equals(variableSymbol)) return varDecl.type;
        if (varDeclList != null) return varDeclList.getVariableType(variableSymbol);
        return new NullType();
    }

    public long getVarDeclOffSet(Symbol variableSymbol) {
        long vdi = 0;
        for (VarDeclList vdl = this; vdl != null; vdl = vdl.varDeclList) {
            //System.out.println(vdl.varDecl.name.toString());
            if (vdl.varDecl.name.equals(variableSymbol)) {
                vdi = vdl.varDeclSize;
                break;
            }
        }
        return (this.varDeclSize - vdi) * 4;
    }

    public String toString(int d) {
        String string = indent(d) + "VarDeclList" + "\n" + varDecl.toString(d + 1);
        if (varDeclList != null)
            string += varDeclList.toString(d + 1);
        return string;
    }

}

package Compiler.AST.Decl;

import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ClassDecl implements Declaration {
    public Symbol className;
    public VarDeclList fields;

    public ClassDecl(Symbol cn) {
        className = cn;
        fields = null;
    }

    public ClassDecl(Symbol cn, VarDeclList f) {
        className = cn;
        fields = f;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ClassDecl\n";
        if (className != null) string += className.toString(d + 1);
        if (fields != null) {
            string += fields.toString(d + 1);
        }
        return string;
    }

    public void emit() {

    }
}

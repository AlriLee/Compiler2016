package Compiler.AST.Decl;

import Compiler.AST.Statement.CompoundStatement;
import Compiler.AST.Symbol;
import Compiler.AST.Type.Type;
import Compiler.AST.VarDeclList;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class FunctionDecl implements Type, Declaration {
    public Type returnType;
    public Symbol functionName;
    public VarDeclList parameters;
    public CompoundStatement functionBody;

    /*
        public FunctionDecl() {
            returnType = null;
            functionName = null;
            parameters = null;
            functionBody = null;
        }
    */
    public FunctionDecl(Type rt, Symbol fn, VarDeclList pm, CompoundStatement fb) {
        returnType = rt;
        functionName = fn;
        parameters = pm;
        functionBody = fb;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "FunctionDecl\n";
        string += returnType.toString(d + 1);
        string += functionName.toString(d + 1);
        if (parameters != null) {
            string += parameters.toString(d + 1);
        }
        if (functionBody != null) string += functionBody.toString(d + 1);
        return string;
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof FunctionDecl)
            return true;
        else return false;
    }
}

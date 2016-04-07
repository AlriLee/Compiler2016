package Compiler.AST.Statement.Expression;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.ExpressionList;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class FunctionCall extends Expression {
    public Expression functionBody;
    public ExpressionList arguments;

    public FunctionCall(Expression fb) {
        functionBody = fb;
        arguments = null;
        if (!(functionBody.type instanceof FunctionDecl)) {
            throw new CompileError("function expected");
        }
        FunctionDecl functionDecl = (FunctionDecl) functionBody.type;
        type = functionDecl.returnType;
    }

    public FunctionCall(Expression fb, ExpressionList arg) {
        functionBody = fb;
        arguments = arg;
        if (!(functionBody.type instanceof FunctionDecl)) {
            throw new CompileError("function expected");
        }
        FunctionDecl functionDecl = (FunctionDecl) functionBody.type;
        type = functionDecl.returnType;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "FunctionCall\n";
        string += functionBody.toString(d + 1);
        if (arguments != null) {
            string += arguments.toString(d + 1);
        }
        return string;
    }
}

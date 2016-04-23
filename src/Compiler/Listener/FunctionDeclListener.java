package Compiler.Listener;

import Compiler.AST.ASTNode;
import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Parser.MagBaseListener;
import Compiler.AST.Parser.MagParser;
import Compiler.AST.Symbol;
import Compiler.AST.Type.*;
import Compiler.AST.VarDeclList;
import Compiler.Environment.SymbolTable;
import Compiler.Error.CompileError;
import org.antlr.v4.runtime.tree.ParseTreeProperty;

/**
 * Created by Alri on 16/4/4.
 */
public class FunctionDeclListener extends MagBaseListener {
    public static ParseTreeProperty<ASTNode> stack = new ParseTreeProperty<>();

    //@Override
    //public void exitClassMemDeclList_(MagParser.ClassMemDeclList_Context ctx) {
    //    stack.push(new VarDeclList(new VarDecl((Type)stack.pop(), Symbol.getSymbol(ctx.ID().getText()))));
    //}

    @Override
    public void exitClassDeclaration(MagParser.ClassDeclarationContext ctx) {
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
        ClassType classType = (ClassType) SymbolTable.symbolStackHashMap.get(symbol).peek().type;
        classType.classMember = (VarDeclList)stack.get(ctx.classMemberDeclarationList());
        classType.classMember.checkDuplicated();
    }
    @Override
    public void exitClassMemDeclList_(MagParser.ClassMemDeclList_Context ctx) {
        stack.put(ctx, new VarDeclList(
                new VarDecl(
                        (Type) stack.get(ctx.typeArray()),
                        Symbol.getSymbol(ctx.ID().getText())
                )
        ));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitClassMemDeclList_list(MagParser.ClassMemDeclList_listContext ctx) {
        VarDeclList list = (VarDeclList) stack.get(ctx.classMemberDeclarationList());
        stack.put(ctx, new VarDeclList(
                new VarDecl(
                        (Type) stack.get(ctx.typeArray()),
                        Symbol.getSymbol(ctx.ID().getText())
                ),
                list
        ));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }
/*
    @Override
    public void exitVarDecl_(MagParser.VarDecl_Context ctx) {
        stack.push(new VarDeclList(new VarDecl((Type) stack.pop(), Symbol.getSymbol(ctx.ID().getText()))));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitVarDecl_init(MagParser.VarDecl_initContext ctx) {
        //Expression init = (Expression) stack.pop();
        Type type = (Type) stack.pop();
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
        //stack.push(new VarDecl(type, symbol, init));
        stack.push(new VarDeclList(new VarDecl(type, symbol)));
        //System.out.println("AddSymbol" + symbol.toString(0));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }
*/
    @Override
    public void exitType(MagParser.TypeContext ctx) {
        if (ctx.getText().equals("int")) {
            stack.put(ctx, new IntType());
        } else if (ctx.getText().equals("string")) {
            stack.put(ctx, new StringType());
        } else if (ctx.getText().equals("bool")) {
            stack.put(ctx, new BoolType());
        } else {
            Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
            if (SymbolTable.getType(symbol) == null) {
                throw new CompileError("Undefined class type.");
            }
            stack.put(ctx, SymbolTable.getType(symbol).type);
        }
    }

    @Override
    public void exitTypeArray_type(MagParser.TypeArray_typeContext ctx) {
        stack.put(ctx, stack.get(ctx.type()));
    }

    @Override
    public void exitTypeArray_dim(MagParser.TypeArray_dimContext ctx) {
        stack.put(ctx, new ArrayType((Type)stack.get(ctx.typeArray())));
    }

    @Override
    public void exitFunctionDecl_returnType(MagParser.FunctionDecl_returnTypeContext ctx) {
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
        VarDeclList varDeclList = null;
        if (ctx.parameterList() != null) {
            varDeclList = (VarDeclList) stack.get(ctx.parameterList());
            varDeclList.checkDuplicated();
        }
        Type type = (Type)stack.get(ctx.typeArray());
        FunctionDecl functionDecl = new FunctionDecl(type, symbol, varDeclList, null);
        SymbolTable.addSymbol(symbol, functionDecl);
    }

    @Override
    public void exitFunctionDecl_void(MagParser.FunctionDecl_voidContext ctx) {
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
        VarDeclList varDeclList = null;
        if (ctx.parameterList() != null) {
            varDeclList = (VarDeclList)stack.get(ctx.parameterList());
            varDeclList.checkDuplicated();
        }
        FunctionDecl functionDecl = new FunctionDecl(new VoidType(), symbol, varDeclList, null);
        SymbolTable.addSymbol(symbol, functionDecl);
    }

    @Override
    public void exitParameter_(MagParser.Parameter_Context ctx) {
        stack.put(ctx, new VarDeclList(
                new VarDecl(
                        (Type) stack.get(ctx.typeArray()),
                        Symbol.getSymbol(ctx.ID().getText())
                )
        ));
    }

    @Override
    public void exitParameter_list(MagParser.Parameter_listContext ctx) {
        VarDeclList varDeclList = (VarDeclList)stack.get(ctx.parameterList());
        stack.put(ctx, new VarDeclList(
                new VarDecl(
                        (Type) stack.get(ctx.typeArray()),
                        Symbol.getSymbol(ctx.ID().getText())
                ),
                varDeclList
        ));
    }
}

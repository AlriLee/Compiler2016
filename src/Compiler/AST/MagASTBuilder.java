package Compiler.AST;

import Compiler.AST.Decl.ClassDecl;
import Compiler.AST.Decl.Declaration;
import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Parser.MagParser;
import Compiler.AST.Statement.*;
import Compiler.AST.Statement.Expression.*;
import Compiler.AST.Statement.Expression.Identifier;
import Compiler.AST.Type.*;
import Compiler.Environment.SymbolTable;
import org.antlr.v4.runtime.tree.ParseTree;

import java.util.LinkedList;
import java.util.Stack;

/**
 * Created by Alri on 16/4/3.
 */
public class MagASTBuilder extends BaseListener {
    public MagParser parser;
    public Stack<ASTNode> stack = new Stack<ASTNode>();

    public MagASTBuilder(MagParser p) {
        parser = p;
    }

    @Override
    public void exitProgram(MagParser.ProgramContext ctx) {
        LinkedList<Declaration> decls = new LinkedList<Declaration>();
        while (!stack.isEmpty()) {
            decls.add((Declaration) stack.pop());
        }
        Prog prog = new Prog();
        while (!decls.isEmpty()) {
            prog.declarations.add(decls.getLast());
            decls.removeLast();
        }
        stack.push(prog);
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitClassDeclaration(MagParser.ClassDeclarationContext ctx) {
        if (ctx.classMemberDeclarationList() != null) {
            stack.push(new ClassDecl(Symbol.getSymbol(ctx.ID().getText()), (VarDeclList) stack.pop()));
        } else {
            stack.push(new ClassDecl(Symbol.getSymbol(ctx.ID().getText())));
        }
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitClassMemDeclList_(MagParser.ClassMemDeclList_Context ctx) {
        stack.push(new VarDeclList(
                new VarDecl((Type) stack.pop(), Symbol.getSymbol(ctx.ID().getText()))
        ));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitClassMemDeclList_list(MagParser.ClassMemDeclList_listContext ctx) {
        VarDeclList list = (VarDeclList) stack.pop();
        stack.push(new VarDeclList(new VarDecl((Type) stack.pop(), Symbol.getSymbol(ctx.ID().getText())), list));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitTypeArray_dim(MagParser.TypeArray_dimContext ctx) {
        stack.push(new ArrayType((Type) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitType(MagParser.TypeContext ctx) {
        if (ctx.getText().equals("int")) {
            stack.push(new IntType());
        } else if (ctx.getText().equals("string")) {
            stack.push(new StringType());
        } else if (ctx.getText().equals("bool")) {
            stack.push(new BoolType());
        } else {
            stack.push(new ClassType(Symbol.getSymbol(ctx.ID().getText())));
        }
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitBlockStatement(MagParser.BlockStatementContext ctx) {
        if (ctx.statementList() == null) {
            stack.push(new CompoundStatement());
        } else {
            stack.push(new CompoundStatement((StatementList) stack.pop()));
        }
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitStatementList_stmt(MagParser.StatementList_stmtContext ctx) {
        stack.push(new StatementList((Statement) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitStatementList_list(MagParser.StatementList_listContext ctx) {
        StatementList statementList = (StatementList) stack.pop();
        stack.push(new StatementList((Statement) stack.pop(), statementList));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitExpressionStatement(MagParser.ExpressionStatementContext ctx) {
        if (ctx.expression() == null) {
            stack.push(new EmptyExpression());
        }
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitAssignment_assign(MagParser.Assignment_assignContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.ASSIGN, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitLogicalOr_or(MagParser.LogicalOr_orContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.LOGICAL_OR, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitLogicalAnd_and(MagParser.LogicalAnd_andContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.LOGICAL_AND, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitBitwiseOr_or(MagParser.BitwiseOr_orContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.OR, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitBitwiseXor_xor(MagParser.BitwiseXor_xorContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.XOR, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitBitwiseAnd_and(MagParser.BitwiseAnd_andContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.AND, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitEquality_equal(MagParser.Equality_equalContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.EQ, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitEquality_notEqual(MagParser.Equality_notEqualContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.NEQ, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitRelational_less(MagParser.Relational_lessContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.LT, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitRelational_greater(MagParser.Relational_greaterContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.GT, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitRelational_leq(MagParser.Relational_leqContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.LEQ, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitRelational_geq(MagParser.Relational_geqContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.GEQ, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitShift_leftShift(MagParser.Shift_leftShiftContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.SHL, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitShift_rightShift(MagParser.Shift_rightShiftContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.SHR, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitAddSub_add(MagParser.AddSub_addContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.ADD, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitAddSub_sub(MagParser.AddSub_subContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.SUB, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitMulDivRem_mul(MagParser.MulDivRem_mulContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.MUL, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitMulDivRem_div(MagParser.MulDivRem_divContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.DIV, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitMulDivRem_rem(MagParser.MulDivRem_remContext ctx) {
        Expression rhs = (Expression) stack.pop();
        Expression lhs = (Expression) stack.pop();
        stack.push(new BinaryExpression(lhs, BinaryOp.MOD, rhs));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitCreation_dim(MagParser.Creation_dimContext ctx) {
        stack.push(new CreationExpression((Type) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitDimension_(MagParser.Dimension_Context ctx) {
        Stack<Expression> reorderStack = new Stack<Expression>();
        while (stack.peek() instanceof Expression) {
            reorderStack.push((Expression) stack.pop());
        }
        Type type = (Type) stack.pop();
        while (!reorderStack.empty()) {
            stack.push((Expression) reorderStack.pop());
        }
        stack.push(new ArrayType(type, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitDimension_dim(MagParser.Dimension_dimContext ctx) {
        Type type = (Type) stack.pop();
        stack.push(new ArrayType(type, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitCreation_para(MagParser.Creation_paraContext ctx) {
        // No constructor function currently.
    }

    @Override
    public void exitPrefix_positive(MagParser.Prefix_positiveContext ctx) {
        stack.push(new UnaryExpression(UnaryOp.PLUS, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPrefix_negative(MagParser.Prefix_negativeContext ctx) {
        stack.push(new UnaryExpression(UnaryOp.MINUS, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPrefix_not(MagParser.Prefix_notContext ctx) {
        stack.push(new UnaryExpression(UnaryOp.NOT, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPrefix_tilde(MagParser.Prefix_tildeContext ctx) {
        stack.push(new UnaryExpression(UnaryOp.TILDE, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPrefix_plusPlus(MagParser.Prefix_plusPlusContext ctx) {
        stack.push(new UnaryExpression(UnaryOp.INC, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPrefix_minusMinus(MagParser.Prefix_minusMinusContext ctx) {
        stack.push(new UnaryExpression(UnaryOp.DEC, (Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPostfix_expression(MagParser.Postfix_expressionContext ctx) {
        Expression expression = (Expression) stack.pop();
        stack.push(new ArrayAccess((Expression) stack.pop(), expression));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPostfix_argument(MagParser.Postfix_argumentContext ctx) {
        if (ctx.argumentExpressionList() != null) {
            ExpressionList argumentList = (ExpressionList) stack.pop();
            stack.push(new FunctionCall((Expression) stack.pop(), argumentList));
        } else {
            stack.push(new FunctionCall((Expression) stack.pop()));
        }
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPostfix_id(MagParser.Postfix_idContext ctx) {
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
        stack.push(new ClassAccess((Expression) stack.pop(), symbol));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPostfix_incre(MagParser.Postfix_increContext ctx) {
        stack.push(new PostSelfIncrement((Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPostfix_decre(MagParser.Postfix_decreContext ctx) {
        stack.push(new PostSelfDecrement((Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitPrimary_id(MagParser.Primary_idContext ctx) {
        stack.push(new Identifier(Symbol.getSymbol(ctx.ID().getText())));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitConstant_null(MagParser.Constant_nullContext ctx) {
        stack.push(new NullConst());
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitConstant_int(MagParser.Constant_intContext ctx) {
        stack.push(new IntConst(Integer.valueOf(ctx.getText()).intValue()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitConstant_string(MagParser.Constant_stringContext ctx) {
        stack.push(new StringConst(ctx.getText()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitLogic_true(MagParser.Logic_trueContext ctx) {
        stack.push(new BoolConst(true));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitLogic_false(MagParser.Logic_falseContext ctx) {
        stack.push(new BoolConst(false));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitArgument_expression(MagParser.Argument_expressionContext ctx) {
        stack.push(new ExpressionList((Expression) stack.pop()));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitArgument_expressionList(MagParser.Argument_expressionListContext ctx) {
        ExpressionList expressionList = (ExpressionList) stack.pop();
        stack.push(new ExpressionList((Expression) stack.pop(), expressionList));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitSelection_if(MagParser.Selection_ifContext ctx) {
        Statement consequence = (Statement) stack.pop();
        stack.push(new IfStatement((Expression) stack.pop(), consequence));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitSelection_ifElse(MagParser.Selection_ifElseContext ctx) {
        Statement alternative = (Statement) stack.pop();
        Statement consequence = (Statement) stack.pop();
        stack.push(new IfStatement((Expression) stack.pop(), consequence, alternative));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitWhileStatement(MagParser.WhileStatementContext ctx) {
        Statement body = (Statement) stack.pop();
        stack.push(new WhileLoop((Expression) stack.pop(), body));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitForStatement(MagParser.ForStatementContext ctx) {
        Statement forStatement = (Statement) stack.pop();

        MagParser.ExpressionContext[] expressionContexts = new MagParser.ExpressionContext[3];

        int total = 0;
        for (ParseTree parseTree : ctx.children) {
            if (parseTree.getText().equals(";")) {
                total++;
            }
            if (parseTree instanceof MagParser.ExpressionContext) {
                expressionContexts[total] = (MagParser.ExpressionContext) parseTree;
            }
        }

        Expression init = null, cond = null, incr = null;
        if (expressionContexts[2] != null) {
            incr = (Expression) stack.pop();
//            System.out.println("2: " + expressionContexts[2].getText());
        }
        if (expressionContexts[1] != null) {
            cond = (Expression) stack.pop();
//            System.out.println("1: " + expressionContexts[1].getText());
        }
        if (expressionContexts[0] != null) {
            init = (Expression) stack.pop();
//            System.out.println("0: " + expressionContexts[0].getText());
        }
        stack.push(new ForLoop(init, cond, incr, forStatement));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitReturnStatement(MagParser.ReturnStatementContext ctx) {
        if (ctx.expression() != null) {
            stack.push(new ReturnStatement((Expression) stack.pop()));
        } else {
            stack.push(new ReturnStatement());
        }
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitBreakStatement(MagParser.BreakStatementContext ctx) {
        stack.push(new BreakStatement());
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitContinueStatement(MagParser.ContinueStatementContext ctx) {
        stack.push(new ContinueStatement());
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitVarDecl_(MagParser.VarDecl_Context ctx) {
        stack.push(new VarDecl((Type) stack.pop(), Symbol.getSymbol(ctx.ID().getText())));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitVarDecl_init(MagParser.VarDecl_initContext ctx) {
        Expression init = (Expression) stack.pop();
        Type type = (Type) stack.pop();
        Symbol symbol = Symbol.getSymbol(ctx.ID().getText());
        stack.push(new VarDecl(type, symbol, init));
        SymbolTable.addSymbol(symbol, type);
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void enterFunctionDecl_returnType(MagParser.FunctionDecl_returnTypeContext ctx) {
        SymbolTable.beginScope();
    }

    @Override
    public void exitFunctionDecl_returnType(MagParser.FunctionDecl_returnTypeContext ctx) {
        CompoundStatement block = (CompoundStatement) stack.pop();
        Symbol functionName = Symbol.getSymbol(ctx.ID().getText());
        VarDeclList paraList;
        if (ctx.parameterList() != null)
            paraList = (VarDeclList) stack.pop();
        else paraList = null;
        stack.push(new FunctionDecl((Type) stack.pop(), functionName, paraList, block));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
        SymbolTable.endScope();
    }

    @Override
    public void exitFunctionDecl_void(MagParser.FunctionDecl_voidContext ctx) {
        CompoundStatement block = (CompoundStatement) stack.pop();
        Symbol functionName = Symbol.getSymbol(ctx.ID().getText());
        VarDeclList paraList;
        if (ctx.parameterList() != null)
            paraList = (VarDeclList) stack.pop();
        else paraList = null;
        stack.push(new FunctionDecl(new VoidType(), functionName, paraList, block));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitParameter_(MagParser.Parameter_Context ctx) {
        stack.push(new VarDeclList(new VarDecl((Type) stack.pop(), Symbol.getSymbol(ctx.ID().getText()))));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }

    @Override
    public void exitParameter_list(MagParser.Parameter_listContext ctx) {
        VarDeclList parameterList = (VarDeclList) stack.pop();
        stack.push(new VarDeclList(new VarDecl((Type) stack.pop(), Symbol.getSymbol(ctx.ID().getText())), parameterList));
//        stack.peek().info = new Info(ctx.getStart().getLine(), ctx.getStart().getCharPositionInLine());
    }
}


















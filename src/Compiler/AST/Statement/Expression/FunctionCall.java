package Compiler.AST.Statement.Expression;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.ExpressionList;
import Compiler.AST.VarDeclList;
import Compiler.ControlFlowGraph.Instruction.CallInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.ArrayList;
import java.util.List;

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

        if (functionBody instanceof ClassAccess) {
            arguments = new ExpressionList(((ClassAccess) functionBody).className, arguments);
        }

        FunctionDecl function = (FunctionDecl) functionBody.type;
        type = function.returnType;

        VarDeclList list1 = function.parameters;
        ExpressionList list2 = arguments;
        while (list1 != null && list2 != null) {
            //System.out.println(list1.varDecl.type.toString());
            //System.out.println(list2.expression.type.toString());
            if (!list1.varDecl.type.equal(list2.expression.type)) {
                throw new CompileError("parameter type error");
            }
            list1 = list1.varDeclList;
            list2 = list2.expressionList;
        }
        if (list1 != null || list2 != null) {
            throw new CompileError("parameter error");
        }
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

    @Override
    public void emit(List<Instruction> instructions) {
        List<Operand> parameters = new ArrayList<>();
        functionBody.emit(instructions);
        for (ExpressionList arg = arguments; arg != null; arg = arg.expressionList) {
            arg.expression.emit(instructions);
            arg.expression.load(instructions);
            //System.out.println(arg.expression.toString(0));
            parameters.add(arg.expression.operand);
        }
        operand = new Register();
        instructions.add(new CallInstruction((FunctionDecl) functionBody.type, parameters, operand));
        // operand of functionCall
    }
}

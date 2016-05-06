package Compiler.AST.Decl;

import Compiler.AST.Statement.CompoundStatement;
import Compiler.AST.Symbol;
import Compiler.AST.Type.IntType;
import Compiler.AST.Type.Type;
import Compiler.AST.VarDeclList;
import Compiler.ControlFlowGraph.ControlFlowGraph;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.LabelInstruction;
import Compiler.Environment.SymbolTable;
import Compiler.Error.CompileError;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.ArrayList;
import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class FunctionDecl implements Type, Declaration {
    public Type returnType;
    public Symbol functionName;
    public VarDeclList parameters;
    public CompoundStatement functionBody;

    public ControlFlowGraph cfg;
    public LabelInstruction beginOfFunctionDeclLabel = new LabelInstruction("BeginOfFunctionDecl");
    public LabelInstruction endOfFunctionDeclLabel = new LabelInstruction("EndOfFunctionDecl");
    public List<Operand> parameterOperand;

    public FunctionDecl(Type rt, Symbol fn, VarDeclList pm, CompoundStatement fb) {
        returnType = rt;
        functionName = fn;
        parameters = pm;
        functionBody = fb;
        if (functionName.name.equals("main")) {
            if (!(returnType instanceof IntType)) {
                throw new CompileError("returnType error in int main()");
            }
        }
        parameterOperand = new ArrayList<>();
    }

    @Override
    public Type getMemberType(Symbol memberSymbol) {
        return null;
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

    public void emit() {
        cfg = new ControlFlowGraph(this);
        cfg.instruction.add(beginOfFunctionDeclLabel);
        if (functionName.name.equals("main")) {
            for (Declaration declaration : SymbolTable.program.declarations) {
                if (declaration instanceof VarDecl) {
                    ((VarDecl) declaration).entry.register.type = Register.registerType.GLOBAL;
                    ((VarDecl) declaration).emit(cfg.instruction);
                }
            }
        }
        for (Operand operand : parameterOperand) {
            ((Register) operand).type = Register.registerType.PARAMETER;
        }
        functionBody.emit(cfg.instruction);
        cfg.instruction.add(endOfFunctionDeclLabel);
    }

    @Override
    public long pointerSize() {
        return 0;
    }

    @Override
    public Operand alloc(List<Instruction> instructions) {
        return null;
    }
}

package Compiler.AST.Type;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Operand;

import java.util.HashMap;
import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class IntType extends BasicType {
    private static HashMap<Symbol, Type> members;
    public boolean lvalue;

    public static void initialize() {
        members = new HashMap<>();
        Symbol thisSymbol = Symbol.getSymbol("this");
        VarDeclList varDeclList = new VarDeclList(new VarDecl(new StringType(), thisSymbol));

        // string substring(int left, int right)
        Symbol substringSymbol = Symbol.getSymbol("substring");
        members.put(substringSymbol, new FunctionDecl(
                        new StringType(),
                        substringSymbol,
                        varDeclList,
                        null
                )
        );

        // int ord(int pos);
        Symbol ordSymbol = Symbol.getSymbol("ord");
        members.put(ordSymbol, new FunctionDecl(
                        new StringType(),
                        ordSymbol,
                        varDeclList,
                        null
                )
        );
    }

    @Override
    public String toString(int d) {
        return indent(d) + "IntType\n";
    }

    @Override
    public Type getMemberType(Symbol memberSymbol) {
        if (members.containsKey(memberSymbol)) {
            return members.get(memberSymbol);
        }
        throw new CompileError("no member");
    }

    public boolean equal(Type rhs) {
        if (rhs instanceof IntType)
            return true;
        else
            return false;
    }

    @Override
    public long pointerSize() {
        return 4;
    }

    @Override
    public Operand alloc(List<Instruction> instructions) {
        throw new CompileError("Unable to new a intType.");
    }
}

package Compiler.AST.Statement.Expression;

import Compiler.AST.Symbol;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Environment.SymbolTable;
import Compiler.Environment.SymbolTableEntry;
import Compiler.Error.CompileError;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class Identifier extends Expression {
    public SymbolTableEntry entry;

    public Identifier(Symbol s) {
        if (SymbolTable.getType(s) == null) {
            throw new CompileError("no symbol named \"" + s.name + "\"");
        }
        entry = SymbolTable.getType(s);
        //System.out.println("In Identifier " + entry.name);
        type = entry.type;
        lvalue = true;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "Identifier: " + entry.name.toString();
    }

    @Override
    public void emit(List<Instruction> instructions) {
        operand = entry.register;
    }
}

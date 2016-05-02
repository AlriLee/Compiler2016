package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.IntType;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Operand.Immediate;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class IntConst extends Expression {
    public long intValue;

    public IntConst(long i) {
        intValue = i;
        type = new IntType();
        ((IntType) type).lvalue = false;
    }

    @Override
    public String toString(int d) {
        return indent(d) + "IntConst\n";
    }

    @Override
    public void emit(List<Instruction> instructions) {
        operand = new Immediate(intValue);
    }

    @Override
    public void load(List<Instruction> instructions) {

    }
}

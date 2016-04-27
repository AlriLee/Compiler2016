package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.BoolType;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Operand.Immediate;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class BoolConst extends Expression {
    public boolean value;

    public BoolConst(boolean v) {
        value = v;
        type = new BoolType();
    }

    @Override
    public String toString(int d) {
        return indent(d) + "BoolConst" + value + '\n';
    }

    @Override
    public void emit(List<Instruction> instructions) {
        operand = new Immediate(value ? 1 : 0);
    }
}

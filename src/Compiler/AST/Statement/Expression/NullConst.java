package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.NullType;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Operand.Immediate;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class NullConst extends Expression {
    public NullConst() {
        type = new NullType();
    }
    @Override
    public String toString(int d) {
        return indent(d) + "NullConst\n";
    }

    @Override
    public void emit(List<Instruction> instructions) {
        operand = new Immediate(0);
    }

    @Override
    public void load(List<Instruction> instructions) {

    }
}

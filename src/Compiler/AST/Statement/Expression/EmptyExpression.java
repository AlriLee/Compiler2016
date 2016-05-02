package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.NullType;
import Compiler.ControlFlowGraph.Instruction.Instruction;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class EmptyExpression extends Expression {
    public EmptyExpression() {
        type = new NullType();
    }
    @Override
    public String toString(int d) {
        return indent(d) + "EmptyExpression\n";
    }

    @Override
    public void emit(List<Instruction> instructions) {

    }

    @Override
    public void load(List<Instruction> instructions) {

    }
}

package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.Type;
import Compiler.ControlFlowGraph.Instruction.Instruction;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class CreationExpression extends Expression {
    public CreationExpression(Type t) {
        type = t;
    }

    @Override
    public void emit(List<Instruction> instructions) {

    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "CreationExpression\n";
        string += type.toString(d + 1);
        return string;
    }
}

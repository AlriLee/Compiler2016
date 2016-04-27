package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.StringType;
import Compiler.ControlFlowGraph.Instruction.Instruction;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class StringConst extends Expression {
    public String stringValue;

    public StringConst(String sv) {
        stringValue = sv;
        type = new StringType();
    }

    @Override
    public void emit(List<Instruction> instructions) {
        // TODO
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "StringConst\n";
        if (stringValue != null)
            string += stringValue.toString();
        else
            string += (indent(d + 1) + "null\n");
        return string;
    }
}

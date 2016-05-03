package Compiler.AST.Statement;

import Compiler.AST.Statement.Expression.Expression;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.ReturnInstruction;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ReturnStatement implements Statement {
    public Expression expr;

    public ReturnStatement(Expression e) {
        expr = e;
    }

    public ReturnStatement() {
        expr = null;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ReturnStatement\n";
        if (expr != null) {
            string += expr.toString(d + 1);
        }
        return string;
    }

    @Override
    public void emit(List<Instruction> instruction) {
        expr.emit(instruction);
        expr.load(instruction);
        instruction.add(new ReturnInstruction(expr.operand));
    }
}

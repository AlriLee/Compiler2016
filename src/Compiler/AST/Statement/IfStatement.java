package Compiler.AST.Statement;

import Compiler.AST.Statement.Expression.Expression;
import Compiler.AST.Type.BoolType;
import Compiler.ControlFlowGraph.Instruction.ConditionBranchInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.LabelInstruction;
import Compiler.Error.CompileError;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/30.
 */
public class IfStatement implements Statement {
    public Expression condition;
    public Statement consequence;
    public Statement alternative;

    public IfStatement(Expression cond, Statement conse) {
        condition = cond;
        consequence = conse;
        alternative = null;
        if (!(condition.type instanceof BoolType)) {
            throw new CompileError("type error");
        }
    }

    public IfStatement(Expression cond, Statement conse, Statement alter) {
        condition = cond;
        consequence = conse;
        alternative = alter;
        if (!(condition.type instanceof BoolType)) {
            throw new CompileError("type error");
        }
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "IfStatement\n" + condition.toString(d + 1) + consequence.toString(d + 1);
        if (alternative != null) {
            string += alternative.toString(d + 1);
        }
        return string;
    }

    @Override
    public void emit(List<Instruction> instruction) {
        LabelInstruction consequenceLabel = new LabelInstruction("consequence");
        LabelInstruction alternativeLabel = new LabelInstruction("alternative");
        condition.emit(instruction);
        instruction.add(new ConditionBranchInstruction(condition.register, consequenceLabel, alternativeLabel));
        instruction.add(consequenceLabel);
        consequence.emit(instruction);
        instruction.add(alternativeLabel);
        alternative.emit(instruction);
    }
}

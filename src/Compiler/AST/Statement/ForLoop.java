package Compiler.AST.Statement;

import Compiler.AST.Statement.Expression.Expression;
import Compiler.AST.Type.BoolType;
import Compiler.ControlFlowGraph.Instruction.ConditionBranchInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.JumpInstruction;
import Compiler.ControlFlowGraph.Instruction.LabelInstruction;
import Compiler.Error.CompileError;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ForLoop implements LoopStatement {
    public Expression initExpression;
    public Expression conditionExpression;
    public Expression incrementExpression;
    public Statement forStatement;
    public LabelInstruction forLoopLabel = new LabelInstruction("ForLoop");
    public LabelInstruction continueLoopLabel = new LabelInstruction("continueFor");

    public ForLoop() {
        initExpression = null;
        conditionExpression = null;
        incrementExpression = null;
        forStatement = null;
    }

    public ForLoop FulfillForLoop(Expression init, Expression cond, Expression incre, Statement state) {
        if (cond != null && !(cond.type instanceof BoolType)) {
            throw new CompileError("A BoolType expression is expected in ForLoop.");
        }
        initExpression = init;
        conditionExpression = cond;
        incrementExpression = incre;
        forStatement = state;
        return this;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ForLoop\n";
        if (initExpression != null) {
            string += initExpression.toString(d + 1);
        }
        if (conditionExpression != null) {
            string += conditionExpression.toString(d + 1);
        }
        if (incrementExpression != null) {
            string += incrementExpression.toString(d + 1);
        }
        string += forStatement.toString(d + 1);

        return string;
    }

    @Override
    public void emit(List<Instruction> instruction) {
        LabelInstruction bodyLabel = new LabelInstruction("ForBody");
        LabelInstruction outLabel = new LabelInstruction("OutOfFor");
        if (initExpression != null)
            initExpression.emit(instruction);
        instruction.add(forLoopLabel);
        if (conditionExpression != null) {
            conditionExpression.emit(instruction);
            instruction.add(new ConditionBranchInstruction(conditionExpression.operand, bodyLabel, outLabel));
        }
        instruction.add(bodyLabel);
        if (forStatement != null)
            forStatement.emit(instruction);
        instruction.add(continueLoopLabel);
        if (incrementExpression != null)
            incrementExpression.emit(instruction);
        instruction.add(new JumpInstruction(forLoopLabel));
        instruction.add(outLabel);
    }
}

package Compiler.ControlFlowGraph.Instruction;

import Compiler.AST.Statement.Expression.UnaryOp;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class UnaryInstruction extends Instruction {
    UnaryOp op;
    Register dest;
    Operand src;

    public UnaryInstruction(UnaryOp o, Register d, Operand s) {
        op = o;
        dest = d;
        src = s;
    }

    @Override
    public String toString() {
        //INC, DEC, PLUS, MINUS, TILDE, NOT
        String opOutput = null;
        switch (op) {
            case MINUS: {
                opOutput = "neg";
                break;
            }
            case NOT: {
                opOutput = "not";
                break;
            }
        }
        return dest.toString() + " = " + opOutput + " " + src.toString();
    }

    @Override
    public List<Operand> getUsedOp() {
        return Collections.singletonList(src);
    }

    @Override
    public List<Operand> getDefinedOp() {
        return Collections.singletonList(dest);
    }
}

package Compiler.ControlFlowGraph.Instruction;

import Compiler.AST.Statement.Expression.BinaryOp;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class BinaryInstruction extends Instruction {
    public BinaryOp op;
    public Register dest;
    public Operand lhs, rhs;

    public BinaryInstruction(BinaryOp o, Register d, Operand l, Operand r) {
        op = o;
        dest = d;
        lhs = l;
        rhs = r;
    }

    @Override
    public String toString() {
        //return op + " " + dest + ", " + lhs + ", " + rhs;
        //ASSIGN,

        //LOGICAL_OR, LOGICAL_AND, OR, XOR, AND, EQ, NEQ, LT, GT, LEQ, GEQ, SHL, SHR, ADD, SUB,
        //        MUL, DIV, MOD
        String opOutput = null;
        switch (op) {
            // Arithmetic Instruction:
            case ADD: {
                opOutput = "add";
                break;
            }
            case SUB: {
                opOutput = "sub";
                break;
            }
            case MUL: {
                opOutput = "mul";
                break;
            }
            case DIV: {
                opOutput = "div";
                break;
            }
            case MOD: {
                opOutput = "rem";
                break;
            }
            // Bitwise Instruction:
            case SHL: {
                opOutput = "shl";
                break;
            }
            case SHR: {
                opOutput = "shr";
                break;
            }
            case AND:
            case LOGICAL_AND: {
                opOutput = "and";
                break;
            }
            case XOR: {
                opOutput = "xor";
                break;
            }
            case OR:
            case LOGICAL_OR: {
                opOutput = "or";
                break;
            }
            //Condition Set Instruction:
            case LT: {
                opOutput = "slt";
                break;
            }
            case GT: {
                opOutput = "sgt";
                break;
            }
            case LEQ: {
                opOutput = "sle";
                break;
            }
            case GEQ: {
                opOutput = "sge";
                break;
            }
            case EQ: {
                opOutput = "seq";
                break;
            }
            case NEQ: {
                opOutput = "sne";
                break;
            }
        }
        return dest + " = " + opOutput + " " + lhs + " " + rhs;
    }

    @Override
    public List<Operand> getUsedOp() {
        List<Operand> operands = new ArrayList<>();
        operands.add(lhs);
        operands.add(rhs);
        return operands;
    }

    @Override
    public List<Operand> getDefinedOp() {
        return Collections.singletonList(dest);
    }
}

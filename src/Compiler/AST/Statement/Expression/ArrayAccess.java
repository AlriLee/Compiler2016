package Compiler.AST.Statement.Expression;

import Compiler.AST.Type.ArrayType;
import Compiler.AST.Type.IntType;
import Compiler.ControlFlowGraph.Instruction.BinaryInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Immediate;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ArrayAccess extends Expression {
    public Expression arrayBody;
    public Expression arrayIndex;

    public ArrayAccess(Expression ab, Expression ai) {
        if (!(ab.type instanceof ArrayType)) {
            throw new CompileError("Access non-array object." + ab.type.toString(0));
        }
        if (!(ai.type instanceof IntType)) {
            throw new CompileError("Non-int type" + ai.type.toString(0) + "used as array index.");
        }
        type = ((ArrayType) ab.type).baseType;
        arrayBody = ab;
        arrayIndex = ai;
        lvalue = ab.lvalue;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ArrayAccess\n";
        if (arrayBody != null) string += arrayBody.toString(d + 1);
        if (arrayIndex != null) string += arrayIndex.toString(d + 1);
        return string;
    }

    @Override
    public void emit(List<Instruction> instructions) {
        arrayBody.emit(instructions);
        arrayIndex.emit(instructions);
        long size = arrayBody.type.pointerSize();
        Register offSet = new Register();
        instructions.add(new BinaryInstruction(BinaryOp.MUL, offSet, arrayIndex.operand, new Immediate(size)));
        instructions.add(new BinaryInstruction(BinaryOp.ADD, (Register) operand, arrayBody.operand, offSet));
    }
}

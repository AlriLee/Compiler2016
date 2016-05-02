package Compiler.AST.Type;

import Compiler.AST.Statement.Expression.BinaryOp;
import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;
import Compiler.ControlFlowGraph.Instruction.AllocInstruction;
import Compiler.ControlFlowGraph.Instruction.BinaryInstruction;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Error.CompileError;
import Compiler.Operand.Immediate;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ClassType extends BasicType {
    public Symbol className;
    public VarDeclList classMember;

    public ClassType(Symbol cn) {
        className = cn;
        classMember = null;
    }

    public boolean hasMember(Symbol memberSymbol) {
        return classMember.hasVariable(memberSymbol);
    }

    public Type getMemberType(Symbol memberSymbol) {
        if (hasMember(memberSymbol)) {
            return classMember.getVariableType(memberSymbol);
        }
        throw new CompileError("no member");
    }

    public long getMemberOffSet(Symbol memberSymbol) {
        return classMember.getVarDeclOffSet(memberSymbol);
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ClassType\n" + indent(d + 1);
        if (className != null)
            string += className.toString();
        else
            string += "null\n";
        return string;
    }

    @Override
    public boolean equal(Type rhs) {
        return rhs == this;
    }

    @Override
    public long pointerSize() {
        return 4;
    }

    @Override
    public Operand alloc(List<Instruction> instructions) {
        //return new Immediate(classMember.varDeclSize);
        Operand allocAddress = new Register();
        Operand allocSize = new Register();
        instructions.add(new BinaryInstruction(BinaryOp.MUL, (Register) allocSize, new Immediate(classMember.varDeclSize), new Immediate(4)));
        instructions.add(new AllocInstruction((Register) allocAddress, (Register) allocSize));
        return allocAddress;
    }
}

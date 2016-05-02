package Compiler.AST.Statement.Expression;

import Compiler.AST.Statement.Statement;
import Compiler.AST.Type.Type;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.Operand.Operand;

import java.util.List;

/**
 * Created by Alri on 16/3/31.
 */
public abstract class Expression implements Statement {
    public Type type;
    public boolean lvalue = false;
    public Operand operand;

    public abstract void emit(List<Instruction> instructions);

    /*public void load(List<Instruction> instructions) {
        if (operand instanceof Address) {
            Address srcAddr = (Address) operand;
            operand = new Register();
            instructions.add(new LoadInstruction((Register) operand, srcAddr));
        }
    }*/
    public abstract void load(List<Instruction> instructions);
}

package Compiler.AST.Statement.Expression;

import Compiler.AST.Symbol;
import Compiler.AST.Type.ClassType;
import Compiler.AST.Type.Type;
import Compiler.ControlFlowGraph.Instruction.Instruction;
import Compiler.ControlFlowGraph.Instruction.LoadInstruction;
import Compiler.Operand.Address;
import Compiler.Operand.Immediate;
import Compiler.Operand.Register;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class ClassAccess extends Expression {
    public Expression className;
    public Symbol attribute;

    public ClassAccess(Expression cn, Symbol at) {
        className = cn;
        attribute = at;

        Type classType =  className.type;
        type = classType.getMemberType(attribute);
        lvalue = className.lvalue;
        //List<VarDecl> memList = ((ClassType)SymbolTable.hashMapStack.peek().get(symbol)).classMember;
        /*for (int i = 0; i < memList.size(); ++i) {
            Type t = ((VarDecl)memList.get(i)).type;
            Symbol s = ((VarDecl)memList.get(i)).name;
            if (s.equals(attribute)) {
                className = cn;
                attribute = at;
                type = t;
                return;
            }
        }*/
    }

    @Override
    public String toString(int d) {
        return indent(d) + "ClassAccess\n" + className.toString(d + 1) + attribute.toString(d + 1);
    }

    @Override
    public void emit(List<Instruction> instructions) {
        className.emit(instructions);
        Type classType = className.type;
        long attributeOffSet = ((ClassType) classType).getMemberOffSet(attribute);
        //Register offSet = new Register();
        //instructions.add(new LoadInstruction(offSet, new Immediate(attributeOffSet)));
        operand = new Address((Register) className.operand, new Immediate(attributeOffSet), type.size());
    }

    @Override
    public void load(List<Instruction> instructions) {
        instructions.add(new LoadInstruction((Register) operand, (Address) operand));
    }
}

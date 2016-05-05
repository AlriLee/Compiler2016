package Compiler.ControlFlowGraph.Instruction;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Type.VoidType;
import Compiler.Operand.Operand;

import java.util.Collections;
import java.util.List;

/**
 * Created by Alri on 16/4/23.
 */
public class CallInstruction extends Instruction {
    public FunctionDecl function;
    public List<Operand> actualParameters;
    public Operand returnOperand;

    public CallInstruction(FunctionDecl f, List<Operand> ap, Operand ro) {
        function = f;
        actualParameters = ap;
        returnOperand = ro;
    }

    @Override
    public String toString() {
        String callInstruction = null;
        if (!(function.returnType instanceof VoidType))
            callInstruction = returnOperand.toString() + " = ";
        callInstruction += "call " + function.functionName.name;
        for (int i = 0; i < actualParameters.size(); ++i) {
            callInstruction += " ";
            callInstruction += actualParameters.get(i).toString();
        }
        return callInstruction;
    }

    @Override
    public List<Operand> getUsedOp() {
        return actualParameters;
    }

    @Override
    public List<Operand> getDefinedOp() {
        return Collections.singletonList(returnOperand);
    }
}

package Compiler.AST.Type;

import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;
import Compiler.Error.CompileError;

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
    public long size() {
        return 4;
        //return classMember.varDeclSize;
    }
}

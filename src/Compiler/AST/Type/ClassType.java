package Compiler.AST.Type;

import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;

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
        return classMember.getVariableType(memberSymbol);
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
        if (rhs instanceof ClassType)
            return true;
        else return false;
    }
}
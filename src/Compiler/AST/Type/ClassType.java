package Compiler.AST.Type;

import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Symbol;

import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ClassType extends BasicType {
    public Symbol className;
    public List<VarDecl> classMember;

    public ClassType(Symbol cn) {
        className = cn;
        classMember = null;
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
}

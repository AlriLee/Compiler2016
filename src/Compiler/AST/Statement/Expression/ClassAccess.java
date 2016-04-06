package Compiler.AST.Statement.Expression;

import Compiler.AST.Symbol;
import Compiler.AST.Type.ClassType;
import Compiler.Environment.SymbolTable;
import Compiler.Error.CompileError;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/3.
 */
public class ClassAccess extends Expression {
    public Expression className;
    public Symbol attribute;

    public ClassAccess(Expression cn, Symbol at) {
        if (!(cn.type instanceof ClassType)) {
            throw new CompileError("Non-class type accessed." + cn.type.toString());
        }
        Symbol symbol = ((ClassType) (cn.type)).className;

        // Is this necessary?
        if (!(SymbolTable.hashMapStack.peek().containsKey(symbol))) {
            throw new CompileError("No such class exits.");
        }
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
        }
        throw new CompileError("Class " + symbol.toString() + "does not contain member named " + attribute.toString());
        */
    }

    @Override
    public String toString(int d) {
        return indent(d) + "ClassAccess\n" + className.toString(d + 1) + attribute.toString(d + 1);
    }
}

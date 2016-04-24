package Compiler.AST.Type;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Statement.Expression.Expression;
import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;
import Compiler.Error.CompileError;

import java.util.HashMap;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/3/31.
 */
public class ArrayType implements Type {
    private static HashMap<Symbol, Type> members;
    public Type baseType;
    public Expression arraySize;

    public ArrayType(Type bt) {
        baseType = bt;
        arraySize = null;
    }

    public ArrayType(Type bt, Expression as) {
        baseType = bt;
        arraySize = as;
    }

    public static void initialize() {
        members = new HashMap<>();
        Symbol thisSymbol = Symbol.getSymbol("this");
        VarDeclList varDeclList = new VarDeclList(new VarDecl(new StringType(), thisSymbol));

        // int size()
        Symbol sizeSymbol = Symbol.getSymbol("size");
        members.put(sizeSymbol, new FunctionDecl(
                new IntType(),
                sizeSymbol,
                varDeclList,
                null
            )
        );
    }

    @Override
    public long size() {
        return 4;
    }

    public void changeSize(Expression as) {
        arraySize = as;
    }

    @Override
    public Type getMemberType(Symbol memberSymbol) {
        if (members.containsKey(memberSymbol)) {
            return members.get(memberSymbol);
        }
        throw new CompileError("no member");
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "ArrayType\n";
        if (baseType != null) string += baseType.toString(d + 1);
        if (arraySize != null) string += arraySize.toString(d + 1);
        return string;
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof ArrayType)
            return baseType.equal(((ArrayType) rhs).baseType);
        else
            return false;
    }
}

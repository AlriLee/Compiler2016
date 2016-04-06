package Compiler.Environment;

import Compiler.AST.Symbol;
import Compiler.AST.Type.IntType;
import Compiler.AST.Type.StringType;
import Compiler.AST.Type.Type;
import Compiler.AST.Type.VoidType;
import Compiler.Error.CompileError;

import java.util.HashMap;
import java.util.Stack;

/**
 * Created by Alri on 16/4/4.
 */
public class SymbolTable {
    public static HashMap<Symbol, Stack<Type>> symbolStackHashMap = new HashMap<Symbol, Stack<Type>>();
    public static Stack<HashMap<Symbol, Type>> hashMapStack = new Stack<HashMap<Symbol, Type>>();

    static {
        beginScope(); // Initialize the symbolTable to allow global declarations.

        //Add built-in functions to the outside-most scope.

        // void print(string str);
        Symbol printMethodSymbol = Symbol.getSymbol("print");
        Type printMethodType = new VoidType();
        addSymbol(printMethodSymbol, printMethodType);

        //void println(string str);
        Symbol printlnMethodSymbol = Symbol.getSymbol("println");
        Type printlnMethodType = new VoidType();
        addSymbol(printlnMethodSymbol, printlnMethodType);

        //string getString();
        Symbol getStringMethodSymbol = Symbol.getSymbol("getSymbol");
        Type getStringMethodType = new StringType();
        addSymbol(getStringMethodSymbol, getStringMethodType);

        //int getInt();
        Symbol getIntSymbol = Symbol.getSymbol("getInt");
        Type getIntType = new IntType();
        addSymbol(getIntSymbol, getIntType);

        //string toString(int i);
        Symbol toStringSymbol = Symbol.getSymbol("toString");
        Type toStringType = new StringType();
        addSymbol(toStringSymbol, toStringType);
    }

    public static void addSymbol(Symbol symbol, Type type) {
        if (hashMapStack.peek().containsKey(symbol)) {
            System.out.println(hashMapStack.peek().get(symbol));
            throw new CompileError("Symbol name conflict in the same scope." + symbol.toString(0));
        }
        hashMapStack.peek().put(symbol, type);
        if (!symbolStackHashMap.containsKey(symbol)) {
            symbolStackHashMap.put(symbol, new Stack<Type>());
        }
        symbolStackHashMap.get(symbol).push(type);
    }

    public static Type getType(Symbol symbol) {
        if (!symbolStackHashMap.containsKey(symbol) || symbolStackHashMap.get(symbol).empty()) {
            return null;
        }
        return symbolStackHashMap.get(symbol).peek();
    }

    public static void beginScope() {
        hashMapStack.push(new HashMap<Symbol, Type>());
    }

    public static void endScope() {
        for (Symbol key : hashMapStack.peek().keySet()) {
            symbolStackHashMap.get(key).pop();
        }
        hashMapStack.pop();
    }
}

package Compiler.Environment;

import Compiler.AST.Symbol;
import Compiler.AST.Type.Type;
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
        beginScope();
    }

    public static void addSymbol(Symbol symbol, Type type) {
        if (hashMapStack.peek().containsKey(symbol)) {
            throw new CompileError("Symbol name conflict in the same scope.");
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

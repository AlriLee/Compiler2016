package Compiler.Environment;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Symbol;
import Compiler.AST.Type.IntType;
import Compiler.AST.Type.StringType;
import Compiler.AST.Type.Type;
import Compiler.AST.Type.VoidType;
import Compiler.AST.VarDeclList;
import Compiler.Error.CompileError;
import Compiler.Listener.FunctionDeclListener;
import Compiler.Listener.MagASTBuilder;
import org.antlr.v4.runtime.tree.ParseTreeProperty;

import java.util.HashMap;
import java.util.Stack;

/**
 * Created by Alri on 16/4/4.
 */
public class SymbolTable {
    public static HashMap<Symbol, Stack<Type>> symbolStackHashMap;
    public static Stack<HashMap<Symbol, Type>> hashMapStack;

    public static void initilize() {
        MagASTBuilder.stack = new Stack<>();
        FunctionDeclListener.stack = new ParseTreeProperty<>();

        symbolStackHashMap = new HashMap<Symbol, Stack<Type>>();
        hashMapStack = new Stack<HashMap<Symbol, Type>>();

        beginScope(); // Initialize the symbolTable to allow global declarations.

        //Add built-in functions to the outside-most scope.

        // void print(string str);
        Symbol printMethodSymbol = Symbol.getSymbol("print");
        addSymbol(printMethodSymbol, new FunctionDecl(
                        new VoidType(),
                        printMethodSymbol,
                        new VarDeclList(new VarDecl(new IntType(), Symbol.getSymbol("str"))),
                        null
                )
        );

        //void println(string str);
        Symbol printlnMethodSymbol = Symbol.getSymbol("println");
        addSymbol(printlnMethodSymbol, new FunctionDecl(
                        new VoidType(),
                        printlnMethodSymbol,
                        new VarDeclList(new VarDecl(new IntType(), Symbol.getSymbol("str"))),
                        null
                )
        );

        //string getString();
        Symbol getStringMethodSymbol = Symbol.getSymbol("getSymbol");
        addSymbol(getStringMethodSymbol, new FunctionDecl(
                        new StringType(),
                        getStringMethodSymbol,
                        null,
                        null
                )
        );

        //int getInt();
        Symbol getIntSymbol = Symbol.getSymbol("getInt");
        addSymbol(getIntSymbol, new FunctionDecl(
                        new IntType(),
                        getIntSymbol,
                        null,
                        null
                )
        );

        //string toString(int i);
        Symbol toStringSymbol = Symbol.getSymbol("toString");
        addSymbol(toStringSymbol, new FunctionDecl(
                        new StringType(),
                        toStringSymbol,
                        new VarDeclList(new VarDecl(new IntType(), Symbol.getSymbol("i"))),
                        null
                )
        );
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

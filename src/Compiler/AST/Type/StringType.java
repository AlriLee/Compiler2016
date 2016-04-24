package Compiler.AST.Type;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Symbol;
import Compiler.AST.VarDeclList;
import Compiler.Error.CompileError;
import javafx.util.Pair;

import java.util.ArrayList;
import java.util.HashMap;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class StringType extends BasicType {
    private static HashMap<Symbol, Type> members;

    public static void initialize() {
        members = new HashMap<>();
        Symbol thisSymbol = Symbol.getSymbol("this");
        VarDeclList varDeclList = new VarDeclList(new VarDecl(new StringType(), thisSymbol));

        // int length()
        Symbol lengthSymbol = Symbol.getSymbol("length");
        members.put(lengthSymbol, new FunctionDecl(
                new IntType(),
                lengthSymbol,
                varDeclList,
                null
            )
        );

        // int parseInt();
        Symbol parseIntSymbol = Symbol.getSymbol("parseInt");
        members.put(parseIntSymbol, new FunctionDecl(
                new IntType(),
                parseIntSymbol,
                varDeclList,
                null
            )
        );

        Symbol subStringSymbol = Symbol.getSymbol("substring");
        members.put(subStringSymbol, new FunctionDecl(
                        new StringType(),
                        subStringSymbol,
                        VarDeclList.getVarDeclList(new ArrayList<Pair<String, Type>>(){{
                            add(new Pair<>("this", new StringType()));
                            add(new Pair<>("left", new IntType()));
                            add(new Pair<>("right", new IntType()));
                        }}),
                        null
                )
        );

        Symbol ordSymbol = Symbol.getSymbol("ord");
        members.put(ordSymbol, new FunctionDecl(
                        new IntType(),
                        ordSymbol,
                        VarDeclList.getVarDeclList(new ArrayList<Pair<String, Type>>(){{
                            add(new Pair<>("this", new StringType()));
                            add(new Pair<>("pos", new IntType()));
                        }}),
                        null
                )
        );
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
        return indent(d) + "StringType\n";
    }

    @Override
    public boolean equal(Type rhs) {
        if (rhs instanceof StringType)
            return true;
        else return false;
    }

    @Override
    public long size() {
        return 0;
    }
}

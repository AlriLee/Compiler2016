package Compiler;

import Compiler.AST.Parser.MagLexer;
import Compiler.AST.Parser.MagParser;
import Compiler.Environment.SymbolTable;
import Compiler.Error.CompileError;
import Compiler.Listener.ClassDeclListener;
import Compiler.Listener.ErrorListener;
import Compiler.Listener.FunctionDeclListener;
import Compiler.Listener.MagASTBuilder;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

public class Main {
    public static void main(String[] args) {
        try {
            new Main().compile(args);
        } catch (Exception e) {
            e.printStackTrace();
        } catch (CompileError e) {
            System.out.println(e.getMessage());
            System.exit(1);
        }
    }

    public void compile(String[] args) throws Exception {
        SymbolTable.initilize();

        ANTLRInputStream input = new ANTLRInputStream(System.in);
        MagLexer lexer = new MagLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        MagParser parser = new MagParser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(new ErrorListener());

        ParseTree tree = parser.program(); // calc is the starting rule
        ParseTreeWalker walker = new ParseTreeWalker();
        walker.walk(new ClassDeclListener(), tree);
        walker.walk(new FunctionDeclListener(), tree);
        walker.walk(new MagASTBuilder(), tree);
    }
}

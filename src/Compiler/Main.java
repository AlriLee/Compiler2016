package Compiler;

import Compiler.AST.Decl.Declaration;
import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Parser.MagLexer;
import Compiler.AST.Parser.MagParser;
import Compiler.AST.Prog;
import Compiler.Environment.SymbolTable;
import Compiler.Error.CompileError;
import Compiler.GlobalRegisterAllocator.GlobalRegisterAllocator;
import Compiler.Listener.ClassDeclListener;
import Compiler.Listener.ErrorListener;
import Compiler.Listener.FunctionDeclListener;
import Compiler.Listener.MagASTBuilder;
import Compiler.Operand.Register;
import Compiler.Translator.MIPSTranslator;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;

public class Main {
    public static void main(String[] args) {
        try {
            new Main().compile(System.in, System.out);
        } catch (Exception e) {
            e.printStackTrace();
        } catch (CompileError e) {
            System.out.println(e.getMessage());
            System.exit(1);
        }
    }

    public void compile(InputStream file, OutputStream output) throws Exception {
        SymbolTable.initilize();

        ANTLRInputStream input = new ANTLRInputStream(file);
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

        Register.registers = 0;

        SymbolTable.program = (Prog) MagASTBuilder.stack.peek();
        SymbolTable.program.emit();
        new MIPSTranslator(new PrintStream(output)).translate();
    }
}

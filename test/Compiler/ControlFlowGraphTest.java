package Compiler;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Parser.MagLexer;
import Compiler.AST.Parser.MagParser;
import Compiler.AST.Prog;
import Compiler.Environment.SymbolTable;
import Compiler.Listener.ClassDeclListener;
import Compiler.Listener.ErrorListener;
import Compiler.Listener.FunctionDeclListener;
import Compiler.Listener.MagASTBuilder;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;

@RunWith(Parameterized.class)
public class ControlFlowGraphTest {
    private String filename;

    public ControlFlowGraphTest(String filename) {
        this.filename = filename;
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data() {
        Collection<Object[]> params = new ArrayList<>();
        for (File f : new File("testcase/cfg/").listFiles()) {
            if (f.isFile() && f.getName().endsWith(".mx")) {
                params.add(new Object[]{"testcase/cfg/" + f.getName()});
            }
        }
        return params;
    }

    @Test
    public void testPass() throws IOException {
        System.out.println(filename);

        SymbolTable.initilize();

        InputStream in = new FileInputStream(filename); // or System.in;
        ANTLRInputStream input = new ANTLRInputStream(in);
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

        Prog prog = (Prog) MagASTBuilder.stack.peek();
        prog.emit();
        prog.declarations.stream().filter(declaration -> declaration instanceof FunctionDecl).forEach(function -> {
            //((FunctionDecl)function).cfg.printInitialInstructions();
            ((FunctionDecl) function).cfg.buildBasicBlock();
            System.out.println("func " + ((FunctionDecl) function).functionName + "{");
            System.out.println(((FunctionDecl) function).cfg.basicBlockToString());
            System.out.println("}");
        });
    }
}
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
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;

import static org.junit.Assert.fail;

@RunWith(Parameterized.class)
public class SemanticCheckTest {
    @Parameterized.Parameters
    public static Collection<Object[]> data() {
        Collection<Object[]> params = new ArrayList<>();
        for (File f : new File("testcase/passed/").listFiles()) {
            if (f.isFile() && f.getName().endsWith(".mx")) {
                params.add(new Object[] { "testcase/passed/" + f.getName(), true });
            }
        }
        for (File f : new File("testcase/compile_error/").listFiles()) {
            if (f.isFile() && f.getName().endsWith(".mx")) {
                params.add(new Object[] { "testcase/compile_error/" + f.getName(), false });
            }
        }
        return params;
    }

    private String filename;
    private boolean shouldPass;

    public SemanticCheckTest(String filename, boolean shouldPass) {
        this.filename = filename;
        this.shouldPass = shouldPass;
    }

    @Test
    public void testPass() throws IOException {
        try {
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

            if (!shouldPass) fail("Should not pass.");
        } catch (CompileError e) {
            if (shouldPass) throw e;
            System.out.println(e.getMessage());
        }
    }
}
package Compiler;

import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Parser.MagLexer;
import Compiler.AST.Parser.MagParser;
import Compiler.AST.Prog;
import Compiler.Environment.SymbolTable;
import Compiler.GlobalRegisterAllocator.GlobalRegisterAllocator;
import Compiler.Listener.ClassDeclListener;
import Compiler.Listener.ErrorListener;
import Compiler.Listener.FunctionDeclListener;
import Compiler.Listener.MagASTBuilder;
import Interpreter.LLIRInterpreter;
import com.sun.xml.internal.messaging.saaj.util.ByteInputStream;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.io.*;
import java.util.ArrayList;
import java.util.Collection;

@RunWith(Parameterized.class)
public class IntermediateRepresentationTest {
    private String fileName;

    public IntermediateRepresentationTest(String fileName) {
        this.fileName = fileName;
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data() {
        Collection<Object[]> parameters = new ArrayList<>();
        for (File file : new File("testcase/cfg/intermediate-representation/").listFiles()) {
            if (file.isFile() && file.getName().endsWith(".mx")) {
                parameters.add(new Object[]{"testcase/cfg/intermediate-representation/" + file.getName()});
            }
        }
        return parameters;
    }

    @Test
    public void testPass() throws Exception {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PrintStream out = new PrintStream(outputStream);

        System.out.println(fileName);

        SymbolTable.initilize();

        InputStream in = new FileInputStream(fileName); // or System.in;
        ANTLRInputStream cfginput = new ANTLRInputStream(in);
        MagLexer lexer = new MagLexer(cfginput);
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
            String functionHead = "func " + ((FunctionDecl) function).functionName + " ";
            for (int i = 0; i < ((FunctionDecl) function).parameterOperand.size(); ++i) {
                functionHead = functionHead + ((FunctionDecl) function).parameterOperand.get(i).toString() + " ";
            }
            functionHead += "{";
            out.println(functionHead);
            out.print(((FunctionDecl) function).cfg.basicBlockToString());
            out.println("}");
        });
        prog.declarations.stream().filter(declaration -> declaration instanceof FunctionDecl).forEach(function -> {
            //((FunctionDecl)function).cfg.printInitialInstructions();
            //((FunctionDecl)function).cfg.buildBasicBlock();

            // new test
            GlobalRegisterAllocator globalRegisterAllocator = new GlobalRegisterAllocator(((FunctionDecl) function).cfg);
            System.out.println(globalRegisterAllocator.interferenceGraphToString());
            String functionHead = "func " + ((FunctionDecl) function).functionName + " ";
            for (int i = 0; i < ((FunctionDecl) function).parameterOperand.size(); ++i) {
                functionHead = functionHead + ((FunctionDecl) function).parameterOperand.get(i).toString() + " ";
            }
            functionHead += "{";
            System.out.println(functionHead);
            System.out.print(((FunctionDecl) function).cfg.basicBlockToString());
            System.out.println("}");
        });

        byte[] text = outputStream.toByteArray();
        ByteInputStream input = new ByteInputStream(text, text.length);
        LLIRInterpreter interpreter = new LLIRInterpreter(input, false);
        interpreter.run();

        BufferedReader bufferedReader = new BufferedReader(new FileReader(fileName));
        String line;
        do {
            line = bufferedReader.readLine();
        } while (!line.startsWith("/*! assert:"));
        String assertion = line.replace("/*! assert:", "").trim();

        if (assertion.equals("exitcode")) {
            int expected = Integer.valueOf(bufferedReader.readLine().trim());
            if (interpreter.getExitcode() != expected) {
                throw new RuntimeException("exitcode = " + interpreter.getExitcode() + ", expected: " + expected);
            }
        } else if (assertion.equals("exception")) {
            if (!interpreter.exitException()) {
                throw new RuntimeException("exit successfully, expected an exception.");
            }
        } else {
            throw new RuntimeException("unknown assertion.");
        }
        bufferedReader.close();
    }
}
package Compiler.Listener;

import Compiler.Error.CompileError;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

/**
 * Created by Alri on 16/4/7.
 */
public class ErrorListener extends BaseErrorListener {
    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
        BaseListener.currentRow = line;
        BaseListener.currentColumn = charPositionInLine;
        throw new CompileError(msg);
    }
}

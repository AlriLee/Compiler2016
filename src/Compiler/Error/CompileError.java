package Compiler.Error;

import Compiler.AbstractSyntaxTree.BaseListener;

/**
 * Created by Alri on 16/4/4.
 */
public class CompileError extends Error {
    public CompileError(String errorMessage) {
        super("Compile error:" + BaseListener.currentRow + ":" + BaseListener.currentColumn + ": " + errorMessage);
    }
}

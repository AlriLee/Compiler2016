package Compiler.AST.Statement.Expression;

import Compiler.AST.Statement.Statement;
import Compiler.AST.Type.Type;

/**
 * Created by Alri on 16/3/31.
 */
public abstract class Expression implements Statement {
    public Type type;
    public boolean lvalue = false;
}

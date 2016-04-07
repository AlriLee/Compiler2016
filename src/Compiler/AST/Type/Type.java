package Compiler.AST.Type;

import Compiler.AST.ASTNode;
import Compiler.AST.Symbol;

/**
 * Created by Alri on 16/3/31.
 */
public interface Type extends ASTNode {
    boolean equal(Type rhs);

    Type getMemberType(Symbol memberSymbol);
}

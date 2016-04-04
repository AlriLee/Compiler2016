package Compiler.AbstractSyntaxTree;

import Compiler.AbstractSyntaxTree.Decl.Declaration;

import java.util.LinkedList;
import java.util.List;

import static Compiler.Tool.Tool.indent;

/**
 * Created by Alri on 16/4/2.
 */
public class Prog implements ASTNode {
    public List<Declaration> declarations;

    public Prog() {
        declarations = new LinkedList<Declaration>();
    }

    public Prog(List<Declaration> d) {
        declarations = d;
    }

    @Override
    public String toString(int d) {
        String string = indent(d) + "Prog\n";
        for (int i = 0; i < declarations.size(); ++i) {
            string += declarations.get(i).toString(d + 1);
        }
        return string;
    }
}

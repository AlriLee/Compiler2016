package Compiler.Operand;

import Compiler.Environment.SymbolTable;

/**
 * Created by Alri on 16/5/6.
 */
public class StringImmediate extends Register {
    public String literal;

    public StringImmediate(String literal) {
        super();
        this.literal = literal;
        SymbolTable.stringImmediateArrayList.add(this);
    }

    //public int stringSize() {
    //TODO
    //}

    @Override
    public String toString() {
        return literal;
    }
}

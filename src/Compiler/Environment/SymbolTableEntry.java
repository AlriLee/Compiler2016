package Compiler.Environment;

import Compiler.AST.Type.Type;
import Compiler.Operand.Register;

/**
 * Created by Alri on 16/4/23.
 */
public class SymbolTableEntry {
    public String name;
    public Type type;
    public Register register;

    public SymbolTableEntry(String name, Type type) {
        this.name = name;
        this.type = type;
        this.register = new Register();
    }
}

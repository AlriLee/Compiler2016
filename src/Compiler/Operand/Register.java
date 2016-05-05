package Compiler.Operand;

/**
 * Created by Alri on 16/4/23.
 */
public class Register extends Operand {
    public static int registers = 0;

    public int id;

    public Register() {
        this.id = registers++;
    }

    @Override
    public String toString() {
        return "$" + String.valueOf(id);
    }
}

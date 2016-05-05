package Compiler.Operand;

/**
 * Created by Alri on 16/4/23.
 */
public class Immediate extends Operand {
    long immediate;

    public Immediate(long i) {
        immediate = i;
    }

    @Override
    public String toString() {
        return String.valueOf(immediate);
    }
}

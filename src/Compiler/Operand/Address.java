package Compiler.Operand;

/**
 * Created by Alri on 16/4/23.
 */
public class Address extends Operand {
    public Register baseAddress;
    public Immediate offSet;
    public long size;

    public Address(Register b, Immediate o, long s) {
        baseAddress = b;
        offSet = o;
        size = s;
    }

    @Override
    public String toString() {
        return String.valueOf(size) + " " + baseAddress.toString() + " " + offSet.toString();
    }
}

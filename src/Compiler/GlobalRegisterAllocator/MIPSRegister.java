package Compiler.GlobalRegisterAllocator;

/**
 * Created by Alri on 16/5/4.
 */
public class MIPSRegister {
    public static MIPSRegister zero = new MIPSRegister("zero");
    public static MIPSRegister at = new MIPSRegister("$at");
    public static MIPSRegister v0 = new MIPSRegister("$v0");
    public static MIPSRegister v1 = new MIPSRegister("$v1");
    public static MIPSRegister a0 = new MIPSRegister("$a0");
    public static MIPSRegister a1 = new MIPSRegister("$a1");
    public static MIPSRegister a2 = new MIPSRegister("$a2");
    public static MIPSRegister a3 = new MIPSRegister("$a3");
    public static MIPSRegister t0 = new MIPSRegister("$t0");
    public static MIPSRegister t1 = new MIPSRegister("$t1");
    public static MIPSRegister t2 = new MIPSRegister("$t2");
    public static MIPSRegister t3 = new MIPSRegister("$t3");
    public static MIPSRegister t4 = new MIPSRegister("$t4");
    public static MIPSRegister t5 = new MIPSRegister("$t5");
    public static MIPSRegister t6 = new MIPSRegister("$t6");
    public static MIPSRegister t7 = new MIPSRegister("$t7");
    public static MIPSRegister s0 = new MIPSRegister("$s0");
    public static MIPSRegister s1 = new MIPSRegister("$s1");
    public static MIPSRegister s2 = new MIPSRegister("$s2");
    public static MIPSRegister s3 = new MIPSRegister("$s3");
    public static MIPSRegister s4 = new MIPSRegister("$s4");
    public static MIPSRegister s5 = new MIPSRegister("$s5");
    public static MIPSRegister s6 = new MIPSRegister("$s6");
    public static MIPSRegister s7 = new MIPSRegister("$s7");
    public static MIPSRegister t8 = new MIPSRegister("$t8");
    public static MIPSRegister t9 = new MIPSRegister("$t9");
    public static MIPSRegister k0 = new MIPSRegister("$k0");
    public static MIPSRegister k1 = new MIPSRegister("$k1");
    public static MIPSRegister gp = new MIPSRegister("$gp");
    public static MIPSRegister sp = new MIPSRegister("$sp");
    public static MIPSRegister ra = new MIPSRegister("$ra");
    public static MIPSRegister fp = new MIPSRegister("$fp");
    public String registerName;
    public MIPSRegister(String rn) {
        registerName = rn;
    }

    @Override
    public String toString() {
        return registerName;
    }
}

package Compiler.Tool;

public class Tool {
    public static String indent(int d) {
        String string = "";
        for (; --d >= 0; )
            string = string + "\t";
        return string;
    }
}

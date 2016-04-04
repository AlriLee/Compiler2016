package Compiler.AbstractSyntaxTree;

/**
 * Created by Alri on 16/4/2.
 */
public class Info {
    public int rowNumber;
    public int columnNumber;

    public Info() {
        rowNumber = 0;
        columnNumber = 0;
    }

    public Info(int r, int c) {
        rowNumber = r;
        columnNumber = c;
    }
}

// Generated from /Users/Alri/IdeaProjects/Compiler2016/src/Compiler/AST/Parser/Mag.g4 by ANTLR 4.5.1
package Compiler.AbstractSyntaxTree.Parser;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.atn.ATNDeserializer;
import org.antlr.v4.runtime.atn.LexerATNSimulator;
import org.antlr.v4.runtime.atn.PredictionContextCache;
import org.antlr.v4.runtime.dfa.DFA;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class MagLexer extends Lexer {
    public static final int
            Break = 1, Continue = 2, Else = 3, For = 4, If = 5, Int = 6, Void = 7, While = 8, Bool = 9,
            String = 10, Null = 11, True = 12, False = 13, Return = 14, New = 15, Class = 16, LeftParen = 17,
            RightParen = 18, LeftBracket = 19, RightBracket = 20, LeftBrace = 21, RightBrace = 22,
            Less = 23, LessEqual = 24, Greater = 25, GreaterEqual = 26, LeftShift = 27, RightShift = 28,
            Plus = 29, PlusPlus = 30, Minus = 31, MinusMinus = 32, Star = 33, Div = 34, Mod = 35,
            And = 36, Or = 37, AndAnd = 38, OrOr = 39, Caret = 40, Not = 41, Tilde = 42, Question = 43,
            Colon = 44, Semi = 45, Comma = 46, Assign = 47, Equal = 48, NotEqual = 49, Dot = 50,
            ID = 51, IntLiteral = 52, StringLiteral = 53, Whitespace = 54, Newline = 55, LineComment = 56;
    public static final String[] ruleNames = {
            "Break", "Continue", "Else", "For", "If", "Int", "Void", "While", "Bool",
            "String", "Null", "True", "False", "Return", "New", "Class", "LeftParen",
            "RightParen", "LeftBracket", "RightBracket", "LeftBrace", "RightBrace",
            "Less", "LessEqual", "Greater", "GreaterEqual", "LeftShift", "RightShift",
            "Plus", "PlusPlus", "Minus", "MinusMinus", "Star", "Div", "Mod", "And",
            "Or", "AndAnd", "OrOr", "Caret", "Not", "Tilde", "Question", "Colon",
            "Semi", "Comma", "Assign", "Equal", "NotEqual", "Dot", "ID", "IntLiteral",
            "EscapeSequence", "StringLiteral", "SCharSequence", "SChar", "Whitespace",
            "Newline", "LineComment"
    };
    /**
     * @deprecated Use {@link #VOCABULARY} instead.
     */
    @Deprecated
    public static final String[] tokenNames;
    public static final String _serializedATN =
            "\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\2:\u0157\b\1\4\2\t" +
                    "\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13" +
                    "\t\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22" +
                    "\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31\t\31" +
                    "\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36\4\37\t\37\4 \t \4!" +
                    "\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t&\4\'\t\'\4(\t(\4)\t)\4*\t*\4+\t+\4" +
                    ",\t,\4-\t-\4.\t.\4/\t/\4\60\t\60\4\61\t\61\4\62\t\62\4\63\t\63\4\64\t" +
                    "\64\4\65\t\65\4\66\t\66\4\67\t\67\48\t8\49\t9\4:\t:\4;\t;\4<\t<\3\2\3" +
                    "\2\3\2\3\2\3\2\3\2\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\4\3\4\3\4\3\4" +
                    "\3\4\3\5\3\5\3\5\3\5\3\6\3\6\3\6\3\7\3\7\3\7\3\7\3\b\3\b\3\b\3\b\3\b\3" +
                    "\t\3\t\3\t\3\t\3\t\3\t\3\n\3\n\3\n\3\n\3\n\3\13\3\13\3\13\3\13\3\13\3" +
                    "\13\3\13\3\f\3\f\3\f\3\f\3\f\3\r\3\r\3\r\3\r\3\r\3\16\3\16\3\16\3\16\3" +
                    "\16\3\16\3\17\3\17\3\17\3\17\3\17\3\17\3\17\3\20\3\20\3\20\3\20\3\21\3" +
                    "\21\3\21\3\21\3\21\3\21\3\22\3\22\3\23\3\23\3\24\3\24\3\25\3\25\3\26\3" +
                    "\26\3\27\3\27\3\30\3\30\3\31\3\31\3\31\3\32\3\32\3\33\3\33\3\33\3\34\3" +
                    "\34\3\34\3\35\3\35\3\35\3\36\3\36\3\37\3\37\3\37\3 \3 \3!\3!\3!\3\"\3" +
                    "\"\3#\3#\3$\3$\3%\3%\3&\3&\3\'\3\'\3\'\3(\3(\3(\3)\3)\3*\3*\3+\3+\3,\3" +
                    ",\3-\3-\3.\3.\3/\3/\3\60\3\60\3\61\3\61\3\61\3\62\3\62\3\62\3\63\3\63" +
                    "\3\64\3\64\7\64\u0121\n\64\f\64\16\64\u0124\13\64\3\65\6\65\u0127\n\65" +
                    "\r\65\16\65\u0128\3\66\3\66\3\66\3\67\3\67\5\67\u0130\n\67\3\67\3\67\3" +
                    "8\68\u0135\n8\r8\168\u0136\39\39\59\u013b\n9\3:\6:\u013e\n:\r:\16:\u013f" +
                    "\3:\3:\3;\3;\5;\u0146\n;\3;\5;\u0149\n;\3;\3;\3<\3<\3<\3<\7<\u0151\n<" +
                    "\f<\16<\u0154\13<\3<\3<\2\2=\3\3\5\4\7\5\t\6\13\7\r\b\17\t\21\n\23\13" +
                    "\25\f\27\r\31\16\33\17\35\20\37\21!\22#\23%\24\'\25)\26+\27-\30/\31\61" +
                    "\32\63\33\65\34\67\359\36;\37= ?!A\"C#E$G%I&K\'M(O)Q*S+U,W-Y.[/]\60_\61" +
                    "a\62c\63e\64g\65i\66k\2m\67o\2q\2s8u9w:\3\2\t\4\2C\\c|\6\2\62;C\\aac|" +
                    "\3\2\62;\5\2$$^^pp\5\2\f\f\17\17$$\4\2\13\13\"\"\4\2\f\f\17\17\u015c\2" +
                    "\3\3\2\2\2\2\5\3\2\2\2\2\7\3\2\2\2\2\t\3\2\2\2\2\13\3\2\2\2\2\r\3\2\2" +
                    "\2\2\17\3\2\2\2\2\21\3\2\2\2\2\23\3\2\2\2\2\25\3\2\2\2\2\27\3\2\2\2\2" +
                    "\31\3\2\2\2\2\33\3\2\2\2\2\35\3\2\2\2\2\37\3\2\2\2\2!\3\2\2\2\2#\3\2\2" +
                    "\2\2%\3\2\2\2\2\'\3\2\2\2\2)\3\2\2\2\2+\3\2\2\2\2-\3\2\2\2\2/\3\2\2\2" +
                    "\2\61\3\2\2\2\2\63\3\2\2\2\2\65\3\2\2\2\2\67\3\2\2\2\29\3\2\2\2\2;\3\2" +
                    "\2\2\2=\3\2\2\2\2?\3\2\2\2\2A\3\2\2\2\2C\3\2\2\2\2E\3\2\2\2\2G\3\2\2\2" +
                    "\2I\3\2\2\2\2K\3\2\2\2\2M\3\2\2\2\2O\3\2\2\2\2Q\3\2\2\2\2S\3\2\2\2\2U" +
                    "\3\2\2\2\2W\3\2\2\2\2Y\3\2\2\2\2[\3\2\2\2\2]\3\2\2\2\2_\3\2\2\2\2a\3\2" +
                    "\2\2\2c\3\2\2\2\2e\3\2\2\2\2g\3\2\2\2\2i\3\2\2\2\2m\3\2\2\2\2s\3\2\2\2" +
                    "\2u\3\2\2\2\2w\3\2\2\2\3y\3\2\2\2\5\177\3\2\2\2\7\u0088\3\2\2\2\t\u008d" +
                    "\3\2\2\2\13\u0091\3\2\2\2\r\u0094\3\2\2\2\17\u0098\3\2\2\2\21\u009d\3" +
                    "\2\2\2\23\u00a3\3\2\2\2\25\u00a8\3\2\2\2\27\u00af\3\2\2\2\31\u00b4\3\2" +
                    "\2\2\33\u00b9\3\2\2\2\35\u00bf\3\2\2\2\37\u00c6\3\2\2\2!\u00ca\3\2\2\2" +
                    "#\u00d0\3\2\2\2%\u00d2\3\2\2\2\'\u00d4\3\2\2\2)\u00d6\3\2\2\2+\u00d8\3" +
                    "\2\2\2-\u00da\3\2\2\2/\u00dc\3\2\2\2\61\u00de\3\2\2\2\63\u00e1\3\2\2\2" +
                    "\65\u00e3\3\2\2\2\67\u00e6\3\2\2\29\u00e9\3\2\2\2;\u00ec\3\2\2\2=\u00ee" +
                    "\3\2\2\2?\u00f1\3\2\2\2A\u00f3\3\2\2\2C\u00f6\3\2\2\2E\u00f8\3\2\2\2G" +
                    "\u00fa\3\2\2\2I\u00fc\3\2\2\2K\u00fe\3\2\2\2M\u0100\3\2\2\2O\u0103\3\2" +
                    "\2\2Q\u0106\3\2\2\2S\u0108\3\2\2\2U\u010a\3\2\2\2W\u010c\3\2\2\2Y\u010e" +
                    "\3\2\2\2[\u0110\3\2\2\2]\u0112\3\2\2\2_\u0114\3\2\2\2a\u0116\3\2\2\2c" +
                    "\u0119\3\2\2\2e\u011c\3\2\2\2g\u011e\3\2\2\2i\u0126\3\2\2\2k\u012a\3\2" +
                    "\2\2m\u012d\3\2\2\2o\u0134\3\2\2\2q\u013a\3\2\2\2s\u013d\3\2\2\2u\u0148" +
                    "\3\2\2\2w\u014c\3\2\2\2yz\7d\2\2z{\7t\2\2{|\7g\2\2|}\7c\2\2}~\7m\2\2~" +
                    "\4\3\2\2\2\177\u0080\7e\2\2\u0080\u0081\7q\2\2\u0081\u0082\7p\2\2\u0082" +
                    "\u0083\7v\2\2\u0083\u0084\7k\2\2\u0084\u0085\7p\2\2\u0085\u0086\7w\2\2" +
                    "\u0086\u0087\7g\2\2\u0087\6\3\2\2\2\u0088\u0089\7g\2\2\u0089\u008a\7n" +
                    "\2\2\u008a\u008b\7u\2\2\u008b\u008c\7g\2\2\u008c\b\3\2\2\2\u008d\u008e" +
                    "\7h\2\2\u008e\u008f\7q\2\2\u008f\u0090\7t\2\2\u0090\n\3\2\2\2\u0091\u0092" +
                    "\7k\2\2\u0092\u0093\7h\2\2\u0093\f\3\2\2\2\u0094\u0095\7k\2\2\u0095\u0096" +
                    "\7p\2\2\u0096\u0097\7v\2\2\u0097\16\3\2\2\2\u0098\u0099\7x\2\2\u0099\u009a" +
                    "\7q\2\2\u009a\u009b\7k\2\2\u009b\u009c\7f\2\2\u009c\20\3\2\2\2\u009d\u009e" +
                    "\7y\2\2\u009e\u009f\7j\2\2\u009f\u00a0\7k\2\2\u00a0\u00a1\7n\2\2\u00a1" +
                    "\u00a2\7g\2\2\u00a2\22\3\2\2\2\u00a3\u00a4\7d\2\2\u00a4\u00a5\7q\2\2\u00a5" +
                    "\u00a6\7q\2\2\u00a6\u00a7\7n\2\2\u00a7\24\3\2\2\2\u00a8\u00a9\7u\2\2\u00a9" +
                    "\u00aa\7v\2\2\u00aa\u00ab\7t\2\2\u00ab\u00ac\7k\2\2\u00ac\u00ad\7p\2\2" +
                    "\u00ad\u00ae\7i\2\2\u00ae\26\3\2\2\2\u00af\u00b0\7p\2\2\u00b0\u00b1\7" +
                    "w\2\2\u00b1\u00b2\7n\2\2\u00b2\u00b3\7n\2\2\u00b3\30\3\2\2\2\u00b4\u00b5" +
                    "\7v\2\2\u00b5\u00b6\7t\2\2\u00b6\u00b7\7w\2\2\u00b7\u00b8\7g\2\2\u00b8" +
                    "\32\3\2\2\2\u00b9\u00ba\7h\2\2\u00ba\u00bb\7c\2\2\u00bb\u00bc\7n\2\2\u00bc" +
                    "\u00bd\7u\2\2\u00bd\u00be\7g\2\2\u00be\34\3\2\2\2\u00bf\u00c0\7t\2\2\u00c0" +
                    "\u00c1\7g\2\2\u00c1\u00c2\7v\2\2\u00c2\u00c3\7w\2\2\u00c3\u00c4\7t\2\2" +
                    "\u00c4\u00c5\7p\2\2\u00c5\36\3\2\2\2\u00c6\u00c7\7p\2\2\u00c7\u00c8\7" +
                    "g\2\2\u00c8\u00c9\7y\2\2\u00c9 \3\2\2\2\u00ca\u00cb\7e\2\2\u00cb\u00cc" +
                    "\7n\2\2\u00cc\u00cd\7c\2\2\u00cd\u00ce\7u\2\2\u00ce\u00cf\7u\2\2\u00cf" +
                    "\"\3\2\2\2\u00d0\u00d1\7*\2\2\u00d1$\3\2\2\2\u00d2\u00d3\7+\2\2\u00d3" +
                    "&\3\2\2\2\u00d4\u00d5\7]\2\2\u00d5(\3\2\2\2\u00d6\u00d7\7_\2\2\u00d7*" +
                    "\3\2\2\2\u00d8\u00d9\7}\2\2\u00d9,\3\2\2\2\u00da\u00db\7\177\2\2\u00db" +
                    ".\3\2\2\2\u00dc\u00dd\7>\2\2\u00dd\60\3\2\2\2\u00de\u00df\7>\2\2\u00df" +
                    "\u00e0\7?\2\2\u00e0\62\3\2\2\2\u00e1\u00e2\7@\2\2\u00e2\64\3\2\2\2\u00e3" +
                    "\u00e4\7@\2\2\u00e4\u00e5\7?\2\2\u00e5\66\3\2\2\2\u00e6\u00e7\7>\2\2\u00e7" +
                    "\u00e8\7>\2\2\u00e88\3\2\2\2\u00e9\u00ea\7@\2\2\u00ea\u00eb\7@\2\2\u00eb" +
                    ":\3\2\2\2\u00ec\u00ed\7-\2\2\u00ed<\3\2\2\2\u00ee\u00ef\7-\2\2\u00ef\u00f0" +
                    "\7-\2\2\u00f0>\3\2\2\2\u00f1\u00f2\7/\2\2\u00f2@\3\2\2\2\u00f3\u00f4\7" +
                    "/\2\2\u00f4\u00f5\7/\2\2\u00f5B\3\2\2\2\u00f6\u00f7\7,\2\2\u00f7D\3\2" +
                    "\2\2\u00f8\u00f9\7\61\2\2\u00f9F\3\2\2\2\u00fa\u00fb\7\'\2\2\u00fbH\3" +
                    "\2\2\2\u00fc\u00fd\7(\2\2\u00fdJ\3\2\2\2\u00fe\u00ff\7~\2\2\u00ffL\3\2" +
                    "\2\2\u0100\u0101\7(\2\2\u0101\u0102\7(\2\2\u0102N\3\2\2\2\u0103\u0104" +
                    "\7~\2\2\u0104\u0105\7~\2\2\u0105P\3\2\2\2\u0106\u0107\7`\2\2\u0107R\3" +
                    "\2\2\2\u0108\u0109\7#\2\2\u0109T\3\2\2\2\u010a\u010b\7\u0080\2\2\u010b" +
                    "V\3\2\2\2\u010c\u010d\7A\2\2\u010dX\3\2\2\2\u010e\u010f\7<\2\2\u010fZ" +
                    "\3\2\2\2\u0110\u0111\7=\2\2\u0111\\\3\2\2\2\u0112\u0113\7.\2\2\u0113^" +
                    "\3\2\2\2\u0114\u0115\7?\2\2\u0115`\3\2\2\2\u0116\u0117\7?\2\2\u0117\u0118" +
                    "\7?\2\2\u0118b\3\2\2\2\u0119\u011a\7#\2\2\u011a\u011b\7?\2\2\u011bd\3" +
                    "\2\2\2\u011c\u011d\7\60\2\2\u011df\3\2\2\2\u011e\u0122\t\2\2\2\u011f\u0121" +
                    "\t\3\2\2\u0120\u011f\3\2\2\2\u0121\u0124\3\2\2\2\u0122\u0120\3\2\2\2\u0122" +
                    "\u0123\3\2\2\2\u0123h\3\2\2\2\u0124\u0122\3\2\2\2\u0125\u0127\t\4\2\2" +
                    "\u0126\u0125\3\2\2\2\u0127\u0128\3\2\2\2\u0128\u0126\3\2\2\2\u0128\u0129" +
                    "\3\2\2\2\u0129j\3\2\2\2\u012a\u012b\7^\2\2\u012b\u012c\t\5\2\2\u012cl" +
                    "\3\2\2\2\u012d\u012f\7$\2\2\u012e\u0130\5o8\2\u012f\u012e\3\2\2\2\u012f" +
                    "\u0130\3\2\2\2\u0130\u0131\3\2\2\2\u0131\u0132\7$\2\2\u0132n\3\2\2\2\u0133" +
                    "\u0135\5q9\2\u0134\u0133\3\2\2\2\u0135\u0136\3\2\2\2\u0136\u0134\3\2\2" +
                    "\2\u0136\u0137\3\2\2\2\u0137p\3\2\2\2\u0138\u013b\n\6\2\2\u0139\u013b" +
                    "\5k\66\2\u013a\u0138\3\2\2\2\u013a\u0139\3\2\2\2\u013br\3\2\2\2\u013c" +
                    "\u013e\t\7\2\2\u013d\u013c\3\2\2\2\u013e\u013f\3\2\2\2\u013f\u013d\3\2" +
                    "\2\2\u013f\u0140\3\2\2\2\u0140\u0141\3\2\2\2\u0141\u0142\b:\2\2\u0142" +
                    "t\3\2\2\2\u0143\u0145\7\17\2\2\u0144\u0146\7\f\2\2\u0145\u0144\3\2\2\2" +
                    "\u0145\u0146\3\2\2\2\u0146\u0149\3\2\2\2\u0147\u0149\7\f\2\2\u0148\u0143" +
                    "\3\2\2\2\u0148\u0147\3\2\2\2\u0149\u014a\3\2\2\2\u014a\u014b\b;\2\2\u014b" +
                    "v\3\2\2\2\u014c\u014d\7\61\2\2\u014d\u014e\7\61\2\2\u014e\u0152\3\2\2" +
                    "\2\u014f\u0151\n\b\2\2\u0150\u014f\3\2\2\2\u0151\u0154\3\2\2\2\u0152\u0150" +
                    "\3\2\2\2\u0152\u0153\3\2\2\2\u0153\u0155\3\2\2\2\u0154\u0152\3\2\2\2\u0155" +
                    "\u0156\b<\2\2\u0156x\3\2\2\2\f\2\u0122\u0128\u012f\u0136\u013a\u013f\u0145" +
                    "\u0148\u0152\3\b\2\2";
    public static final ATN _ATN =
            new ATNDeserializer().deserialize(_serializedATN.toCharArray());
    protected static final DFA[] _decisionToDFA;
    protected static final PredictionContextCache _sharedContextCache =
            new PredictionContextCache();
    private static final String[] _LITERAL_NAMES = {
            null, "'break'", "'continue'", "'else'", "'for'", "'if'", "'int'", "'void'",
            "'while'", "'bool'", "'string'", "'null'", "'true'", "'false'", "'return'",
            "'new'", "'class'", "'('", "')'", "'['", "']'", "'{'", "'}'", "'<'", "'<='",
            "'>'", "'>='", "'<<'", "'>>'", "'+'", "'++'", "'-'", "'--'", "'*'", "'/'",
            "'%'", "'&'", "'|'", "'&&'", "'||'", "'^'", "'!'", "'~'", "'?'", "':'",
            "';'", "','", "'='", "'=='", "'!='", "'.'"
    };
    private static final String[] _SYMBOLIC_NAMES = {
            null, "Break", "Continue", "Else", "For", "If", "Int", "Void", "While",
            "Bool", "String", "Null", "True", "False", "Return", "New", "Class", "LeftParen",
            "RightParen", "LeftBracket", "RightBracket", "LeftBrace", "RightBrace",
            "Less", "LessEqual", "Greater", "GreaterEqual", "LeftShift", "RightShift",
            "Plus", "PlusPlus", "Minus", "MinusMinus", "Star", "Div", "Mod", "And",
            "Or", "AndAnd", "OrOr", "Caret", "Not", "Tilde", "Question", "Colon",
            "Semi", "Comma", "Assign", "Equal", "NotEqual", "Dot", "ID", "IntLiteral",
            "StringLiteral", "Whitespace", "Newline", "LineComment"
    };
    public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);
    public static String[] modeNames = {
            "DEFAULT_MODE"
    };

    static {
        RuntimeMetaData.checkVersion("4.5.1", RuntimeMetaData.VERSION);
    }

    static {
        tokenNames = new String[_SYMBOLIC_NAMES.length];
        for (int i = 0; i < tokenNames.length; i++) {
            tokenNames[i] = VOCABULARY.getLiteralName(i);
            if (tokenNames[i] == null) {
                tokenNames[i] = VOCABULARY.getSymbolicName(i);
            }

            if (tokenNames[i] == null) {
                tokenNames[i] = "<INVALID>";
            }
        }
    }

    static {
        _decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
        for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
            _decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
        }
    }

    public MagLexer(CharStream input) {
        super(input);
        _interp = new LexerATNSimulator(this, _ATN, _decisionToDFA, _sharedContextCache);
    }

    @Override
    @Deprecated
    public String[] getTokenNames() {
        return tokenNames;
    }

    @Override

    public Vocabulary getVocabulary() {
        return VOCABULARY;
    }

    @Override
    public String getGrammarFileName() {
        return "Mag.g4";
    }

    @Override
    public String[] getRuleNames() {
        return ruleNames;
    }

    @Override
    public String getSerializedATN() {
        return _serializedATN;
    }

    @Override
    public String[] getModeNames() {
        return modeNames;
    }

    @Override
    public ATN getATN() {
        return _ATN;
    }
}
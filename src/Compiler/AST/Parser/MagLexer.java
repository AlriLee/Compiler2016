// Generated from /Users/Alri/IdeaProjects/Compiler2016/src/Compiler/AST/Parser/Mag.g4 by ANTLR 4.5.1
package Compiler.AST.Parser;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class MagLexer extends Lexer {
	static { RuntimeMetaData.checkVersion("4.5.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		Break=1, Continue=2, Else=3, For=4, If=5, Int=6, Void=7, While=8, Bool=9, 
		String=10, Null=11, True=12, False=13, Return=14, New=15, Class=16, LeftParen=17, 
		RightParen=18, LeftBracket=19, RightBracket=20, LeftBrace=21, RightBrace=22, 
		Less=23, LessEqual=24, Greater=25, GreaterEqual=26, LeftShift=27, RightShift=28, 
		Plus=29, PlusPlus=30, Minus=31, MinusMinus=32, Star=33, Div=34, Mod=35, 
		And=36, Or=37, AndAnd=38, OrOr=39, Caret=40, Not=41, Tilde=42, Question=43, 
		Colon=44, Semi=45, Comma=46, Assign=47, Equal=48, NotEqual=49, Dot=50, 
		ID=51, IntLiteral=52, StringLiteral=53, Whitespace=54, Newline=55, LineComment=56, 
		BlockComment=57;
	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	public static final String[] ruleNames = {
		"Break", "Continue", "Else", "For", "If", "Int", "Void", "While", "Bool", 
		"String", "Null", "True", "False", "Return", "New", "Class", "LeftParen", 
		"RightParen", "LeftBracket", "RightBracket", "LeftBrace", "RightBrace", 
		"Less", "LessEqual", "Greater", "GreaterEqual", "LeftShift", "RightShift", 
		"Plus", "PlusPlus", "Minus", "MinusMinus", "Star", "Div", "Mod", "And", 
		"Or", "AndAnd", "OrOr", "Caret", "Not", "Tilde", "Question", "Colon", 
		"Semi", "Comma", "Assign", "Equal", "NotEqual", "Dot", "ID", "IntLiteral", 
		"EscapeSequence", "StringLiteral", "SCharSequence", "SChar", "Whitespace", 
		"Newline", "LineComment", "BlockComment"
	};

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
		"StringLiteral", "Whitespace", "Newline", "LineComment", "BlockComment"
	};
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
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

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}


	public MagLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "Mag.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\2;\u0167\b\1\4\2\t"+
		"\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13"+
		"\t\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22"+
		"\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31\t\31"+
		"\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36\4\37\t\37\4 \t \4!"+
		"\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t&\4\'\t\'\4(\t(\4)\t)\4*\t*\4+\t+\4"+
		",\t,\4-\t-\4.\t.\4/\t/\4\60\t\60\4\61\t\61\4\62\t\62\4\63\t\63\4\64\t"+
		"\64\4\65\t\65\4\66\t\66\4\67\t\67\48\t8\49\t9\4:\t:\4;\t;\4<\t<\4=\t="+
		"\3\2\3\2\3\2\3\2\3\2\3\2\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\4\3\4\3"+
		"\4\3\4\3\4\3\5\3\5\3\5\3\5\3\6\3\6\3\6\3\7\3\7\3\7\3\7\3\b\3\b\3\b\3\b"+
		"\3\b\3\t\3\t\3\t\3\t\3\t\3\t\3\n\3\n\3\n\3\n\3\n\3\13\3\13\3\13\3\13\3"+
		"\13\3\13\3\13\3\f\3\f\3\f\3\f\3\f\3\r\3\r\3\r\3\r\3\r\3\16\3\16\3\16\3"+
		"\16\3\16\3\16\3\17\3\17\3\17\3\17\3\17\3\17\3\17\3\20\3\20\3\20\3\20\3"+
		"\21\3\21\3\21\3\21\3\21\3\21\3\22\3\22\3\23\3\23\3\24\3\24\3\25\3\25\3"+
		"\26\3\26\3\27\3\27\3\30\3\30\3\31\3\31\3\31\3\32\3\32\3\33\3\33\3\33\3"+
		"\34\3\34\3\34\3\35\3\35\3\35\3\36\3\36\3\37\3\37\3\37\3 \3 \3!\3!\3!\3"+
		"\"\3\"\3#\3#\3$\3$\3%\3%\3&\3&\3\'\3\'\3\'\3(\3(\3(\3)\3)\3*\3*\3+\3+"+
		"\3,\3,\3-\3-\3.\3.\3/\3/\3\60\3\60\3\61\3\61\3\61\3\62\3\62\3\62\3\63"+
		"\3\63\3\64\3\64\7\64\u0123\n\64\f\64\16\64\u0126\13\64\3\65\6\65\u0129"+
		"\n\65\r\65\16\65\u012a\3\66\3\66\3\66\3\67\3\67\5\67\u0132\n\67\3\67\3"+
		"\67\38\68\u0137\n8\r8\168\u0138\39\39\59\u013d\n9\3:\6:\u0140\n:\r:\16"+
		":\u0141\3:\3:\3;\3;\5;\u0148\n;\3;\5;\u014b\n;\3;\3;\3<\3<\3<\3<\7<\u0153"+
		"\n<\f<\16<\u0156\13<\3<\3<\3=\3=\3=\3=\7=\u015e\n=\f=\16=\u0161\13=\3"+
		"=\3=\3=\3=\3=\3\u015f\2>\3\3\5\4\7\5\t\6\13\7\r\b\17\t\21\n\23\13\25\f"+
		"\27\r\31\16\33\17\35\20\37\21!\22#\23%\24\'\25)\26+\27-\30/\31\61\32\63"+
		"\33\65\34\67\359\36;\37= ?!A\"C#E$G%I&K\'M(O)Q*S+U,W-Y.[/]\60_\61a\62"+
		"c\63e\64g\65i\66k\2m\67o\2q\2s8u9w:y;\3\2\t\4\2C\\c|\6\2\62;C\\aac|\3"+
		"\2\62;\5\2$$^^pp\5\2\f\f\17\17$$\4\2\13\13\"\"\4\2\f\f\17\17\u016d\2\3"+
		"\3\2\2\2\2\5\3\2\2\2\2\7\3\2\2\2\2\t\3\2\2\2\2\13\3\2\2\2\2\r\3\2\2\2"+
		"\2\17\3\2\2\2\2\21\3\2\2\2\2\23\3\2\2\2\2\25\3\2\2\2\2\27\3\2\2\2\2\31"+
		"\3\2\2\2\2\33\3\2\2\2\2\35\3\2\2\2\2\37\3\2\2\2\2!\3\2\2\2\2#\3\2\2\2"+
		"\2%\3\2\2\2\2\'\3\2\2\2\2)\3\2\2\2\2+\3\2\2\2\2-\3\2\2\2\2/\3\2\2\2\2"+
		"\61\3\2\2\2\2\63\3\2\2\2\2\65\3\2\2\2\2\67\3\2\2\2\29\3\2\2\2\2;\3\2\2"+
		"\2\2=\3\2\2\2\2?\3\2\2\2\2A\3\2\2\2\2C\3\2\2\2\2E\3\2\2\2\2G\3\2\2\2\2"+
		"I\3\2\2\2\2K\3\2\2\2\2M\3\2\2\2\2O\3\2\2\2\2Q\3\2\2\2\2S\3\2\2\2\2U\3"+
		"\2\2\2\2W\3\2\2\2\2Y\3\2\2\2\2[\3\2\2\2\2]\3\2\2\2\2_\3\2\2\2\2a\3\2\2"+
		"\2\2c\3\2\2\2\2e\3\2\2\2\2g\3\2\2\2\2i\3\2\2\2\2m\3\2\2\2\2s\3\2\2\2\2"+
		"u\3\2\2\2\2w\3\2\2\2\2y\3\2\2\2\3{\3\2\2\2\5\u0081\3\2\2\2\7\u008a\3\2"+
		"\2\2\t\u008f\3\2\2\2\13\u0093\3\2\2\2\r\u0096\3\2\2\2\17\u009a\3\2\2\2"+
		"\21\u009f\3\2\2\2\23\u00a5\3\2\2\2\25\u00aa\3\2\2\2\27\u00b1\3\2\2\2\31"+
		"\u00b6\3\2\2\2\33\u00bb\3\2\2\2\35\u00c1\3\2\2\2\37\u00c8\3\2\2\2!\u00cc"+
		"\3\2\2\2#\u00d2\3\2\2\2%\u00d4\3\2\2\2\'\u00d6\3\2\2\2)\u00d8\3\2\2\2"+
		"+\u00da\3\2\2\2-\u00dc\3\2\2\2/\u00de\3\2\2\2\61\u00e0\3\2\2\2\63\u00e3"+
		"\3\2\2\2\65\u00e5\3\2\2\2\67\u00e8\3\2\2\29\u00eb\3\2\2\2;\u00ee\3\2\2"+
		"\2=\u00f0\3\2\2\2?\u00f3\3\2\2\2A\u00f5\3\2\2\2C\u00f8\3\2\2\2E\u00fa"+
		"\3\2\2\2G\u00fc\3\2\2\2I\u00fe\3\2\2\2K\u0100\3\2\2\2M\u0102\3\2\2\2O"+
		"\u0105\3\2\2\2Q\u0108\3\2\2\2S\u010a\3\2\2\2U\u010c\3\2\2\2W\u010e\3\2"+
		"\2\2Y\u0110\3\2\2\2[\u0112\3\2\2\2]\u0114\3\2\2\2_\u0116\3\2\2\2a\u0118"+
		"\3\2\2\2c\u011b\3\2\2\2e\u011e\3\2\2\2g\u0120\3\2\2\2i\u0128\3\2\2\2k"+
		"\u012c\3\2\2\2m\u012f\3\2\2\2o\u0136\3\2\2\2q\u013c\3\2\2\2s\u013f\3\2"+
		"\2\2u\u014a\3\2\2\2w\u014e\3\2\2\2y\u0159\3\2\2\2{|\7d\2\2|}\7t\2\2}~"+
		"\7g\2\2~\177\7c\2\2\177\u0080\7m\2\2\u0080\4\3\2\2\2\u0081\u0082\7e\2"+
		"\2\u0082\u0083\7q\2\2\u0083\u0084\7p\2\2\u0084\u0085\7v\2\2\u0085\u0086"+
		"\7k\2\2\u0086\u0087\7p\2\2\u0087\u0088\7w\2\2\u0088\u0089\7g\2\2\u0089"+
		"\6\3\2\2\2\u008a\u008b\7g\2\2\u008b\u008c\7n\2\2\u008c\u008d\7u\2\2\u008d"+
		"\u008e\7g\2\2\u008e\b\3\2\2\2\u008f\u0090\7h\2\2\u0090\u0091\7q\2\2\u0091"+
		"\u0092\7t\2\2\u0092\n\3\2\2\2\u0093\u0094\7k\2\2\u0094\u0095\7h\2\2\u0095"+
		"\f\3\2\2\2\u0096\u0097\7k\2\2\u0097\u0098\7p\2\2\u0098\u0099\7v\2\2\u0099"+
		"\16\3\2\2\2\u009a\u009b\7x\2\2\u009b\u009c\7q\2\2\u009c\u009d\7k\2\2\u009d"+
		"\u009e\7f\2\2\u009e\20\3\2\2\2\u009f\u00a0\7y\2\2\u00a0\u00a1\7j\2\2\u00a1"+
		"\u00a2\7k\2\2\u00a2\u00a3\7n\2\2\u00a3\u00a4\7g\2\2\u00a4\22\3\2\2\2\u00a5"+
		"\u00a6\7d\2\2\u00a6\u00a7\7q\2\2\u00a7\u00a8\7q\2\2\u00a8\u00a9\7n\2\2"+
		"\u00a9\24\3\2\2\2\u00aa\u00ab\7u\2\2\u00ab\u00ac\7v\2\2\u00ac\u00ad\7"+
		"t\2\2\u00ad\u00ae\7k\2\2\u00ae\u00af\7p\2\2\u00af\u00b0\7i\2\2\u00b0\26"+
		"\3\2\2\2\u00b1\u00b2\7p\2\2\u00b2\u00b3\7w\2\2\u00b3\u00b4\7n\2\2\u00b4"+
		"\u00b5\7n\2\2\u00b5\30\3\2\2\2\u00b6\u00b7\7v\2\2\u00b7\u00b8\7t\2\2\u00b8"+
		"\u00b9\7w\2\2\u00b9\u00ba\7g\2\2\u00ba\32\3\2\2\2\u00bb\u00bc\7h\2\2\u00bc"+
		"\u00bd\7c\2\2\u00bd\u00be\7n\2\2\u00be\u00bf\7u\2\2\u00bf\u00c0\7g\2\2"+
		"\u00c0\34\3\2\2\2\u00c1\u00c2\7t\2\2\u00c2\u00c3\7g\2\2\u00c3\u00c4\7"+
		"v\2\2\u00c4\u00c5\7w\2\2\u00c5\u00c6\7t\2\2\u00c6\u00c7\7p\2\2\u00c7\36"+
		"\3\2\2\2\u00c8\u00c9\7p\2\2\u00c9\u00ca\7g\2\2\u00ca\u00cb\7y\2\2\u00cb"+
		" \3\2\2\2\u00cc\u00cd\7e\2\2\u00cd\u00ce\7n\2\2\u00ce\u00cf\7c\2\2\u00cf"+
		"\u00d0\7u\2\2\u00d0\u00d1\7u\2\2\u00d1\"\3\2\2\2\u00d2\u00d3\7*\2\2\u00d3"+
		"$\3\2\2\2\u00d4\u00d5\7+\2\2\u00d5&\3\2\2\2\u00d6\u00d7\7]\2\2\u00d7("+
		"\3\2\2\2\u00d8\u00d9\7_\2\2\u00d9*\3\2\2\2\u00da\u00db\7}\2\2\u00db,\3"+
		"\2\2\2\u00dc\u00dd\7\177\2\2\u00dd.\3\2\2\2\u00de\u00df\7>\2\2\u00df\60"+
		"\3\2\2\2\u00e0\u00e1\7>\2\2\u00e1\u00e2\7?\2\2\u00e2\62\3\2\2\2\u00e3"+
		"\u00e4\7@\2\2\u00e4\64\3\2\2\2\u00e5\u00e6\7@\2\2\u00e6\u00e7\7?\2\2\u00e7"+
		"\66\3\2\2\2\u00e8\u00e9\7>\2\2\u00e9\u00ea\7>\2\2\u00ea8\3\2\2\2\u00eb"+
		"\u00ec\7@\2\2\u00ec\u00ed\7@\2\2\u00ed:\3\2\2\2\u00ee\u00ef\7-\2\2\u00ef"+
		"<\3\2\2\2\u00f0\u00f1\7-\2\2\u00f1\u00f2\7-\2\2\u00f2>\3\2\2\2\u00f3\u00f4"+
		"\7/\2\2\u00f4@\3\2\2\2\u00f5\u00f6\7/\2\2\u00f6\u00f7\7/\2\2\u00f7B\3"+
		"\2\2\2\u00f8\u00f9\7,\2\2\u00f9D\3\2\2\2\u00fa\u00fb\7\61\2\2\u00fbF\3"+
		"\2\2\2\u00fc\u00fd\7\'\2\2\u00fdH\3\2\2\2\u00fe\u00ff\7(\2\2\u00ffJ\3"+
		"\2\2\2\u0100\u0101\7~\2\2\u0101L\3\2\2\2\u0102\u0103\7(\2\2\u0103\u0104"+
		"\7(\2\2\u0104N\3\2\2\2\u0105\u0106\7~\2\2\u0106\u0107\7~\2\2\u0107P\3"+
		"\2\2\2\u0108\u0109\7`\2\2\u0109R\3\2\2\2\u010a\u010b\7#\2\2\u010bT\3\2"+
		"\2\2\u010c\u010d\7\u0080\2\2\u010dV\3\2\2\2\u010e\u010f\7A\2\2\u010fX"+
		"\3\2\2\2\u0110\u0111\7<\2\2\u0111Z\3\2\2\2\u0112\u0113\7=\2\2\u0113\\"+
		"\3\2\2\2\u0114\u0115\7.\2\2\u0115^\3\2\2\2\u0116\u0117\7?\2\2\u0117`\3"+
		"\2\2\2\u0118\u0119\7?\2\2\u0119\u011a\7?\2\2\u011ab\3\2\2\2\u011b\u011c"+
		"\7#\2\2\u011c\u011d\7?\2\2\u011dd\3\2\2\2\u011e\u011f\7\60\2\2\u011ff"+
		"\3\2\2\2\u0120\u0124\t\2\2\2\u0121\u0123\t\3\2\2\u0122\u0121\3\2\2\2\u0123"+
		"\u0126\3\2\2\2\u0124\u0122\3\2\2\2\u0124\u0125\3\2\2\2\u0125h\3\2\2\2"+
		"\u0126\u0124\3\2\2\2\u0127\u0129\t\4\2\2\u0128\u0127\3\2\2\2\u0129\u012a"+
		"\3\2\2\2\u012a\u0128\3\2\2\2\u012a\u012b\3\2\2\2\u012bj\3\2\2\2\u012c"+
		"\u012d\7^\2\2\u012d\u012e\t\5\2\2\u012el\3\2\2\2\u012f\u0131\7$\2\2\u0130"+
		"\u0132\5o8\2\u0131\u0130\3\2\2\2\u0131\u0132\3\2\2\2\u0132\u0133\3\2\2"+
		"\2\u0133\u0134\7$\2\2\u0134n\3\2\2\2\u0135\u0137\5q9\2\u0136\u0135\3\2"+
		"\2\2\u0137\u0138\3\2\2\2\u0138\u0136\3\2\2\2\u0138\u0139\3\2\2\2\u0139"+
		"p\3\2\2\2\u013a\u013d\n\6\2\2\u013b\u013d\5k\66\2\u013c\u013a\3\2\2\2"+
		"\u013c\u013b\3\2\2\2\u013dr\3\2\2\2\u013e\u0140\t\7\2\2\u013f\u013e\3"+
		"\2\2\2\u0140\u0141\3\2\2\2\u0141\u013f\3\2\2\2\u0141\u0142\3\2\2\2\u0142"+
		"\u0143\3\2\2\2\u0143\u0144\b:\2\2\u0144t\3\2\2\2\u0145\u0147\7\17\2\2"+
		"\u0146\u0148\7\f\2\2\u0147\u0146\3\2\2\2\u0147\u0148\3\2\2\2\u0148\u014b"+
		"\3\2\2\2\u0149\u014b\7\f\2\2\u014a\u0145\3\2\2\2\u014a\u0149\3\2\2\2\u014b"+
		"\u014c\3\2\2\2\u014c\u014d\b;\2\2\u014dv\3\2\2\2\u014e\u014f\7\61\2\2"+
		"\u014f\u0150\7\61\2\2\u0150\u0154\3\2\2\2\u0151\u0153\n\b\2\2\u0152\u0151"+
		"\3\2\2\2\u0153\u0156\3\2\2\2\u0154\u0152\3\2\2\2\u0154\u0155\3\2\2\2\u0155"+
		"\u0157\3\2\2\2\u0156\u0154\3\2\2\2\u0157\u0158\b<\2\2\u0158x\3\2\2\2\u0159"+
		"\u015a\7\61\2\2\u015a\u015b\7,\2\2\u015b\u015f\3\2\2\2\u015c\u015e\13"+
		"\2\2\2\u015d\u015c\3\2\2\2\u015e\u0161\3\2\2\2\u015f\u0160\3\2\2\2\u015f"+
		"\u015d\3\2\2\2\u0160\u0162\3\2\2\2\u0161\u015f\3\2\2\2\u0162\u0163\7,"+
		"\2\2\u0163\u0164\7\61\2\2\u0164\u0165\3\2\2\2\u0165\u0166\b=\2\2\u0166"+
		"z\3\2\2\2\r\2\u0124\u012a\u0131\u0138\u013c\u0141\u0147\u014a\u0154\u015f"+
		"\3\b\2\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}
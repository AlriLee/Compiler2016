// Generated from /Users/Alri/IdeaProjects/Compiler2016/src/Compiler/AST/Parser/Mag.g4 by ANTLR 4.5.1
package Compiler.AST.Parser;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.atn.ATNDeserializer;
import org.antlr.v4.runtime.atn.ParserATNSimulator;
import org.antlr.v4.runtime.atn.PredictionContextCache;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.tree.ParseTreeListener;
import org.antlr.v4.runtime.tree.TerminalNode;

import java.util.List;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class MagParser extends Parser {
	public static final int
			Break = 1, Continue = 2, Else = 3, For = 4, If = 5, Int = 6, Void = 7, While = 8, Bool = 9,
			String = 10, Null = 11, True = 12, False = 13, Return = 14, New = 15, Class = 16, LeftParen = 17,
			RightParen = 18, LeftBracket = 19, RightBracket = 20, LeftBrace = 21, RightBrace = 22,
			Less = 23, LessEqual = 24, Greater = 25, GreaterEqual = 26, LeftShift = 27, RightShift = 28,
			Plus = 29, PlusPlus = 30, Minus = 31, MinusMinus = 32, Star = 33, Div = 34, Mod = 35,
			And = 36, Or = 37, AndAnd = 38, OrOr = 39, Caret = 40, Not = 41, Tilde = 42, Question = 43,
			Colon = 44, Semi = 45, Comma = 46, Assign = 47, Equal = 48, NotEqual = 49, Dot = 50,
			ID = 51, IntLiteral = 52, StringLiteral = 53, Whitespace = 54, Newline = 55, LineComment = 56;
	public static final int
			RULE_program = 0, RULE_classDeclaration = 1, RULE_classMemberDeclarationList = 2,
			RULE_typeArray = 3, RULE_type = 4, RULE_statement = 5, RULE_blockStatement = 6,
			RULE_statementList = 7, RULE_expressionStatement = 8, RULE_expression = 9,
			RULE_assignmentExpression = 10, RULE_logicalOrExpression = 11, RULE_logicalAndExpression = 12,
			RULE_bitwiseOrExpression = 13, RULE_bitwiseXorExpression = 14, RULE_bitwiseAndExpression = 15,
			RULE_equalityExpression = 16, RULE_relationalExpression = 17, RULE_shiftExpression = 18,
			RULE_addSubExpression = 19, RULE_mulDivRemExpression = 20, RULE_creationExpression = 21,
			RULE_dimensionExpression = 22, RULE_dimensionVoidExpression = 23, RULE_prefixExpression = 24,
			RULE_postfixExpression = 25, RULE_primaryExpression = 26, RULE_constant = 27,
			RULE_logicConstant = 28, RULE_argumentExpressionList = 29, RULE_selectionStatement = 30,
			RULE_iterationStatement = 31, RULE_whileStatement = 32, RULE_forStatement = 33,
			RULE_jumpStatement = 34, RULE_returnStatement = 35, RULE_breakStatement = 36,
			RULE_continueStatement = 37, RULE_variableDeclarationStatement = 38, RULE_variableDeclaration = 39,
			RULE_functionDeclaration = 40, RULE_parameterList = 41;
	public static final String[] ruleNames = {
			"program", "classDeclaration", "classMemberDeclarationList", "typeArray",
			"type", "statement", "blockStatement", "statementList", "expressionStatement",
			"expression", "assignmentExpression", "logicalOrExpression", "logicalAndExpression",
			"bitwiseOrExpression", "bitwiseXorExpression", "bitwiseAndExpression",
			"equalityExpression", "relationalExpression", "shiftExpression", "addSubExpression",
			"mulDivRemExpression", "creationExpression", "dimensionExpression", "dimensionVoidExpression",
			"prefixExpression", "postfixExpression", "primaryExpression", "constant",
			"logicConstant", "argumentExpressionList", "selectionStatement", "iterationStatement",
			"whileStatement", "forStatement", "jumpStatement", "returnStatement",
			"breakStatement", "continueStatement", "variableDeclarationStatement",
			"variableDeclaration", "functionDeclaration", "parameterList"
	};
	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	public static final String _serializedATN =
			"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\3:\u01f0\4\2\t\2\4" +
					"\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13\t" +
					"\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22" +
					"\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31\t\31" +
					"\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36\4\37\t\37\4 \t \4!" +
					"\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t&\4\'\t\'\4(\t(\4)\t)\4*\t*\4+\t+\3" +
					"\2\3\2\3\2\3\2\3\2\6\2\\\n\2\r\2\16\2]\3\3\3\3\3\3\3\3\5\3d\n\3\3\3\3" +
					"\3\3\4\3\4\3\4\3\4\3\4\3\4\3\4\3\4\3\4\5\4q\n\4\3\5\3\5\3\5\3\5\3\5\3" +
					"\5\7\5y\n\5\f\5\16\5|\13\5\3\6\3\6\3\7\3\7\3\7\3\7\3\7\3\7\5\7\u0086\n" +
					"\7\3\b\3\b\5\b\u008a\n\b\3\b\3\b\3\t\3\t\3\t\3\t\5\t\u0092\n\t\3\n\5\n" +
					"\u0095\n\n\3\n\3\n\3\13\3\13\3\f\3\f\3\f\3\f\3\f\5\f\u00a0\n\f\3\r\3\r" +
					"\3\r\3\r\3\r\3\r\7\r\u00a8\n\r\f\r\16\r\u00ab\13\r\3\16\3\16\3\16\3\16" +
					"\3\16\3\16\7\16\u00b3\n\16\f\16\16\16\u00b6\13\16\3\17\3\17\3\17\3\17" +
					"\3\17\3\17\7\17\u00be\n\17\f\17\16\17\u00c1\13\17\3\20\3\20\3\20\3\20" +
					"\3\20\3\20\7\20\u00c9\n\20\f\20\16\20\u00cc\13\20\3\21\3\21\3\21\3\21" +
					"\3\21\3\21\7\21\u00d4\n\21\f\21\16\21\u00d7\13\21\3\22\3\22\3\22\3\22" +
					"\3\22\3\22\3\22\3\22\3\22\7\22\u00e2\n\22\f\22\16\22\u00e5\13\22\3\23" +
					"\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23\3\23" +
					"\7\23\u00f6\n\23\f\23\16\23\u00f9\13\23\3\24\3\24\3\24\3\24\3\24\3\24" +
					"\3\24\3\24\3\24\7\24\u0104\n\24\f\24\16\24\u0107\13\24\3\25\3\25\3\25" +
					"\3\25\3\25\3\25\3\25\3\25\3\25\7\25\u0112\n\25\f\25\16\25\u0115\13\25" +
					"\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\26\7\26\u0123" +
					"\n\26\f\26\16\26\u0126\13\26\3\27\3\27\3\27\5\27\u012b\n\27\3\27\3\27" +
					"\3\27\3\27\3\27\3\27\3\27\5\27\u0134\n\27\3\30\3\30\3\30\3\30\3\30\3\30" +
					"\3\30\3\30\3\30\3\30\5\30\u0140\n\30\3\31\3\31\3\31\3\31\3\31\5\31\u0147" +
					"\n\31\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32" +
					"\5\32\u0156\n\32\3\33\3\33\3\33\3\33\3\33\3\33\3\33\3\33\3\33\3\33\3\33" +
					"\5\33\u0163\n\33\3\33\3\33\3\33\3\33\3\33\3\33\3\33\3\33\7\33\u016d\n" +
					"\33\f\33\16\33\u0170\13\33\3\34\3\34\3\34\3\34\3\34\3\34\5\34\u0178\n" +
					"\34\3\35\3\35\3\35\3\35\5\35\u017e\n\35\3\36\3\36\5\36\u0182\n\36\3\37" +
					"\3\37\3\37\3\37\3\37\5\37\u0189\n\37\3 \3 \3 \3 \3 \3 \3 \3 \3 \3 \3 " +
					"\3 \3 \3 \5 \u0199\n \3!\3!\5!\u019d\n!\3\"\3\"\3\"\3\"\3\"\3\"\3#\3#" +
					"\3#\5#\u01a8\n#\3#\3#\5#\u01ac\n#\3#\3#\5#\u01b0\n#\3#\3#\3#\3$\3$\3$" +
					"\5$\u01b8\n$\3%\3%\5%\u01bc\n%\3%\3%\3&\3&\3&\3\'\3\'\3\'\3(\3(\3(\3)" +
					"\3)\3)\3)\3)\3)\3)\3)\5)\u01d1\n)\3*\3*\3*\3*\5*\u01d7\n*\3*\3*\3*\3*" +
					"\3*\3*\3*\5*\u01e0\n*\3*\3*\5*\u01e4\n*\3+\3+\3+\3+\3+\3+\3+\3+\5+\u01ee" +
					"\n+\3+\2\16\b\30\32\34\36 \"$&(*\64,\2\4\6\b\n\f\16\20\22\24\26\30\32" +
					"\34\36 \"$&(*,.\60\62\64\668:<>@BDFHJLNPRT\2\3\5\2\b\b\13\f\65\65\u020c" +
					"\2[\3\2\2\2\4_\3\2\2\2\6p\3\2\2\2\br\3\2\2\2\n}\3\2\2\2\f\u0085\3\2\2" +
					"\2\16\u0087\3\2\2\2\20\u0091\3\2\2\2\22\u0094\3\2\2\2\24\u0098\3\2\2\2" +
					"\26\u009f\3\2\2\2\30\u00a1\3\2\2\2\32\u00ac\3\2\2\2\34\u00b7\3\2\2\2\36" +
					"\u00c2\3\2\2\2 \u00cd\3\2\2\2\"\u00d8\3\2\2\2$\u00e6\3\2\2\2&\u00fa\3" +
					"\2\2\2(\u0108\3\2\2\2*\u0116\3\2\2\2,\u0133\3\2\2\2.\u013f\3\2\2\2\60" +
					"\u0146\3\2\2\2\62\u0155\3\2\2\2\64\u0157\3\2\2\2\66\u0177\3\2\2\28\u017d" +
					"\3\2\2\2:\u0181\3\2\2\2<\u0188\3\2\2\2>\u0198\3\2\2\2@\u019c\3\2\2\2B" +
					"\u019e\3\2\2\2D\u01a4\3\2\2\2F\u01b7\3\2\2\2H\u01b9\3\2\2\2J\u01bf\3\2" +
					"\2\2L\u01c2\3\2\2\2N\u01c5\3\2\2\2P\u01d0\3\2\2\2R\u01e3\3\2\2\2T\u01ed" +
					"\3\2\2\2V\\\5\4\3\2W\\\5R*\2XY\5P)\2YZ\7/\2\2Z\\\3\2\2\2[V\3\2\2\2[W\3" +
					"\2\2\2[X\3\2\2\2\\]\3\2\2\2][\3\2\2\2]^\3\2\2\2^\3\3\2\2\2_`\7\22\2\2" +
					"`a\7\65\2\2ac\7\27\2\2bd\5\6\4\2cb\3\2\2\2cd\3\2\2\2de\3\2\2\2ef\7\30" +
					"\2\2f\5\3\2\2\2gh\5\b\5\2hi\7\65\2\2ij\7/\2\2jq\3\2\2\2kl\5\b\5\2lm\7" +
					"\65\2\2mn\7/\2\2no\5\6\4\2oq\3\2\2\2pg\3\2\2\2pk\3\2\2\2q\7\3\2\2\2rs" +
					"\b\5\1\2st\5\n\6\2tz\3\2\2\2uv\f\3\2\2vw\7\25\2\2wy\7\26\2\2xu\3\2\2\2" +
					"y|\3\2\2\2zx\3\2\2\2z{\3\2\2\2{\t\3\2\2\2|z\3\2\2\2}~\t\2\2\2~\13\3\2" +
					"\2\2\177\u0086\5\16\b\2\u0080\u0086\5\22\n\2\u0081\u0086\5> \2\u0082\u0086" +
					"\5@!\2\u0083\u0086\5F$\2\u0084\u0086\5N(\2\u0085\177\3\2\2\2\u0085\u0080" +
					"\3\2\2\2\u0085\u0081\3\2\2\2\u0085\u0082\3\2\2\2\u0085\u0083\3\2\2\2\u0085" +
					"\u0084\3\2\2\2\u0086\r\3\2\2\2\u0087\u0089\7\27\2\2\u0088\u008a\5\20\t" +
					"\2\u0089\u0088\3\2\2\2\u0089\u008a\3\2\2\2\u008a\u008b\3\2\2\2\u008b\u008c" +
					"\7\30\2\2\u008c\17\3\2\2\2\u008d\u0092\5\f\7\2\u008e\u008f\5\f\7\2\u008f" +
					"\u0090\5\20\t\2\u0090\u0092\3\2\2\2\u0091\u008d\3\2\2\2\u0091\u008e\3" +
					"\2\2\2\u0092\21\3\2\2\2\u0093\u0095\5\24\13\2\u0094\u0093\3\2\2\2\u0094" +
					"\u0095\3\2\2\2\u0095\u0096\3\2\2\2\u0096\u0097\7/\2\2\u0097\23\3\2\2\2" +
					"\u0098\u0099\5\26\f\2\u0099\25\3\2\2\2\u009a\u00a0\5\30\r\2\u009b\u009c" +
					"\5\62\32\2\u009c\u009d\7\61\2\2\u009d\u009e\5\26\f\2\u009e\u00a0\3\2\2" +
					"\2\u009f\u009a\3\2\2\2\u009f\u009b\3\2\2\2\u00a0\27\3\2\2\2\u00a1\u00a2" +
					"\b\r\1\2\u00a2\u00a3\5\32\16\2\u00a3\u00a9\3\2\2\2\u00a4\u00a5\f\3\2\2" +
					"\u00a5\u00a6\7)\2\2\u00a6\u00a8\5\32\16\2\u00a7\u00a4\3\2\2\2\u00a8\u00ab" +
					"\3\2\2\2\u00a9\u00a7\3\2\2\2\u00a9\u00aa\3\2\2\2\u00aa\31\3\2\2\2\u00ab" +
					"\u00a9\3\2\2\2\u00ac\u00ad\b\16\1\2\u00ad\u00ae\5\34\17\2\u00ae\u00b4" +
					"\3\2\2\2\u00af\u00b0\f\3\2\2\u00b0\u00b1\7(\2\2\u00b1\u00b3\5\34\17\2" +
					"\u00b2\u00af\3\2\2\2\u00b3\u00b6\3\2\2\2\u00b4\u00b2\3\2\2\2\u00b4\u00b5" +
					"\3\2\2\2\u00b5\33\3\2\2\2\u00b6\u00b4\3\2\2\2\u00b7\u00b8\b\17\1\2\u00b8" +
					"\u00b9\5\36\20\2\u00b9\u00bf\3\2\2\2\u00ba\u00bb\f\3\2\2\u00bb\u00bc\7" +
					"\'\2\2\u00bc\u00be\5\36\20\2\u00bd\u00ba\3\2\2\2\u00be\u00c1\3\2\2\2\u00bf" +
					"\u00bd\3\2\2\2\u00bf\u00c0\3\2\2\2\u00c0\35\3\2\2\2\u00c1\u00bf\3\2\2" +
					"\2\u00c2\u00c3\b\20\1\2\u00c3\u00c4\5 \21\2\u00c4\u00ca\3\2\2\2\u00c5" +
					"\u00c6\f\3\2\2\u00c6\u00c7\7*\2\2\u00c7\u00c9\5 \21\2\u00c8\u00c5\3\2" +
					"\2\2\u00c9\u00cc\3\2\2\2\u00ca\u00c8\3\2\2\2\u00ca\u00cb\3\2\2\2\u00cb" +
					"\37\3\2\2\2\u00cc\u00ca\3\2\2\2\u00cd\u00ce\b\21\1\2\u00ce\u00cf\5\"\22" +
					"\2\u00cf\u00d5\3\2\2\2\u00d0\u00d1\f\3\2\2\u00d1\u00d2\7&\2\2\u00d2\u00d4" +
					"\5\"\22\2\u00d3\u00d0\3\2\2\2\u00d4\u00d7\3\2\2\2\u00d5\u00d3\3\2\2\2" +
					"\u00d5\u00d6\3\2\2\2\u00d6!\3\2\2\2\u00d7\u00d5\3\2\2\2\u00d8\u00d9\b" +
					"\22\1\2\u00d9\u00da\5$\23\2\u00da\u00e3\3\2\2\2\u00db\u00dc\f\4\2\2\u00dc" +
					"\u00dd\7\62\2\2\u00dd\u00e2\5$\23\2\u00de\u00df\f\3\2\2\u00df\u00e0\7" +
					"\63\2\2\u00e0\u00e2\5$\23\2\u00e1\u00db\3\2\2\2\u00e1\u00de\3\2\2\2\u00e2" +
					"\u00e5\3\2\2\2\u00e3\u00e1\3\2\2\2\u00e3\u00e4\3\2\2\2\u00e4#\3\2\2\2" +
					"\u00e5\u00e3\3\2\2\2\u00e6\u00e7\b\23\1\2\u00e7\u00e8\5&\24\2\u00e8\u00f7" +
					"\3\2\2\2\u00e9\u00ea\f\6\2\2\u00ea\u00eb\7\31\2\2\u00eb\u00f6\5&\24\2" +
					"\u00ec\u00ed\f\5\2\2\u00ed\u00ee\7\33\2\2\u00ee\u00f6\5&\24\2\u00ef\u00f0" +
					"\f\4\2\2\u00f0\u00f1\7\32\2\2\u00f1\u00f6\5&\24\2\u00f2\u00f3\f\3\2\2" +
					"\u00f3\u00f4\7\34\2\2\u00f4\u00f6\5&\24\2\u00f5\u00e9\3\2\2\2\u00f5\u00ec" +
					"\3\2\2\2\u00f5\u00ef\3\2\2\2\u00f5\u00f2\3\2\2\2\u00f6\u00f9\3\2\2\2\u00f7" +
					"\u00f5\3\2\2\2\u00f7\u00f8\3\2\2\2\u00f8%\3\2\2\2\u00f9\u00f7\3\2\2\2" +
					"\u00fa\u00fb\b\24\1\2\u00fb\u00fc\5(\25\2\u00fc\u0105\3\2\2\2\u00fd\u00fe" +
					"\f\4\2\2\u00fe\u00ff\7\35\2\2\u00ff\u0104\5(\25\2\u0100\u0101\f\3\2\2" +
					"\u0101\u0102\7\36\2\2\u0102\u0104\5(\25\2\u0103\u00fd\3\2\2\2\u0103\u0100" +
					"\3\2\2\2\u0104\u0107\3\2\2\2\u0105\u0103\3\2\2\2\u0105\u0106\3\2\2\2\u0106" +
					"\'\3\2\2\2\u0107\u0105\3\2\2\2\u0108\u0109\b\25\1\2\u0109\u010a\5*\26" +
					"\2\u010a\u0113\3\2\2\2\u010b\u010c\f\4\2\2\u010c\u010d\7\37\2\2\u010d" +
					"\u0112\5*\26\2\u010e\u010f\f\3\2\2\u010f\u0110\7!\2\2\u0110\u0112\5*\26" +
					"\2\u0111\u010b\3\2\2\2\u0111\u010e\3\2\2\2\u0112\u0115\3\2\2\2\u0113\u0111" +
					"\3\2\2\2\u0113\u0114\3\2\2\2\u0114)\3\2\2\2\u0115\u0113\3\2\2\2\u0116" +
					"\u0117\b\26\1\2\u0117\u0118\5,\27\2\u0118\u0124\3\2\2\2\u0119\u011a\f" +
					"\5\2\2\u011a\u011b\7#\2\2\u011b\u0123\5,\27\2\u011c\u011d\f\4\2\2\u011d" +
					"\u011e\7$\2\2\u011e\u0123\5,\27\2\u011f\u0120\f\3\2\2\u0120\u0121\7%\2" +
					"\2\u0121\u0123\5,\27\2\u0122\u0119\3\2\2\2\u0122\u011c\3\2\2\2\u0122\u011f" +
					"\3\2\2\2\u0123\u0126\3\2\2\2\u0124\u0122\3\2\2\2\u0124\u0125\3\2\2\2\u0125" +
					"+\3\2\2\2\u0126\u0124\3\2\2\2\u0127\u0128\7\21\2\2\u0128\u012a\5\n\6\2" +
					"\u0129\u012b\5.\30\2\u012a\u0129\3\2\2\2\u012a\u012b\3\2\2\2\u012b\u0134" +
					"\3\2\2\2\u012c\u012d\7\21\2\2\u012d\u012e\5\b\5\2\u012e\u012f\7\23\2\2" +
					"\u012f\u0130\5\24\13\2\u0130\u0131\7\24\2\2\u0131\u0134\3\2\2\2\u0132" +
					"\u0134\5\62\32\2\u0133\u0127\3\2\2\2\u0133\u012c\3\2\2\2\u0133\u0132\3" +
					"\2\2\2\u0134-\3\2\2\2\u0135\u0136\7\25\2\2\u0136\u0137\5\24\13\2\u0137" +
					"\u0138\7\26\2\2\u0138\u0140\3\2\2\2\u0139\u013a\7\25\2\2\u013a\u013b\5" +
					"\24\13\2\u013b\u013c\7\26\2\2\u013c\u013d\5.\30\2\u013d\u0140\3\2\2\2" +
					"\u013e\u0140\5\60\31\2\u013f\u0135\3\2\2\2\u013f\u0139\3\2\2\2\u013f\u013e" +
					"\3\2\2\2\u0140/\3\2\2\2\u0141\u0142\7\25\2\2\u0142\u0147\7\26\2\2\u0143" +
					"\u0144\7\25\2\2\u0144\u0145\7\26\2\2\u0145\u0147\5\60\31\2\u0146\u0141" +
					"\3\2\2\2\u0146\u0143\3\2\2\2\u0147\61\3\2\2\2\u0148\u0156\5\64\33\2\u0149" +
					"\u014a\7\37\2\2\u014a\u0156\5\62\32\2\u014b\u014c\7!\2\2\u014c\u0156\5" +
					"\62\32\2\u014d\u014e\7+\2\2\u014e\u0156\5\62\32\2\u014f\u0150\7,\2\2\u0150" +
					"\u0156\5\62\32\2\u0151\u0152\7 \2\2\u0152\u0156\5\62\32\2\u0153\u0154" +
					"\7\"\2\2\u0154\u0156\5\62\32\2\u0155\u0148\3\2\2\2\u0155\u0149\3\2\2\2" +
					"\u0155\u014b\3\2\2\2\u0155\u014d\3\2\2\2\u0155\u014f\3\2\2\2\u0155\u0151" +
					"\3\2\2\2\u0155\u0153\3\2\2\2\u0156\63\3\2\2\2\u0157\u0158\b\33\1\2\u0158" +
					"\u0159\5\66\34\2\u0159\u016e\3\2\2\2\u015a\u015b\f\7\2\2\u015b\u015c\7" +
					"\25\2\2\u015c\u015d\5\24\13\2\u015d\u015e\7\26\2\2\u015e\u016d\3\2\2\2" +
					"\u015f\u0160\f\6\2\2\u0160\u0162\7\23\2\2\u0161\u0163\5<\37\2\u0162\u0161" +
					"\3\2\2\2\u0162\u0163\3\2\2\2\u0163\u0164\3\2\2\2\u0164\u016d\7\24\2\2" +
					"\u0165\u0166\f\5\2\2\u0166\u0167\7\64\2\2\u0167\u016d\7\65\2\2\u0168\u0169" +
					"\f\4\2\2\u0169\u016d\7 \2\2\u016a\u016b\f\3\2\2\u016b\u016d\7\"\2\2\u016c" +
					"\u015a\3\2\2\2\u016c\u015f\3\2\2\2\u016c\u0165\3\2\2\2\u016c\u0168\3\2" +
					"\2\2\u016c\u016a\3\2\2\2\u016d\u0170\3\2\2\2\u016e\u016c\3\2\2\2\u016e" +
					"\u016f\3\2\2\2\u016f\65\3\2\2\2\u0170\u016e\3\2\2\2\u0171\u0178\7\65\2" +
					"\2\u0172\u0178\58\35\2\u0173\u0174\7\23\2\2\u0174\u0175\5\24\13\2\u0175" +
					"\u0176\7\24\2\2\u0176\u0178\3\2\2\2\u0177\u0171\3\2\2\2\u0177\u0172\3" +
					"\2\2\2\u0177\u0173\3\2\2\2\u0178\67\3\2\2\2\u0179\u017e\7\r\2\2\u017a" +
					"\u017e\7\66\2\2\u017b\u017e\7\67\2\2\u017c\u017e\5:\36\2\u017d\u0179\3" +
					"\2\2\2\u017d\u017a\3\2\2\2\u017d\u017b\3\2\2\2\u017d\u017c\3\2\2\2\u017e" +
					"9\3\2\2\2\u017f\u0182\7\16\2\2\u0180\u0182\7\17\2\2\u0181\u017f\3\2\2" +
					"\2\u0181\u0180\3\2\2\2\u0182;\3\2\2\2\u0183\u0189\5\24\13\2\u0184\u0185" +
					"\5\24\13\2\u0185\u0186\7\60\2\2\u0186\u0187\5<\37\2\u0187\u0189\3\2\2" +
					"\2\u0188\u0183\3\2\2\2\u0188\u0184\3\2\2\2\u0189=\3\2\2\2\u018a\u018b" +
					"\7\7\2\2\u018b\u018c\7\23\2\2\u018c\u018d\5\24\13\2\u018d\u018e\7\24\2" +
					"\2\u018e\u018f\5\f\7\2\u018f\u0199\3\2\2\2\u0190\u0191\7\7\2\2\u0191\u0192" +
					"\7\23\2\2\u0192\u0193\5\24\13\2\u0193\u0194\7\24\2\2\u0194\u0195\5\f\7" +
					"\2\u0195\u0196\7\5\2\2\u0196\u0197\5\f\7\2\u0197\u0199\3\2\2\2\u0198\u018a" +
					"\3\2\2\2\u0198\u0190\3\2\2\2\u0199?\3\2\2\2\u019a\u019d\5B\"\2\u019b\u019d" +
					"\5D#\2\u019c\u019a\3\2\2\2\u019c\u019b\3\2\2\2\u019dA\3\2\2\2\u019e\u019f" +
					"\7\n\2\2\u019f\u01a0\7\23\2\2\u01a0\u01a1\5\24\13\2\u01a1\u01a2\7\24\2" +
					"\2\u01a2\u01a3\5\f\7\2\u01a3C\3\2\2\2\u01a4\u01a5\7\6\2\2\u01a5\u01a7" +
					"\7\23\2\2\u01a6\u01a8\5\24\13\2\u01a7\u01a6\3\2\2\2\u01a7\u01a8\3\2\2" +
					"\2\u01a8\u01a9\3\2\2\2\u01a9\u01ab\7/\2\2\u01aa\u01ac\5\24\13\2\u01ab" +
					"\u01aa\3\2\2\2\u01ab\u01ac\3\2\2\2\u01ac\u01ad\3\2\2\2\u01ad\u01af\7/" +
					"\2\2\u01ae\u01b0\5\24\13\2\u01af\u01ae\3\2\2\2\u01af\u01b0\3\2\2\2\u01b0" +
					"\u01b1\3\2\2\2\u01b1\u01b2\7\24\2\2\u01b2\u01b3\5\f\7\2\u01b3E\3\2\2\2" +
					"\u01b4\u01b8\5H%\2\u01b5\u01b8\5J&\2\u01b6\u01b8\5L\'\2\u01b7\u01b4\3" +
					"\2\2\2\u01b7\u01b5\3\2\2\2\u01b7\u01b6\3\2\2\2\u01b8G\3\2\2\2\u01b9\u01bb" +
					"\7\20\2\2\u01ba\u01bc\5\24\13\2\u01bb\u01ba\3\2\2\2\u01bb\u01bc\3\2\2" +
					"\2\u01bc\u01bd\3\2\2\2\u01bd\u01be\7/\2\2\u01beI\3\2\2\2\u01bf\u01c0\7" +
					"\3\2\2\u01c0\u01c1\7/\2\2\u01c1K\3\2\2\2\u01c2\u01c3\7\4\2\2\u01c3\u01c4" +
					"\7/\2\2\u01c4M\3\2\2\2\u01c5\u01c6\5P)\2\u01c6\u01c7\7/\2\2\u01c7O\3\2" +
					"\2\2\u01c8\u01c9\5\b\5\2\u01c9\u01ca\7\65\2\2\u01ca\u01d1\3\2\2\2\u01cb" +
					"\u01cc\5\b\5\2\u01cc\u01cd\7\65\2\2\u01cd\u01ce\7\61\2\2\u01ce\u01cf\5" +
					"\24\13\2\u01cf\u01d1\3\2\2\2\u01d0\u01c8\3\2\2\2\u01d0\u01cb\3\2\2\2\u01d1" +
					"Q\3\2\2\2\u01d2\u01d3\5\b\5\2\u01d3\u01d4\7\65\2\2\u01d4\u01d6\7\23\2" +
					"\2\u01d5\u01d7\5T+\2\u01d6\u01d5\3\2\2\2\u01d6\u01d7\3\2\2\2\u01d7\u01d8" +
					"\3\2\2\2\u01d8\u01d9\7\24\2\2\u01d9\u01da\5\16\b\2\u01da\u01e4\3\2\2\2" +
					"\u01db\u01dc\7\t\2\2\u01dc\u01dd\7\65\2\2\u01dd\u01df\7\23\2\2\u01de\u01e0" +
					"\5T+\2\u01df\u01de\3\2\2\2\u01df\u01e0\3\2\2\2\u01e0\u01e1\3\2\2\2\u01e1" +
					"\u01e2\7\24\2\2\u01e2\u01e4\5\16\b\2\u01e3\u01d2\3\2\2\2\u01e3\u01db\3" +
					"\2\2\2\u01e4S\3\2\2\2\u01e5\u01e6\5\b\5\2\u01e6\u01e7\7\65\2\2\u01e7\u01ee" +
					"\3\2\2\2\u01e8\u01e9\5\b\5\2\u01e9\u01ea\7\65\2\2\u01ea\u01eb\7\60\2\2" +
					"\u01eb\u01ec\5T+\2\u01ec\u01ee\3\2\2\2\u01ed\u01e5\3\2\2\2\u01ed\u01e8" +
					"\3\2\2\2\u01eeU\3\2\2\2\63[]cpz\u0085\u0089\u0091\u0094\u009f\u00a9\u00b4" +
					"\u00bf\u00ca\u00d5\u00e1\u00e3\u00f5\u00f7\u0103\u0105\u0111\u0113\u0122" +
					"\u0124\u012a\u0133\u013f\u0146\u0155\u0162\u016c\u016e\u0177\u017d\u0181" +
					"\u0188\u0198\u019c\u01a7\u01ab\u01af\u01b7\u01bb\u01d0\u01d6\u01df\u01e3" +
					"\u01ed";
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

	public MagParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this, _ATN, _decisionToDFA, _sharedContextCache);
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
	public ATN getATN() {
		return _ATN;
	}

	public final ProgramContext program() throws RecognitionException {
		ProgramContext _localctx = new ProgramContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_program);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(89);
				_errHandler.sync(this);
				_la = _input.LA(1);
				do {
					{
						setState(89);
						switch (getInterpreter().adaptivePredict(_input, 0, _ctx)) {
							case 1: {
								setState(84);
								classDeclaration();
							}
							break;
							case 2: {
								setState(85);
								functionDeclaration();
							}
							break;
							case 3: {
								setState(86);
								variableDeclaration();
								setState(87);
								match(Semi);
							}
							break;
						}
					}
					setState(91);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Int) | (1L << Void) | (1L << Bool) | (1L << String) | (1L << Class) | (1L << ID))) != 0));
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ClassDeclarationContext classDeclaration() throws RecognitionException {
		ClassDeclarationContext _localctx = new ClassDeclarationContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_classDeclaration);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(93);
				match(Class);
				setState(94);
				match(ID);
				setState(95);
				match(LeftBrace);
				setState(97);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Int) | (1L << Bool) | (1L << String) | (1L << ID))) != 0)) {
					{
						setState(96);
						classMemberDeclarationList();
					}
				}

				setState(99);
				match(RightBrace);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ClassMemberDeclarationListContext classMemberDeclarationList() throws RecognitionException {
		ClassMemberDeclarationListContext _localctx = new ClassMemberDeclarationListContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_classMemberDeclarationList);
		try {
			setState(110);
			switch (getInterpreter().adaptivePredict(_input, 3, _ctx)) {
				case 1:
					_localctx = new ClassMemDeclList_Context(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(101);
					typeArray(0);
					setState(102);
					match(ID);
					setState(103);
					match(Semi);
				}
				break;
				case 2:
					_localctx = new ClassMemDeclList_listContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(105);
					typeArray(0);
					setState(106);
					match(ID);
					setState(107);
					match(Semi);
					setState(108);
					classMemberDeclarationList();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final TypeArrayContext typeArray() throws RecognitionException {
		return typeArray(0);
	}

	private TypeArrayContext typeArray(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		TypeArrayContext _localctx = new TypeArrayContext(_ctx, _parentState);
		TypeArrayContext _prevctx = _localctx;
		int _startState = 6;
		enterRecursionRule(_localctx, 6, RULE_typeArray, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new TypeArray_typeContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(113);
					type();
				}
				_ctx.stop = _input.LT(-1);
				setState(120);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 4, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							{
								_localctx = new TypeArray_dimContext(new TypeArrayContext(_parentctx, _parentState));
								pushNewRecursionContext(_localctx, _startState, RULE_typeArray);
								setState(115);
								if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
								setState(116);
								match(LeftBracket);
								setState(117);
								match(RightBracket);
							}
						}
					}
					setState(122);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 4, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final TypeContext type() throws RecognitionException {
		TypeContext _localctx = new TypeContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_type);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(123);
				_la = _input.LA(1);
				if (!((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Int) | (1L << Bool) | (1L << String) | (1L << ID))) != 0))) {
					_errHandler.recoverInline(this);
				} else {
					consume();
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_statement);
		try {
			setState(131);
			switch (getInterpreter().adaptivePredict(_input, 5, _ctx)) {
				case 1:
					enterOuterAlt(_localctx, 1);
				{
					setState(125);
					blockStatement();
				}
				break;
				case 2:
					enterOuterAlt(_localctx, 2);
				{
					setState(126);
					expressionStatement();
				}
				break;
				case 3:
					enterOuterAlt(_localctx, 3);
				{
					setState(127);
					selectionStatement();
				}
				break;
				case 4:
					enterOuterAlt(_localctx, 4);
				{
					setState(128);
					iterationStatement();
				}
				break;
				case 5:
					enterOuterAlt(_localctx, 5);
				{
					setState(129);
					jumpStatement();
				}
				break;
				case 6:
					enterOuterAlt(_localctx, 6);
				{
					setState(130);
					variableDeclarationStatement();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final BlockStatementContext blockStatement() throws RecognitionException {
		BlockStatementContext _localctx = new BlockStatementContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_blockStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(133);
				match(LeftBrace);
				setState(135);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Break) | (1L << Continue) | (1L << For) | (1L << If) | (1L << Int) | (1L << While) | (1L << Bool) | (1L << String) | (1L << Null) | (1L << True) | (1L << False) | (1L << Return) | (1L << New) | (1L << LeftParen) | (1L << LeftBrace) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << Semi) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
					{
						setState(134);
						statementList();
					}
				}

				setState(137);
				match(RightBrace);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final StatementListContext statementList() throws RecognitionException {
		StatementListContext _localctx = new StatementListContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_statementList);
		try {
			setState(143);
			switch (getInterpreter().adaptivePredict(_input, 7, _ctx)) {
				case 1:
					_localctx = new StatementList_stmtContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(139);
					statement();
				}
				break;
				case 2:
					_localctx = new StatementList_listContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(140);
					statement();
					setState(141);
					statementList();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ExpressionStatementContext expressionStatement() throws RecognitionException {
		ExpressionStatementContext _localctx = new ExpressionStatementContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_expressionStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(146);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Null) | (1L << True) | (1L << False) | (1L << New) | (1L << LeftParen) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
					{
						setState(145);
						expression();
					}
				}

				setState(148);
				match(Semi);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ExpressionContext expression() throws RecognitionException {
		ExpressionContext _localctx = new ExpressionContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_expression);
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(150);
				assignmentExpression();
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final AssignmentExpressionContext assignmentExpression() throws RecognitionException {
		AssignmentExpressionContext _localctx = new AssignmentExpressionContext(_ctx, getState());
		enterRule(_localctx, 20, RULE_assignmentExpression);
		try {
			setState(157);
			switch (getInterpreter().adaptivePredict(_input, 9, _ctx)) {
				case 1:
					_localctx = new Assignment_logicalOrContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(152);
					logicalOrExpression(0);
				}
				break;
				case 2:
					_localctx = new Assignment_assignContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(153);
					prefixExpression();
					setState(154);
					match(Assign);
					setState(155);
					assignmentExpression();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final LogicalOrExpressionContext logicalOrExpression() throws RecognitionException {
		return logicalOrExpression(0);
	}

	private LogicalOrExpressionContext logicalOrExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		LogicalOrExpressionContext _localctx = new LogicalOrExpressionContext(_ctx, _parentState);
		LogicalOrExpressionContext _prevctx = _localctx;
		int _startState = 22;
		enterRecursionRule(_localctx, 22, RULE_logicalOrExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new LogicalOr_logicalAndContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(160);
					logicalAndExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(167);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 10, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							{
								_localctx = new LogicalOr_orContext(new LogicalOrExpressionContext(_parentctx, _parentState));
								pushNewRecursionContext(_localctx, _startState, RULE_logicalOrExpression);
								setState(162);
								if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
								setState(163);
								match(OrOr);
								setState(164);
								logicalAndExpression(0);
							}
						}
					}
					setState(169);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 10, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final LogicalAndExpressionContext logicalAndExpression() throws RecognitionException {
		return logicalAndExpression(0);
	}

	private LogicalAndExpressionContext logicalAndExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		LogicalAndExpressionContext _localctx = new LogicalAndExpressionContext(_ctx, _parentState);
		LogicalAndExpressionContext _prevctx = _localctx;
		int _startState = 24;
		enterRecursionRule(_localctx, 24, RULE_logicalAndExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new LogicalAnd_bitwiseOrContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(171);
					bitwiseOrExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(178);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 11, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							{
								_localctx = new LogicalAnd_andContext(new LogicalAndExpressionContext(_parentctx, _parentState));
								pushNewRecursionContext(_localctx, _startState, RULE_logicalAndExpression);
								setState(173);
								if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
								setState(174);
								match(AndAnd);
								setState(175);
								bitwiseOrExpression(0);
							}
						}
					}
					setState(180);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 11, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final BitwiseOrExpressionContext bitwiseOrExpression() throws RecognitionException {
		return bitwiseOrExpression(0);
	}

	private BitwiseOrExpressionContext bitwiseOrExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		BitwiseOrExpressionContext _localctx = new BitwiseOrExpressionContext(_ctx, _parentState);
		BitwiseOrExpressionContext _prevctx = _localctx;
		int _startState = 26;
		enterRecursionRule(_localctx, 26, RULE_bitwiseOrExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new BitwiseOr_bitwiseXorContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(182);
					bitwiseXorExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(189);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 12, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							{
								_localctx = new BitwiseOr_orContext(new BitwiseOrExpressionContext(_parentctx, _parentState));
								pushNewRecursionContext(_localctx, _startState, RULE_bitwiseOrExpression);
								setState(184);
								if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
								setState(185);
								match(Or);
								setState(186);
								bitwiseXorExpression(0);
							}
						}
					}
					setState(191);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 12, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final BitwiseXorExpressionContext bitwiseXorExpression() throws RecognitionException {
		return bitwiseXorExpression(0);
	}

	private BitwiseXorExpressionContext bitwiseXorExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		BitwiseXorExpressionContext _localctx = new BitwiseXorExpressionContext(_ctx, _parentState);
		BitwiseXorExpressionContext _prevctx = _localctx;
		int _startState = 28;
		enterRecursionRule(_localctx, 28, RULE_bitwiseXorExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new BitwiseXor_bitwiseAndContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(193);
					bitwiseAndExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(200);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 13, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							{
								_localctx = new BitwiseXor_xorContext(new BitwiseXorExpressionContext(_parentctx, _parentState));
								pushNewRecursionContext(_localctx, _startState, RULE_bitwiseXorExpression);
								setState(195);
								if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
								setState(196);
								match(Caret);
								setState(197);
								bitwiseAndExpression(0);
							}
						}
					}
					setState(202);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 13, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final BitwiseAndExpressionContext bitwiseAndExpression() throws RecognitionException {
		return bitwiseAndExpression(0);
	}

	private BitwiseAndExpressionContext bitwiseAndExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		BitwiseAndExpressionContext _localctx = new BitwiseAndExpressionContext(_ctx, _parentState);
		BitwiseAndExpressionContext _prevctx = _localctx;
		int _startState = 30;
		enterRecursionRule(_localctx, 30, RULE_bitwiseAndExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new BitwiseAnd_equalContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(204);
					equalityExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(211);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 14, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							{
								_localctx = new BitwiseAnd_andContext(new BitwiseAndExpressionContext(_parentctx, _parentState));
								pushNewRecursionContext(_localctx, _startState, RULE_bitwiseAndExpression);
								setState(206);
								if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
								setState(207);
								match(And);
								setState(208);
								equalityExpression(0);
							}
						}
					}
					setState(213);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 14, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final EqualityExpressionContext equalityExpression() throws RecognitionException {
		return equalityExpression(0);
	}

	private EqualityExpressionContext equalityExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		EqualityExpressionContext _localctx = new EqualityExpressionContext(_ctx, _parentState);
		EqualityExpressionContext _prevctx = _localctx;
		int _startState = 32;
		enterRecursionRule(_localctx, 32, RULE_equalityExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new Equality_relationalContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(215);
					relationalExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(225);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 16, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							setState(223);
							switch (getInterpreter().adaptivePredict(_input, 15, _ctx)) {
								case 1: {
									_localctx = new Equality_equalContext(new EqualityExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_equalityExpression);
									setState(217);
									if (!(precpred(_ctx, 2)))
										throw new FailedPredicateException(this, "precpred(_ctx, 2)");
									setState(218);
									match(Equal);
									setState(219);
									relationalExpression(0);
								}
								break;
								case 2: {
									_localctx = new Equality_notEqualContext(new EqualityExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_equalityExpression);
									setState(220);
									if (!(precpred(_ctx, 1)))
										throw new FailedPredicateException(this, "precpred(_ctx, 1)");
									setState(221);
									match(NotEqual);
									setState(222);
									relationalExpression(0);
								}
								break;
							}
						}
					}
					setState(227);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 16, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final RelationalExpressionContext relationalExpression() throws RecognitionException {
		return relationalExpression(0);
	}

	private RelationalExpressionContext relationalExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		RelationalExpressionContext _localctx = new RelationalExpressionContext(_ctx, _parentState);
		RelationalExpressionContext _prevctx = _localctx;
		int _startState = 34;
		enterRecursionRule(_localctx, 34, RULE_relationalExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new Relational_shiftContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(229);
					shiftExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(245);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 18, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							setState(243);
							switch (getInterpreter().adaptivePredict(_input, 17, _ctx)) {
								case 1: {
									_localctx = new Relational_lessContext(new RelationalExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_relationalExpression);
									setState(231);
									if (!(precpred(_ctx, 4)))
										throw new FailedPredicateException(this, "precpred(_ctx, 4)");
									setState(232);
									match(Less);
									setState(233);
									shiftExpression(0);
								}
								break;
								case 2: {
									_localctx = new Relational_greaterContext(new RelationalExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_relationalExpression);
									setState(234);
									if (!(precpred(_ctx, 3)))
										throw new FailedPredicateException(this, "precpred(_ctx, 3)");
									setState(235);
									match(Greater);
									setState(236);
									shiftExpression(0);
								}
								break;
								case 3: {
									_localctx = new Relational_leqContext(new RelationalExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_relationalExpression);
									setState(237);
									if (!(precpred(_ctx, 2)))
										throw new FailedPredicateException(this, "precpred(_ctx, 2)");
									setState(238);
									match(LessEqual);
									setState(239);
									shiftExpression(0);
								}
								break;
								case 4: {
									_localctx = new Relational_geqContext(new RelationalExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_relationalExpression);
									setState(240);
									if (!(precpred(_ctx, 1)))
										throw new FailedPredicateException(this, "precpred(_ctx, 1)");
									setState(241);
									match(GreaterEqual);
									setState(242);
									shiftExpression(0);
								}
								break;
							}
						}
					}
					setState(247);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 18, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final ShiftExpressionContext shiftExpression() throws RecognitionException {
		return shiftExpression(0);
	}

	private ShiftExpressionContext shiftExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ShiftExpressionContext _localctx = new ShiftExpressionContext(_ctx, _parentState);
		ShiftExpressionContext _prevctx = _localctx;
		int _startState = 36;
		enterRecursionRule(_localctx, 36, RULE_shiftExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new Shift_addSubContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(249);
					addSubExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(259);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 20, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							setState(257);
							switch (getInterpreter().adaptivePredict(_input, 19, _ctx)) {
								case 1: {
									_localctx = new Shift_leftShiftContext(new ShiftExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_shiftExpression);
									setState(251);
									if (!(precpred(_ctx, 2)))
										throw new FailedPredicateException(this, "precpred(_ctx, 2)");
									setState(252);
									match(LeftShift);
									setState(253);
									addSubExpression(0);
								}
								break;
								case 2: {
									_localctx = new Shift_rightShiftContext(new ShiftExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_shiftExpression);
									setState(254);
									if (!(precpred(_ctx, 1)))
										throw new FailedPredicateException(this, "precpred(_ctx, 1)");
									setState(255);
									match(RightShift);
									setState(256);
									addSubExpression(0);
								}
								break;
							}
						}
					}
					setState(261);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 20, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final AddSubExpressionContext addSubExpression() throws RecognitionException {
		return addSubExpression(0);
	}

	private AddSubExpressionContext addSubExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		AddSubExpressionContext _localctx = new AddSubExpressionContext(_ctx, _parentState);
		AddSubExpressionContext _prevctx = _localctx;
		int _startState = 38;
		enterRecursionRule(_localctx, 38, RULE_addSubExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new AddSub_mulDivRemContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(263);
					mulDivRemExpression(0);
				}
				_ctx.stop = _input.LT(-1);
				setState(273);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 22, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							setState(271);
							switch (getInterpreter().adaptivePredict(_input, 21, _ctx)) {
								case 1: {
									_localctx = new AddSub_addContext(new AddSubExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_addSubExpression);
									setState(265);
									if (!(precpred(_ctx, 2)))
										throw new FailedPredicateException(this, "precpred(_ctx, 2)");
									setState(266);
									match(Plus);
									setState(267);
									mulDivRemExpression(0);
								}
								break;
								case 2: {
									_localctx = new AddSub_subContext(new AddSubExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_addSubExpression);
									setState(268);
									if (!(precpred(_ctx, 1)))
										throw new FailedPredicateException(this, "precpred(_ctx, 1)");
									setState(269);
									match(Minus);
									setState(270);
									mulDivRemExpression(0);
								}
								break;
							}
						}
					}
					setState(275);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 22, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final MulDivRemExpressionContext mulDivRemExpression() throws RecognitionException {
		return mulDivRemExpression(0);
	}

	private MulDivRemExpressionContext mulDivRemExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		MulDivRemExpressionContext _localctx = new MulDivRemExpressionContext(_ctx, _parentState);
		MulDivRemExpressionContext _prevctx = _localctx;
		int _startState = 40;
		enterRecursionRule(_localctx, 40, RULE_mulDivRemExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new MulDivRem_creationContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(277);
					creationExpression();
				}
				_ctx.stop = _input.LT(-1);
				setState(290);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 24, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							setState(288);
							switch (getInterpreter().adaptivePredict(_input, 23, _ctx)) {
								case 1: {
									_localctx = new MulDivRem_mulContext(new MulDivRemExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_mulDivRemExpression);
									setState(279);
									if (!(precpred(_ctx, 3)))
										throw new FailedPredicateException(this, "precpred(_ctx, 3)");
									setState(280);
									match(Star);
									setState(281);
									creationExpression();
								}
								break;
								case 2: {
									_localctx = new MulDivRem_divContext(new MulDivRemExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_mulDivRemExpression);
									setState(282);
									if (!(precpred(_ctx, 2)))
										throw new FailedPredicateException(this, "precpred(_ctx, 2)");
									setState(283);
									match(Div);
									setState(284);
									creationExpression();
								}
								break;
								case 3: {
									_localctx = new MulDivRem_remContext(new MulDivRemExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_mulDivRemExpression);
									setState(285);
									if (!(precpred(_ctx, 1)))
										throw new FailedPredicateException(this, "precpred(_ctx, 1)");
									setState(286);
									match(Mod);
									setState(287);
									creationExpression();
								}
								break;
							}
						}
					}
					setState(292);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 24, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final CreationExpressionContext creationExpression() throws RecognitionException {
		CreationExpressionContext _localctx = new CreationExpressionContext(_ctx, getState());
		enterRule(_localctx, 42, RULE_creationExpression);
		try {
			setState(305);
			switch (getInterpreter().adaptivePredict(_input, 26, _ctx)) {
				case 1:
					_localctx = new Creation_dimContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(293);
					match(New);
					setState(294);
					type();
					setState(296);
					switch (getInterpreter().adaptivePredict(_input, 25, _ctx)) {
						case 1: {
							setState(295);
							dimensionExpression();
						}
						break;
					}
				}
				break;
				case 2:
					_localctx = new Creation_paraContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(298);
					match(New);
					setState(299);
					typeArray(0);
					setState(300);
					match(LeftParen);
					setState(301);
					expression();
					setState(302);
					match(RightParen);
				}
				break;
				case 3:
					_localctx = new Creation_prefixContext(_localctx);
					enterOuterAlt(_localctx, 3);
				{
					setState(304);
					prefixExpression();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final DimensionExpressionContext dimensionExpression() throws RecognitionException {
		DimensionExpressionContext _localctx = new DimensionExpressionContext(_ctx, getState());
		enterRule(_localctx, 44, RULE_dimensionExpression);
		try {
			setState(317);
			switch (getInterpreter().adaptivePredict(_input, 27, _ctx)) {
				case 1:
					_localctx = new Dimension_Context(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(307);
					match(LeftBracket);
					setState(308);
					expression();
					setState(309);
					match(RightBracket);
				}
				break;
				case 2:
					_localctx = new Dimension_dimContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(311);
					match(LeftBracket);
					setState(312);
					expression();
					setState(313);
					match(RightBracket);
					setState(314);
					dimensionExpression();
				}
				break;
				case 3:
					_localctx = new Dimension_voidContext(_localctx);
					enterOuterAlt(_localctx, 3);
				{
					setState(316);
					dimensionVoidExpression();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final DimensionVoidExpressionContext dimensionVoidExpression() throws RecognitionException {
		DimensionVoidExpressionContext _localctx = new DimensionVoidExpressionContext(_ctx, getState());
		enterRule(_localctx, 46, RULE_dimensionVoidExpression);
		try {
			setState(324);
			switch (getInterpreter().adaptivePredict(_input, 28, _ctx)) {
				case 1:
					_localctx = new DimVoid_Context(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(319);
					match(LeftBracket);
					setState(320);
					match(RightBracket);
				}
				break;
				case 2:
					_localctx = new DimVoid_dContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(321);
					match(LeftBracket);
					setState(322);
					match(RightBracket);
					setState(323);
					dimensionVoidExpression();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final PrefixExpressionContext prefixExpression() throws RecognitionException {
		PrefixExpressionContext _localctx = new PrefixExpressionContext(_ctx, getState());
		enterRule(_localctx, 48, RULE_prefixExpression);
		try {
			setState(339);
			switch (_input.LA(1)) {
				case Null:
				case True:
				case False:
				case LeftParen:
				case ID:
				case IntLiteral:
				case StringLiteral:
					_localctx = new Prefix_postfixContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(326);
					postfixExpression(0);
				}
				break;
				case Plus:
					_localctx = new Prefix_positiveContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(327);
					match(Plus);
					setState(328);
					prefixExpression();
				}
				break;
				case Minus:
					_localctx = new Prefix_negativeContext(_localctx);
					enterOuterAlt(_localctx, 3);
				{
					setState(329);
					match(Minus);
					setState(330);
					prefixExpression();
				}
				break;
				case Not:
					_localctx = new Prefix_notContext(_localctx);
					enterOuterAlt(_localctx, 4);
				{
					setState(331);
					match(Not);
					setState(332);
					prefixExpression();
				}
				break;
				case Tilde:
					_localctx = new Prefix_tildeContext(_localctx);
					enterOuterAlt(_localctx, 5);
				{
					setState(333);
					match(Tilde);
					setState(334);
					prefixExpression();
				}
				break;
				case PlusPlus:
					_localctx = new Prefix_plusPlusContext(_localctx);
					enterOuterAlt(_localctx, 6);
				{
					setState(335);
					match(PlusPlus);
					setState(336);
					prefixExpression();
				}
				break;
				case MinusMinus:
					_localctx = new Prefix_minusMinusContext(_localctx);
					enterOuterAlt(_localctx, 7);
				{
					setState(337);
					match(MinusMinus);
					setState(338);
					prefixExpression();
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final PostfixExpressionContext postfixExpression() throws RecognitionException {
		return postfixExpression(0);
	}

	private PostfixExpressionContext postfixExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		PostfixExpressionContext _localctx = new PostfixExpressionContext(_ctx, _parentState);
		PostfixExpressionContext _prevctx = _localctx;
		int _startState = 50;
		enterRecursionRule(_localctx, 50, RULE_postfixExpression, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
				{
					_localctx = new Postfix_primaryContext(_localctx);
					_ctx = _localctx;
					_prevctx = _localctx;

					setState(342);
					primaryExpression();
				}
				_ctx.stop = _input.LT(-1);
				setState(364);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input, 32, _ctx);
				while (_alt != 2 && _alt != org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER) {
					if (_alt == 1) {
						if (_parseListeners != null) triggerExitRuleEvent();
						_prevctx = _localctx;
						{
							setState(362);
							switch (getInterpreter().adaptivePredict(_input, 31, _ctx)) {
								case 1: {
									_localctx = new Postfix_expressionContext(new PostfixExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_postfixExpression);
									setState(344);
									if (!(precpred(_ctx, 5)))
										throw new FailedPredicateException(this, "precpred(_ctx, 5)");
									setState(345);
									match(LeftBracket);
									setState(346);
									expression();
									setState(347);
									match(RightBracket);
								}
								break;
								case 2: {
									_localctx = new Postfix_argumentContext(new PostfixExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_postfixExpression);
									setState(349);
									if (!(precpred(_ctx, 4)))
										throw new FailedPredicateException(this, "precpred(_ctx, 4)");
									setState(350);
									match(LeftParen);
									setState(352);
									_la = _input.LA(1);
									if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Null) | (1L << True) | (1L << False) | (1L << New) | (1L << LeftParen) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
										{
											setState(351);
											argumentExpressionList();
										}
									}

									setState(354);
									match(RightParen);
								}
								break;
								case 3: {
									_localctx = new Postfix_idContext(new PostfixExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_postfixExpression);
									setState(355);
									if (!(precpred(_ctx, 3)))
										throw new FailedPredicateException(this, "precpred(_ctx, 3)");
									setState(356);
									match(Dot);
									setState(357);
									match(ID);
								}
								break;
								case 4: {
									_localctx = new Postfix_increContext(new PostfixExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_postfixExpression);
									setState(358);
									if (!(precpred(_ctx, 2)))
										throw new FailedPredicateException(this, "precpred(_ctx, 2)");
									setState(359);
									match(PlusPlus);
								}
								break;
								case 5: {
									_localctx = new Postfix_decreContext(new PostfixExpressionContext(_parentctx, _parentState));
									pushNewRecursionContext(_localctx, _startState, RULE_postfixExpression);
									setState(360);
									if (!(precpred(_ctx, 1)))
										throw new FailedPredicateException(this, "precpred(_ctx, 1)");
									setState(361);
									match(MinusMinus);
								}
								break;
							}
						}
					}
					setState(366);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input, 32, _ctx);
				}
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public final PrimaryExpressionContext primaryExpression() throws RecognitionException {
		PrimaryExpressionContext _localctx = new PrimaryExpressionContext(_ctx, getState());
		enterRule(_localctx, 52, RULE_primaryExpression);
		try {
			setState(373);
			switch (_input.LA(1)) {
				case ID:
					_localctx = new Primary_idContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(367);
					match(ID);
				}
				break;
				case Null:
				case True:
				case False:
				case IntLiteral:
				case StringLiteral:
					_localctx = new Primary_constantContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(368);
					constant();
				}
				break;
				case LeftParen:
					_localctx = new Primary_expressionContext(_localctx);
					enterOuterAlt(_localctx, 3);
				{
					setState(369);
					match(LeftParen);
					setState(370);
					expression();
					setState(371);
					match(RightParen);
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ConstantContext constant() throws RecognitionException {
		ConstantContext _localctx = new ConstantContext(_ctx, getState());
		enterRule(_localctx, 54, RULE_constant);
		try {
			setState(379);
			switch (_input.LA(1)) {
				case Null:
					_localctx = new Constant_nullContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(375);
					match(Null);
				}
				break;
				case IntLiteral:
					_localctx = new Constant_intContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(376);
					match(IntLiteral);
				}
				break;
				case StringLiteral:
					_localctx = new Constant_stringContext(_localctx);
					enterOuterAlt(_localctx, 3);
				{
					setState(377);
					match(StringLiteral);
				}
				break;
				case True:
				case False:
					_localctx = new Constant_logicContext(_localctx);
					enterOuterAlt(_localctx, 4);
				{
					setState(378);
					logicConstant();
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final LogicConstantContext logicConstant() throws RecognitionException {
		LogicConstantContext _localctx = new LogicConstantContext(_ctx, getState());
		enterRule(_localctx, 56, RULE_logicConstant);
		try {
			setState(383);
			switch (_input.LA(1)) {
				case True:
					_localctx = new Logic_trueContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(381);
					match(True);
				}
				break;
				case False:
					_localctx = new Logic_falseContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(382);
					match(False);
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ArgumentExpressionListContext argumentExpressionList() throws RecognitionException {
		ArgumentExpressionListContext _localctx = new ArgumentExpressionListContext(_ctx, getState());
		enterRule(_localctx, 58, RULE_argumentExpressionList);
		try {
			setState(390);
			switch (getInterpreter().adaptivePredict(_input, 36, _ctx)) {
				case 1:
					_localctx = new Argument_expressionContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(385);
					expression();
				}
				break;
				case 2:
					_localctx = new Argument_expressionListContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(386);
					expression();
					setState(387);
					match(Comma);
					setState(388);
					argumentExpressionList();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final SelectionStatementContext selectionStatement() throws RecognitionException {
		SelectionStatementContext _localctx = new SelectionStatementContext(_ctx, getState());
		enterRule(_localctx, 60, RULE_selectionStatement);
		try {
			setState(406);
			switch (getInterpreter().adaptivePredict(_input, 37, _ctx)) {
				case 1:
					_localctx = new Selection_ifContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(392);
					match(If);
					setState(393);
					match(LeftParen);
					setState(394);
					expression();
					setState(395);
					match(RightParen);
					setState(396);
					statement();
				}
				break;
				case 2:
					_localctx = new Selection_ifElseContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(398);
					match(If);
					setState(399);
					match(LeftParen);
					setState(400);
					expression();
					setState(401);
					match(RightParen);
					setState(402);
					statement();
					setState(403);
					match(Else);
					setState(404);
					statement();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final IterationStatementContext iterationStatement() throws RecognitionException {
		IterationStatementContext _localctx = new IterationStatementContext(_ctx, getState());
		enterRule(_localctx, 62, RULE_iterationStatement);
		try {
			setState(410);
			switch (_input.LA(1)) {
				case While:
					enterOuterAlt(_localctx, 1);
				{
					setState(408);
					whileStatement();
				}
				break;
				case For:
					enterOuterAlt(_localctx, 2);
				{
					setState(409);
					forStatement();
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final WhileStatementContext whileStatement() throws RecognitionException {
		WhileStatementContext _localctx = new WhileStatementContext(_ctx, getState());
		enterRule(_localctx, 64, RULE_whileStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(412);
				match(While);
				setState(413);
				match(LeftParen);
				setState(414);
				expression();
				setState(415);
				match(RightParen);
				setState(416);
				statement();
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ForStatementContext forStatement() throws RecognitionException {
		ForStatementContext _localctx = new ForStatementContext(_ctx, getState());
		enterRule(_localctx, 66, RULE_forStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(418);
				match(For);
				setState(419);
				match(LeftParen);
				setState(421);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Null) | (1L << True) | (1L << False) | (1L << New) | (1L << LeftParen) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
					{
						setState(420);
						expression();
					}
				}

				setState(423);
				match(Semi);
				setState(425);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Null) | (1L << True) | (1L << False) | (1L << New) | (1L << LeftParen) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
					{
						setState(424);
						expression();
					}
				}

				setState(427);
				match(Semi);
				setState(429);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Null) | (1L << True) | (1L << False) | (1L << New) | (1L << LeftParen) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
					{
						setState(428);
						expression();
					}
				}

				setState(431);
				match(RightParen);
				setState(432);
				statement();
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final JumpStatementContext jumpStatement() throws RecognitionException {
		JumpStatementContext _localctx = new JumpStatementContext(_ctx, getState());
		enterRule(_localctx, 68, RULE_jumpStatement);
		try {
			setState(437);
			switch (_input.LA(1)) {
				case Return:
					enterOuterAlt(_localctx, 1);
				{
					setState(434);
					returnStatement();
				}
				break;
				case Break:
					enterOuterAlt(_localctx, 2);
				{
					setState(435);
					breakStatement();
				}
				break;
				case Continue:
					enterOuterAlt(_localctx, 3);
				{
					setState(436);
					continueStatement();
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ReturnStatementContext returnStatement() throws RecognitionException {
		ReturnStatementContext _localctx = new ReturnStatementContext(_ctx, getState());
		enterRule(_localctx, 70, RULE_returnStatement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(439);
				match(Return);
				setState(441);
				_la = _input.LA(1);
				if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Null) | (1L << True) | (1L << False) | (1L << New) | (1L << LeftParen) | (1L << Plus) | (1L << PlusPlus) | (1L << Minus) | (1L << MinusMinus) | (1L << Not) | (1L << Tilde) | (1L << ID) | (1L << IntLiteral) | (1L << StringLiteral))) != 0)) {
					{
						setState(440);
						expression();
					}
				}

				setState(443);
				match(Semi);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final BreakStatementContext breakStatement() throws RecognitionException {
		BreakStatementContext _localctx = new BreakStatementContext(_ctx, getState());
		enterRule(_localctx, 72, RULE_breakStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(445);
				match(Break);
				setState(446);
				match(Semi);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ContinueStatementContext continueStatement() throws RecognitionException {
		ContinueStatementContext _localctx = new ContinueStatementContext(_ctx, getState());
		enterRule(_localctx, 74, RULE_continueStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(448);
				match(Continue);
				setState(449);
				match(Semi);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final VariableDeclarationStatementContext variableDeclarationStatement() throws RecognitionException {
		VariableDeclarationStatementContext _localctx = new VariableDeclarationStatementContext(_ctx, getState());
		enterRule(_localctx, 76, RULE_variableDeclarationStatement);
		try {
			enterOuterAlt(_localctx, 1);
			{
				setState(451);
				variableDeclaration();
				setState(452);
				match(Semi);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final VariableDeclarationContext variableDeclaration() throws RecognitionException {
		VariableDeclarationContext _localctx = new VariableDeclarationContext(_ctx, getState());
		enterRule(_localctx, 78, RULE_variableDeclaration);
		try {
			setState(462);
			switch (getInterpreter().adaptivePredict(_input, 44, _ctx)) {
				case 1:
					_localctx = new VarDecl_Context(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(454);
					typeArray(0);
					setState(455);
					match(ID);
				}
				break;
				case 2:
					_localctx = new VarDecl_initContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(457);
					typeArray(0);
					setState(458);
					match(ID);
					setState(459);
					match(Assign);
					setState(460);
					expression();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final FunctionDeclarationContext functionDeclaration() throws RecognitionException {
		FunctionDeclarationContext _localctx = new FunctionDeclarationContext(_ctx, getState());
		enterRule(_localctx, 80, RULE_functionDeclaration);
		int _la;
		try {
			setState(481);
			switch (_input.LA(1)) {
				case Int:
				case Bool:
				case String:
				case ID:
					_localctx = new FunctionDecl_returnTypeContext(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(464);
					typeArray(0);
					setState(465);
					match(ID);
					setState(466);
					match(LeftParen);
					setState(468);
					_la = _input.LA(1);
					if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Int) | (1L << Bool) | (1L << String) | (1L << ID))) != 0)) {
						{
							setState(467);
							parameterList();
						}
					}

					setState(470);
					match(RightParen);
					setState(471);
					blockStatement();
				}
				break;
				case Void:
					_localctx = new FunctionDecl_voidContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(473);
					match(Void);
					setState(474);
					match(ID);
					setState(475);
					match(LeftParen);
					setState(477);
					_la = _input.LA(1);
					if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Int) | (1L << Bool) | (1L << String) | (1L << ID))) != 0)) {
						{
							setState(476);
							parameterList();
						}
					}

					setState(479);
					match(RightParen);
					setState(480);
					blockStatement();
				}
				break;
				default:
					throw new NoViableAltException(this);
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public final ParameterListContext parameterList() throws RecognitionException {
		ParameterListContext _localctx = new ParameterListContext(_ctx, getState());
		enterRule(_localctx, 82, RULE_parameterList);
		try {
			setState(491);
			switch (getInterpreter().adaptivePredict(_input, 48, _ctx)) {
				case 1:
					_localctx = new Parameter_Context(_localctx);
					enterOuterAlt(_localctx, 1);
				{
					setState(483);
					typeArray(0);
					setState(484);
					match(ID);
				}
				break;
				case 2:
					_localctx = new Parameter_listContext(_localctx);
					enterOuterAlt(_localctx, 2);
				{
					setState(486);
					typeArray(0);
					setState(487);
					match(ID);
					setState(488);
					match(Comma);
					setState(489);
					parameterList();
				}
				break;
			}
		} catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		} finally {
			exitRule();
		}
		return _localctx;
	}

	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
			case 3:
				return typeArray_sempred((TypeArrayContext) _localctx, predIndex);
			case 11:
				return logicalOrExpression_sempred((LogicalOrExpressionContext) _localctx, predIndex);
			case 12:
				return logicalAndExpression_sempred((LogicalAndExpressionContext) _localctx, predIndex);
			case 13:
				return bitwiseOrExpression_sempred((BitwiseOrExpressionContext) _localctx, predIndex);
			case 14:
				return bitwiseXorExpression_sempred((BitwiseXorExpressionContext) _localctx, predIndex);
			case 15:
				return bitwiseAndExpression_sempred((BitwiseAndExpressionContext) _localctx, predIndex);
			case 16:
				return equalityExpression_sempred((EqualityExpressionContext) _localctx, predIndex);
			case 17:
				return relationalExpression_sempred((RelationalExpressionContext) _localctx, predIndex);
			case 18:
				return shiftExpression_sempred((ShiftExpressionContext) _localctx, predIndex);
			case 19:
				return addSubExpression_sempred((AddSubExpressionContext) _localctx, predIndex);
			case 20:
				return mulDivRemExpression_sempred((MulDivRemExpressionContext) _localctx, predIndex);
			case 25:
				return postfixExpression_sempred((PostfixExpressionContext) _localctx, predIndex);
		}
		return true;
	}

	private boolean typeArray_sempred(TypeArrayContext _localctx, int predIndex) {
		switch (predIndex) {
			case 0:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean logicalOrExpression_sempred(LogicalOrExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 1:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean logicalAndExpression_sempred(LogicalAndExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 2:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean bitwiseOrExpression_sempred(BitwiseOrExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 3:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean bitwiseXorExpression_sempred(BitwiseXorExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 4:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean bitwiseAndExpression_sempred(BitwiseAndExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 5:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean equalityExpression_sempred(EqualityExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 6:
				return precpred(_ctx, 2);
			case 7:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean relationalExpression_sempred(RelationalExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 8:
				return precpred(_ctx, 4);
			case 9:
				return precpred(_ctx, 3);
			case 10:
				return precpred(_ctx, 2);
			case 11:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean shiftExpression_sempred(ShiftExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 12:
				return precpred(_ctx, 2);
			case 13:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean addSubExpression_sempred(AddSubExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 14:
				return precpred(_ctx, 2);
			case 15:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean mulDivRemExpression_sempred(MulDivRemExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 16:
				return precpred(_ctx, 3);
			case 17:
				return precpred(_ctx, 2);
			case 18:
				return precpred(_ctx, 1);
		}
		return true;
	}

	private boolean postfixExpression_sempred(PostfixExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
			case 19:
				return precpred(_ctx, 5);
			case 20:
				return precpred(_ctx, 4);
			case 21:
				return precpred(_ctx, 3);
			case 22:
				return precpred(_ctx, 2);
			case 23:
				return precpred(_ctx, 1);
		}
		return true;
	}

	public static class ProgramContext extends ParserRuleContext {
		public ProgramContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public List<ClassDeclarationContext> classDeclaration() {
			return getRuleContexts(ClassDeclarationContext.class);
		}

		public ClassDeclarationContext classDeclaration(int i) {
			return getRuleContext(ClassDeclarationContext.class, i);
		}

		public List<FunctionDeclarationContext> functionDeclaration() {
			return getRuleContexts(FunctionDeclarationContext.class);
		}

		public FunctionDeclarationContext functionDeclaration(int i) {
			return getRuleContext(FunctionDeclarationContext.class, i);
		}

		public List<VariableDeclarationContext> variableDeclaration() {
			return getRuleContexts(VariableDeclarationContext.class);
		}

		public VariableDeclarationContext variableDeclaration(int i) {
			return getRuleContext(VariableDeclarationContext.class, i);
		}

		@Override
		public int getRuleIndex() {
			return RULE_program;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterProgram(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitProgram(this);
		}
	}

	public static class ClassDeclarationContext extends ParserRuleContext {
		public ClassDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		public ClassMemberDeclarationListContext classMemberDeclarationList() {
			return getRuleContext(ClassMemberDeclarationListContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_classDeclaration;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterClassDeclaration(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitClassDeclaration(this);
		}
	}

	public static class ClassMemberDeclarationListContext extends ParserRuleContext {
		public ClassMemberDeclarationListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ClassMemberDeclarationListContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_classMemberDeclarationList;
		}

		public void copyFrom(ClassMemberDeclarationListContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class ClassMemDeclList_listContext extends ClassMemberDeclarationListContext {
		public ClassMemDeclList_listContext(ClassMemberDeclarationListContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		public ClassMemberDeclarationListContext classMemberDeclarationList() {
			return getRuleContext(ClassMemberDeclarationListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterClassMemDeclList_list(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitClassMemDeclList_list(this);
		}
	}

	public static class ClassMemDeclList_Context extends ClassMemberDeclarationListContext {
		public ClassMemDeclList_Context(ClassMemberDeclarationListContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterClassMemDeclList_(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitClassMemDeclList_(this);
		}
	}

	public static class TypeArrayContext extends ParserRuleContext {
		public TypeArrayContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public TypeArrayContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_typeArray;
		}

		public void copyFrom(TypeArrayContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class TypeArray_typeContext extends TypeArrayContext {
		public TypeArray_typeContext(TypeArrayContext ctx) {
			copyFrom(ctx);
		}

		public TypeContext type() {
			return getRuleContext(TypeContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterTypeArray_type(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitTypeArray_type(this);
		}
	}

	public static class TypeArray_dimContext extends TypeArrayContext {
		public TypeArray_dimContext(TypeArrayContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterTypeArray_dim(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitTypeArray_dim(this);
		}
	}

	public static class TypeContext extends ParserRuleContext {
		public TypeContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_type;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterType(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitType(this);
		}
	}

	public static class StatementContext extends ParserRuleContext {
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public BlockStatementContext blockStatement() {
			return getRuleContext(BlockStatementContext.class, 0);
		}

		public ExpressionStatementContext expressionStatement() {
			return getRuleContext(ExpressionStatementContext.class, 0);
		}

		public SelectionStatementContext selectionStatement() {
			return getRuleContext(SelectionStatementContext.class, 0);
		}

		public IterationStatementContext iterationStatement() {
			return getRuleContext(IterationStatementContext.class, 0);
		}

		public JumpStatementContext jumpStatement() {
			return getRuleContext(JumpStatementContext.class, 0);
		}

		public VariableDeclarationStatementContext variableDeclarationStatement() {
			return getRuleContext(VariableDeclarationStatementContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_statement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitStatement(this);
		}
	}

	public static class BlockStatementContext extends ParserRuleContext {
		public BlockStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public StatementListContext statementList() {
			return getRuleContext(StatementListContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_blockStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBlockStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBlockStatement(this);
		}
	}

	public static class StatementListContext extends ParserRuleContext {
		public StatementListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public StatementListContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_statementList;
		}

		public void copyFrom(StatementListContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class StatementList_stmtContext extends StatementListContext {
		public StatementList_stmtContext(StatementListContext ctx) {
			copyFrom(ctx);
		}

		public StatementContext statement() {
			return getRuleContext(StatementContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterStatementList_stmt(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitStatementList_stmt(this);
		}
	}

	public static class StatementList_listContext extends StatementListContext {
		public StatementList_listContext(StatementListContext ctx) {
			copyFrom(ctx);
		}

		public StatementContext statement() {
			return getRuleContext(StatementContext.class, 0);
		}

		public StatementListContext statementList() {
			return getRuleContext(StatementListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterStatementList_list(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitStatementList_list(this);
		}
	}

	public static class ExpressionStatementContext extends ParserRuleContext {
		public ExpressionStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_expressionStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterExpressionStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitExpressionStatement(this);
		}
	}

	public static class ExpressionContext extends ParserRuleContext {
		public ExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public AssignmentExpressionContext assignmentExpression() {
			return getRuleContext(AssignmentExpressionContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_expression;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterExpression(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitExpression(this);
		}
	}

	public static class AssignmentExpressionContext extends ParserRuleContext {
		public AssignmentExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public AssignmentExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_assignmentExpression;
		}

		public void copyFrom(AssignmentExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Assignment_assignContext extends AssignmentExpressionContext {
		public Assignment_assignContext(AssignmentExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		public AssignmentExpressionContext assignmentExpression() {
			return getRuleContext(AssignmentExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterAssignment_assign(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitAssignment_assign(this);
		}
	}

	public static class Assignment_logicalOrContext extends AssignmentExpressionContext {
		public Assignment_logicalOrContext(AssignmentExpressionContext ctx) {
			copyFrom(ctx);
		}

		public LogicalOrExpressionContext logicalOrExpression() {
			return getRuleContext(LogicalOrExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterAssignment_logicalOr(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitAssignment_logicalOr(this);
		}
	}

	public static class LogicalOrExpressionContext extends ParserRuleContext {
		public LogicalOrExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public LogicalOrExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_logicalOrExpression;
		}

		public void copyFrom(LogicalOrExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class LogicalOr_orContext extends LogicalOrExpressionContext {
		public LogicalOr_orContext(LogicalOrExpressionContext ctx) {
			copyFrom(ctx);
		}

		public LogicalOrExpressionContext logicalOrExpression() {
			return getRuleContext(LogicalOrExpressionContext.class, 0);
		}

		public LogicalAndExpressionContext logicalAndExpression() {
			return getRuleContext(LogicalAndExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterLogicalOr_or(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitLogicalOr_or(this);
		}
	}

	public static class LogicalOr_logicalAndContext extends LogicalOrExpressionContext {
		public LogicalOr_logicalAndContext(LogicalOrExpressionContext ctx) {
			copyFrom(ctx);
		}

		public LogicalAndExpressionContext logicalAndExpression() {
			return getRuleContext(LogicalAndExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterLogicalOr_logicalAnd(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitLogicalOr_logicalAnd(this);
		}
	}

	public static class LogicalAndExpressionContext extends ParserRuleContext {
		public LogicalAndExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public LogicalAndExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_logicalAndExpression;
		}

		public void copyFrom(LogicalAndExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class LogicalAnd_bitwiseOrContext extends LogicalAndExpressionContext {
		public LogicalAnd_bitwiseOrContext(LogicalAndExpressionContext ctx) {
			copyFrom(ctx);
		}

		public BitwiseOrExpressionContext bitwiseOrExpression() {
			return getRuleContext(BitwiseOrExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterLogicalAnd_bitwiseOr(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitLogicalAnd_bitwiseOr(this);
		}
	}

	public static class LogicalAnd_andContext extends LogicalAndExpressionContext {
		public LogicalAnd_andContext(LogicalAndExpressionContext ctx) {
			copyFrom(ctx);
		}

		public LogicalAndExpressionContext logicalAndExpression() {
			return getRuleContext(LogicalAndExpressionContext.class, 0);
		}

		public BitwiseOrExpressionContext bitwiseOrExpression() {
			return getRuleContext(BitwiseOrExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterLogicalAnd_and(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitLogicalAnd_and(this);
		}
	}

	public static class BitwiseOrExpressionContext extends ParserRuleContext {
		public BitwiseOrExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public BitwiseOrExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_bitwiseOrExpression;
		}

		public void copyFrom(BitwiseOrExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class BitwiseOr_bitwiseXorContext extends BitwiseOrExpressionContext {
		public BitwiseOr_bitwiseXorContext(BitwiseOrExpressionContext ctx) {
			copyFrom(ctx);
		}

		public BitwiseXorExpressionContext bitwiseXorExpression() {
			return getRuleContext(BitwiseXorExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBitwiseOr_bitwiseXor(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBitwiseOr_bitwiseXor(this);
		}
	}

	public static class BitwiseOr_orContext extends BitwiseOrExpressionContext {
		public BitwiseOr_orContext(BitwiseOrExpressionContext ctx) {
			copyFrom(ctx);
		}

		public BitwiseOrExpressionContext bitwiseOrExpression() {
			return getRuleContext(BitwiseOrExpressionContext.class, 0);
		}

		public BitwiseXorExpressionContext bitwiseXorExpression() {
			return getRuleContext(BitwiseXorExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBitwiseOr_or(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBitwiseOr_or(this);
		}
	}

	public static class BitwiseXorExpressionContext extends ParserRuleContext {
		public BitwiseXorExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public BitwiseXorExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_bitwiseXorExpression;
		}

		public void copyFrom(BitwiseXorExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class BitwiseXor_bitwiseAndContext extends BitwiseXorExpressionContext {
		public BitwiseXor_bitwiseAndContext(BitwiseXorExpressionContext ctx) {
			copyFrom(ctx);
		}

		public BitwiseAndExpressionContext bitwiseAndExpression() {
			return getRuleContext(BitwiseAndExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBitwiseXor_bitwiseAnd(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBitwiseXor_bitwiseAnd(this);
		}
	}

	public static class BitwiseXor_xorContext extends BitwiseXorExpressionContext {
		public BitwiseXor_xorContext(BitwiseXorExpressionContext ctx) {
			copyFrom(ctx);
		}

		public BitwiseXorExpressionContext bitwiseXorExpression() {
			return getRuleContext(BitwiseXorExpressionContext.class, 0);
		}

		public BitwiseAndExpressionContext bitwiseAndExpression() {
			return getRuleContext(BitwiseAndExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBitwiseXor_xor(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBitwiseXor_xor(this);
		}
	}

	public static class BitwiseAndExpressionContext extends ParserRuleContext {
		public BitwiseAndExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public BitwiseAndExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_bitwiseAndExpression;
		}

		public void copyFrom(BitwiseAndExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class BitwiseAnd_andContext extends BitwiseAndExpressionContext {
		public BitwiseAnd_andContext(BitwiseAndExpressionContext ctx) {
			copyFrom(ctx);
		}

		public BitwiseAndExpressionContext bitwiseAndExpression() {
			return getRuleContext(BitwiseAndExpressionContext.class, 0);
		}

		public EqualityExpressionContext equalityExpression() {
			return getRuleContext(EqualityExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBitwiseAnd_and(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBitwiseAnd_and(this);
		}
	}

	public static class BitwiseAnd_equalContext extends BitwiseAndExpressionContext {
		public BitwiseAnd_equalContext(BitwiseAndExpressionContext ctx) {
			copyFrom(ctx);
		}

		public EqualityExpressionContext equalityExpression() {
			return getRuleContext(EqualityExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBitwiseAnd_equal(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBitwiseAnd_equal(this);
		}
	}

	public static class EqualityExpressionContext extends ParserRuleContext {
		public EqualityExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public EqualityExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_equalityExpression;
		}

		public void copyFrom(EqualityExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Equality_relationalContext extends EqualityExpressionContext {
		public Equality_relationalContext(EqualityExpressionContext ctx) {
			copyFrom(ctx);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterEquality_relational(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitEquality_relational(this);
		}
	}

	public static class Equality_notEqualContext extends EqualityExpressionContext {
		public Equality_notEqualContext(EqualityExpressionContext ctx) {
			copyFrom(ctx);
		}

		public EqualityExpressionContext equalityExpression() {
			return getRuleContext(EqualityExpressionContext.class, 0);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterEquality_notEqual(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitEquality_notEqual(this);
		}
	}

	public static class Equality_equalContext extends EqualityExpressionContext {
		public Equality_equalContext(EqualityExpressionContext ctx) {
			copyFrom(ctx);
		}

		public EqualityExpressionContext equalityExpression() {
			return getRuleContext(EqualityExpressionContext.class, 0);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterEquality_equal(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitEquality_equal(this);
		}
	}

	public static class RelationalExpressionContext extends ParserRuleContext {
		public RelationalExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public RelationalExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_relationalExpression;
		}

		public void copyFrom(RelationalExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Relational_shiftContext extends RelationalExpressionContext {
		public Relational_shiftContext(RelationalExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterRelational_shift(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitRelational_shift(this);
		}
	}

	public static class Relational_geqContext extends RelationalExpressionContext {
		public Relational_geqContext(RelationalExpressionContext ctx) {
			copyFrom(ctx);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterRelational_geq(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitRelational_geq(this);
		}
	}

	public static class Relational_greaterContext extends RelationalExpressionContext {
		public Relational_greaterContext(RelationalExpressionContext ctx) {
			copyFrom(ctx);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterRelational_greater(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitRelational_greater(this);
		}
	}

	public static class Relational_leqContext extends RelationalExpressionContext {
		public Relational_leqContext(RelationalExpressionContext ctx) {
			copyFrom(ctx);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterRelational_leq(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitRelational_leq(this);
		}
	}

	public static class Relational_lessContext extends RelationalExpressionContext {
		public Relational_lessContext(RelationalExpressionContext ctx) {
			copyFrom(ctx);
		}

		public RelationalExpressionContext relationalExpression() {
			return getRuleContext(RelationalExpressionContext.class, 0);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterRelational_less(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitRelational_less(this);
		}
	}

	public static class ShiftExpressionContext extends ParserRuleContext {
		public ShiftExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ShiftExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_shiftExpression;
		}

		public void copyFrom(ShiftExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Shift_leftShiftContext extends ShiftExpressionContext {
		public Shift_leftShiftContext(ShiftExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		public AddSubExpressionContext addSubExpression() {
			return getRuleContext(AddSubExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterShift_leftShift(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitShift_leftShift(this);
		}
	}

	public static class Shift_addSubContext extends ShiftExpressionContext {
		public Shift_addSubContext(ShiftExpressionContext ctx) {
			copyFrom(ctx);
		}

		public AddSubExpressionContext addSubExpression() {
			return getRuleContext(AddSubExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterShift_addSub(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitShift_addSub(this);
		}
	}

	public static class Shift_rightShiftContext extends ShiftExpressionContext {
		public Shift_rightShiftContext(ShiftExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ShiftExpressionContext shiftExpression() {
			return getRuleContext(ShiftExpressionContext.class, 0);
		}

		public AddSubExpressionContext addSubExpression() {
			return getRuleContext(AddSubExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterShift_rightShift(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitShift_rightShift(this);
		}
	}

	public static class AddSubExpressionContext extends ParserRuleContext {
		public AddSubExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public AddSubExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_addSubExpression;
		}

		public void copyFrom(AddSubExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class AddSub_mulDivRemContext extends AddSubExpressionContext {
		public AddSub_mulDivRemContext(AddSubExpressionContext ctx) {
			copyFrom(ctx);
		}

		public MulDivRemExpressionContext mulDivRemExpression() {
			return getRuleContext(MulDivRemExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterAddSub_mulDivRem(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitAddSub_mulDivRem(this);
		}
	}

	public static class AddSub_subContext extends AddSubExpressionContext {
		public AddSub_subContext(AddSubExpressionContext ctx) {
			copyFrom(ctx);
		}

		public AddSubExpressionContext addSubExpression() {
			return getRuleContext(AddSubExpressionContext.class, 0);
		}

		public MulDivRemExpressionContext mulDivRemExpression() {
			return getRuleContext(MulDivRemExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterAddSub_sub(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitAddSub_sub(this);
		}
	}

	public static class AddSub_addContext extends AddSubExpressionContext {
		public AddSub_addContext(AddSubExpressionContext ctx) {
			copyFrom(ctx);
		}

		public AddSubExpressionContext addSubExpression() {
			return getRuleContext(AddSubExpressionContext.class, 0);
		}

		public MulDivRemExpressionContext mulDivRemExpression() {
			return getRuleContext(MulDivRemExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterAddSub_add(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitAddSub_add(this);
		}
	}

	public static class MulDivRemExpressionContext extends ParserRuleContext {
		public MulDivRemExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public MulDivRemExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_mulDivRemExpression;
		}

		public void copyFrom(MulDivRemExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class MulDivRem_remContext extends MulDivRemExpressionContext {
		public MulDivRem_remContext(MulDivRemExpressionContext ctx) {
			copyFrom(ctx);
		}

		public MulDivRemExpressionContext mulDivRemExpression() {
			return getRuleContext(MulDivRemExpressionContext.class, 0);
		}

		public CreationExpressionContext creationExpression() {
			return getRuleContext(CreationExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterMulDivRem_rem(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitMulDivRem_rem(this);
		}
	}

	public static class MulDivRem_divContext extends MulDivRemExpressionContext {
		public MulDivRem_divContext(MulDivRemExpressionContext ctx) {
			copyFrom(ctx);
		}

		public MulDivRemExpressionContext mulDivRemExpression() {
			return getRuleContext(MulDivRemExpressionContext.class, 0);
		}

		public CreationExpressionContext creationExpression() {
			return getRuleContext(CreationExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterMulDivRem_div(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitMulDivRem_div(this);
		}
	}

	public static class MulDivRem_creationContext extends MulDivRemExpressionContext {
		public MulDivRem_creationContext(MulDivRemExpressionContext ctx) {
			copyFrom(ctx);
		}

		public CreationExpressionContext creationExpression() {
			return getRuleContext(CreationExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterMulDivRem_creation(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitMulDivRem_creation(this);
		}
	}

	public static class MulDivRem_mulContext extends MulDivRemExpressionContext {
		public MulDivRem_mulContext(MulDivRemExpressionContext ctx) {
			copyFrom(ctx);
		}

		public MulDivRemExpressionContext mulDivRemExpression() {
			return getRuleContext(MulDivRemExpressionContext.class, 0);
		}

		public CreationExpressionContext creationExpression() {
			return getRuleContext(CreationExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterMulDivRem_mul(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitMulDivRem_mul(this);
		}
	}

	public static class CreationExpressionContext extends ParserRuleContext {
		public CreationExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public CreationExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_creationExpression;
		}

		public void copyFrom(CreationExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Creation_prefixContext extends CreationExpressionContext {
		public Creation_prefixContext(CreationExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterCreation_prefix(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitCreation_prefix(this);
		}
	}

	public static class Creation_dimContext extends CreationExpressionContext {
		public Creation_dimContext(CreationExpressionContext ctx) {
			copyFrom(ctx);
		}

		public TypeContext type() {
			return getRuleContext(TypeContext.class, 0);
		}

		public DimensionExpressionContext dimensionExpression() {
			return getRuleContext(DimensionExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterCreation_dim(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitCreation_dim(this);
		}
	}

	public static class Creation_paraContext extends CreationExpressionContext {
		public Creation_paraContext(CreationExpressionContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterCreation_para(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitCreation_para(this);
		}
	}

	public static class DimensionExpressionContext extends ParserRuleContext {
		public DimensionExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public DimensionExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_dimensionExpression;
		}

		public void copyFrom(DimensionExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Dimension_dimContext extends DimensionExpressionContext {
		public Dimension_dimContext(DimensionExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		public DimensionExpressionContext dimensionExpression() {
			return getRuleContext(DimensionExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterDimension_dim(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitDimension_dim(this);
		}
	}

	public static class Dimension_Context extends DimensionExpressionContext {
		public Dimension_Context(DimensionExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterDimension_(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitDimension_(this);
		}
	}

	public static class Dimension_voidContext extends DimensionExpressionContext {
		public Dimension_voidContext(DimensionExpressionContext ctx) {
			copyFrom(ctx);
		}

		public DimensionVoidExpressionContext dimensionVoidExpression() {
			return getRuleContext(DimensionVoidExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterDimension_void(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitDimension_void(this);
		}
	}

	public static class DimensionVoidExpressionContext extends ParserRuleContext {
		public DimensionVoidExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public DimensionVoidExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_dimensionVoidExpression;
		}

		public void copyFrom(DimensionVoidExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class DimVoid_Context extends DimensionVoidExpressionContext {
		public DimVoid_Context(DimensionVoidExpressionContext ctx) {
			copyFrom(ctx);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterDimVoid_(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitDimVoid_(this);
		}
	}

	public static class DimVoid_dContext extends DimensionVoidExpressionContext {
		public DimVoid_dContext(DimensionVoidExpressionContext ctx) {
			copyFrom(ctx);
		}

		public DimensionVoidExpressionContext dimensionVoidExpression() {
			return getRuleContext(DimensionVoidExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterDimVoid_d(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitDimVoid_d(this);
		}
	}

	public static class PrefixExpressionContext extends ParserRuleContext {
		public PrefixExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public PrefixExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_prefixExpression;
		}

		public void copyFrom(PrefixExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Prefix_postfixContext extends PrefixExpressionContext {
		public Prefix_postfixContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_postfix(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_postfix(this);
		}
	}

	public static class Prefix_negativeContext extends PrefixExpressionContext {
		public Prefix_negativeContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_negative(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_negative(this);
		}
	}

	public static class Prefix_plusPlusContext extends PrefixExpressionContext {
		public Prefix_plusPlusContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_plusPlus(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_plusPlus(this);
		}
	}

	public static class Prefix_notContext extends PrefixExpressionContext {
		public Prefix_notContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_not(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_not(this);
		}
	}

	public static class Prefix_positiveContext extends PrefixExpressionContext {
		public Prefix_positiveContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_positive(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_positive(this);
		}
	}

	public static class Prefix_tildeContext extends PrefixExpressionContext {
		public Prefix_tildeContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_tilde(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_tilde(this);
		}
	}

	public static class Prefix_minusMinusContext extends PrefixExpressionContext {
		public Prefix_minusMinusContext(PrefixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrefixExpressionContext prefixExpression() {
			return getRuleContext(PrefixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrefix_minusMinus(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrefix_minusMinus(this);
		}
	}

	public static class PostfixExpressionContext extends ParserRuleContext {
		public PostfixExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public PostfixExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_postfixExpression;
		}

		public void copyFrom(PostfixExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Postfix_idContext extends PostfixExpressionContext {
		public Postfix_idContext(PostfixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPostfix_id(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPostfix_id(this);
		}
	}

	public static class Postfix_increContext extends PostfixExpressionContext {
		public Postfix_increContext(PostfixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPostfix_incre(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPostfix_incre(this);
		}
	}

	public static class Postfix_expressionContext extends PostfixExpressionContext {
		public Postfix_expressionContext(PostfixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class, 0);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPostfix_expression(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPostfix_expression(this);
		}
	}

	public static class Postfix_primaryContext extends PostfixExpressionContext {
		public Postfix_primaryContext(PostfixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PrimaryExpressionContext primaryExpression() {
			return getRuleContext(PrimaryExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPostfix_primary(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPostfix_primary(this);
		}
	}

	public static class Postfix_argumentContext extends PostfixExpressionContext {
		public Postfix_argumentContext(PostfixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class, 0);
		}

		public ArgumentExpressionListContext argumentExpressionList() {
			return getRuleContext(ArgumentExpressionListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPostfix_argument(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPostfix_argument(this);
		}
	}

	public static class Postfix_decreContext extends PostfixExpressionContext {
		public Postfix_decreContext(PostfixExpressionContext ctx) {
			copyFrom(ctx);
		}

		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPostfix_decre(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPostfix_decre(this);
		}
	}

	public static class PrimaryExpressionContext extends ParserRuleContext {
		public PrimaryExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public PrimaryExpressionContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_primaryExpression;
		}

		public void copyFrom(PrimaryExpressionContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Primary_constantContext extends PrimaryExpressionContext {
		public Primary_constantContext(PrimaryExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ConstantContext constant() {
			return getRuleContext(ConstantContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrimary_constant(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrimary_constant(this);
		}
	}

	public static class Primary_idContext extends PrimaryExpressionContext {
		public Primary_idContext(PrimaryExpressionContext ctx) {
			copyFrom(ctx);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrimary_id(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrimary_id(this);
		}
	}

	public static class Primary_expressionContext extends PrimaryExpressionContext {
		public Primary_expressionContext(PrimaryExpressionContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterPrimary_expression(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitPrimary_expression(this);
		}
	}

	public static class ConstantContext extends ParserRuleContext {
		public ConstantContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ConstantContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_constant;
		}

		public void copyFrom(ConstantContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Constant_logicContext extends ConstantContext {
		public Constant_logicContext(ConstantContext ctx) {
			copyFrom(ctx);
		}

		public LogicConstantContext logicConstant() {
			return getRuleContext(LogicConstantContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterConstant_logic(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitConstant_logic(this);
		}
	}

	public static class Constant_stringContext extends ConstantContext {
		public Constant_stringContext(ConstantContext ctx) {
			copyFrom(ctx);
		}

		public TerminalNode StringLiteral() {
			return getToken(MagParser.StringLiteral, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterConstant_string(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitConstant_string(this);
		}
	}

	public static class Constant_nullContext extends ConstantContext {
		public Constant_nullContext(ConstantContext ctx) {
			copyFrom(ctx);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterConstant_null(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitConstant_null(this);
		}
	}

	public static class Constant_intContext extends ConstantContext {
		public Constant_intContext(ConstantContext ctx) {
			copyFrom(ctx);
		}

		public TerminalNode IntLiteral() {
			return getToken(MagParser.IntLiteral, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterConstant_int(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitConstant_int(this);
		}
	}

	public static class LogicConstantContext extends ParserRuleContext {
		public LogicConstantContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public LogicConstantContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_logicConstant;
		}

		public void copyFrom(LogicConstantContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Logic_falseContext extends LogicConstantContext {
		public Logic_falseContext(LogicConstantContext ctx) {
			copyFrom(ctx);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterLogic_false(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitLogic_false(this);
		}
	}

	public static class Logic_trueContext extends LogicConstantContext {
		public Logic_trueContext(LogicConstantContext ctx) {
			copyFrom(ctx);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterLogic_true(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitLogic_true(this);
		}
	}

	public static class ArgumentExpressionListContext extends ParserRuleContext {
		public ArgumentExpressionListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ArgumentExpressionListContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_argumentExpressionList;
		}

		public void copyFrom(ArgumentExpressionListContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Argument_expressionContext extends ArgumentExpressionListContext {
		public Argument_expressionContext(ArgumentExpressionListContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterArgument_expression(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitArgument_expression(this);
		}
	}

	public static class Argument_expressionListContext extends ArgumentExpressionListContext {
		public Argument_expressionListContext(ArgumentExpressionListContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		public ArgumentExpressionListContext argumentExpressionList() {
			return getRuleContext(ArgumentExpressionListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterArgument_expressionList(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitArgument_expressionList(this);
		}
	}

	public static class SelectionStatementContext extends ParserRuleContext {
		public SelectionStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public SelectionStatementContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_selectionStatement;
		}

		public void copyFrom(SelectionStatementContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Selection_ifContext extends SelectionStatementContext {
		public Selection_ifContext(SelectionStatementContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		public StatementContext statement() {
			return getRuleContext(StatementContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterSelection_if(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitSelection_if(this);
		}
	}

	public static class Selection_ifElseContext extends SelectionStatementContext {
		public Selection_ifElseContext(SelectionStatementContext ctx) {
			copyFrom(ctx);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}

		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class, i);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterSelection_ifElse(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitSelection_ifElse(this);
		}
	}

	public static class IterationStatementContext extends ParserRuleContext {
		public IterationStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public WhileStatementContext whileStatement() {
			return getRuleContext(WhileStatementContext.class, 0);
		}

		public ForStatementContext forStatement() {
			return getRuleContext(ForStatementContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_iterationStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterIterationStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitIterationStatement(this);
		}
	}

	public static class WhileStatementContext extends ParserRuleContext {
		public WhileStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		public StatementContext statement() {
			return getRuleContext(StatementContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_whileStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterWhileStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitWhileStatement(this);
		}
	}

	public static class ForStatementContext extends ParserRuleContext {
		public ForStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public StatementContext statement() {
			return getRuleContext(StatementContext.class, 0);
		}

		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}

		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class, i);
		}

		@Override
		public int getRuleIndex() {
			return RULE_forStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterForStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitForStatement(this);
		}
	}

	public static class JumpStatementContext extends ParserRuleContext {
		public JumpStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ReturnStatementContext returnStatement() {
			return getRuleContext(ReturnStatementContext.class, 0);
		}

		public BreakStatementContext breakStatement() {
			return getRuleContext(BreakStatementContext.class, 0);
		}

		public ContinueStatementContext continueStatement() {
			return getRuleContext(ContinueStatementContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_jumpStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterJumpStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitJumpStatement(this);
		}
	}

	public static class ReturnStatementContext extends ParserRuleContext {
		public ReturnStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_returnStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterReturnStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitReturnStatement(this);
		}
	}

	public static class BreakStatementContext extends ParserRuleContext {
		public BreakStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		@Override
		public int getRuleIndex() {
			return RULE_breakStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterBreakStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitBreakStatement(this);
		}
	}

	public static class ContinueStatementContext extends ParserRuleContext {
		public ContinueStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		@Override
		public int getRuleIndex() {
			return RULE_continueStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterContinueStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitContinueStatement(this);
		}
	}

	public static class VariableDeclarationStatementContext extends ParserRuleContext {
		public VariableDeclarationStatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public VariableDeclarationContext variableDeclaration() {
			return getRuleContext(VariableDeclarationContext.class, 0);
		}

		@Override
		public int getRuleIndex() {
			return RULE_variableDeclarationStatement;
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterVariableDeclarationStatement(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitVariableDeclarationStatement(this);
		}
	}

	public static class VariableDeclarationContext extends ParserRuleContext {
		public VariableDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public VariableDeclarationContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_variableDeclaration;
		}

		public void copyFrom(VariableDeclarationContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class VarDecl_Context extends VariableDeclarationContext {
		public VarDecl_Context(VariableDeclarationContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterVarDecl_(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitVarDecl_(this);
		}
	}

	public static class VarDecl_initContext extends VariableDeclarationContext {
		public VarDecl_initContext(VariableDeclarationContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterVarDecl_init(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitVarDecl_init(this);
		}
	}

	public static class FunctionDeclarationContext extends ParserRuleContext {
		public FunctionDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public FunctionDeclarationContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_functionDeclaration;
		}

		public void copyFrom(FunctionDeclarationContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class FunctionDecl_returnTypeContext extends FunctionDeclarationContext {
		public FunctionDecl_returnTypeContext(FunctionDeclarationContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		public BlockStatementContext blockStatement() {
			return getRuleContext(BlockStatementContext.class, 0);
		}

		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterFunctionDecl_returnType(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitFunctionDecl_returnType(this);
		}
	}

	public static class FunctionDecl_voidContext extends FunctionDeclarationContext {
		public FunctionDecl_voidContext(FunctionDeclarationContext ctx) {
			copyFrom(ctx);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		public BlockStatementContext blockStatement() {
			return getRuleContext(BlockStatementContext.class, 0);
		}

		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterFunctionDecl_void(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitFunctionDecl_void(this);
		}
	}

	public static class ParameterListContext extends ParserRuleContext {
		public ParameterListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}

		public ParameterListContext() {
		}

		@Override
		public int getRuleIndex() {
			return RULE_parameterList;
		}

		public void copyFrom(ParameterListContext ctx) {
			super.copyFrom(ctx);
		}
	}

	public static class Parameter_Context extends ParameterListContext {
		public Parameter_Context(ParameterListContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterParameter_(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitParameter_(this);
		}
	}

	public static class Parameter_listContext extends ParameterListContext {
		public Parameter_listContext(ParameterListContext ctx) {
			copyFrom(ctx);
		}

		public TypeArrayContext typeArray() {
			return getRuleContext(TypeArrayContext.class, 0);
		}

		public TerminalNode ID() {
			return getToken(MagParser.ID, 0);
		}

		public ParameterListContext parameterList() {
			return getRuleContext(ParameterListContext.class, 0);
		}

		@Override
		public void enterRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).enterParameter_list(this);
		}

		@Override
		public void exitRule(ParseTreeListener listener) {
			if (listener instanceof MagListener) ((MagListener) listener).exitParameter_list(this);
		}
	}
}
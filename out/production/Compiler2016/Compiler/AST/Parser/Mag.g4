grammar Mag;

program
	:	(classDeclaration | functionDeclaration | variableDeclaration ';')+
	;

classDeclaration
	:	'class' ID '{' classMemberDeclarationList? '}'
	;

classMemberDeclarationList
	:	typeArray ID ';' # classMemDeclList_
	|	typeArray ID ';' classMemberDeclarationList # classMemDeclList_list
	;
/*
classDeclaration
	:	'class' ID '{' (typeArray ID ';')* '}'
	;
*/
typeArray
	:	type # typeArray_type
	|	typeArray '[' ']' # typeArray_dim
	;

type
	:	'int'
	|	'string'
	|	'bool'
	|	ID
	;

statement
	:	blockStatement
	|	expressionStatement
	|	selectionStatement
	|	iterationStatement
	|	jumpStatement
	|	variableDeclarationStatement
	;

blockStatement
	:	'{' statementList? '}'
	;

statementList
	:	statement # statementList_stmt
	|	statement statementList # statementList_list
	;

expressionStatement
	:	expression? ';'
	;

expression
	:	assignmentExpression
	;

assignmentExpression
	:	logicalOrExpression # assignment_logicalOr
	|	prefixExpression '=' assignmentExpression # assignment_assign
	;

//conditionalExpression
	//:	logicalOrExpression ('?' expression ':' conditionalExpression)?
	//;

logicalOrExpression
	:	logicalAndExpression # logicalOr_logicalAnd
	|	logicalOrExpression '||' logicalAndExpression # logicalOr_or
	;

logicalAndExpression
	:	bitwiseOrExpression # logicalAnd_bitwiseOr
	|	logicalAndExpression '&&' bitwiseOrExpression #logicalAnd_and
	;

bitwiseOrExpression
	:	bitwiseXorExpression # bitwiseOr_bitwiseXor
	|	bitwiseOrExpression '|' bitwiseXorExpression # bitwiseOr_or
	;

bitwiseXorExpression
	:	bitwiseAndExpression # bitwiseXor_bitwiseAnd
	|	bitwiseXorExpression '^' bitwiseAndExpression #bitwiseXor_xor
	;

bitwiseAndExpression
	:	equalityExpression # bitwiseAnd_equal
	|	bitwiseAndExpression '&' equalityExpression # bitwiseAnd_and
	;

equalityExpression
	:	relationalExpression # equality_relational
	|	equalityExpression '==' relationalExpression # equality_equal
	|	equalityExpression '!=' relationalExpression # equality_notEqual
	;

relationalExpression
	:	shiftExpression # relational_shift
	|	relationalExpression '<' shiftExpression # relational_less
	|	relationalExpression '>' shiftExpression # relational_greater
	|	relationalExpression '<=' shiftExpression # relational_leq
	|	relationalExpression '>=' shiftExpression # relational_geq
	;

shiftExpression
	:	addSubExpression # shift_addSub
	|	shiftExpression '<<' addSubExpression # shift_leftShift
	|	shiftExpression '>>' addSubExpression # shift_rightShift
	;

addSubExpression
	:	mulDivRemExpression # addSub_mulDivRem
	|	addSubExpression '+' mulDivRemExpression # addSub_add
	|	addSubExpression '-' mulDivRemExpression # addSub_sub
	;

mulDivRemExpression
	:	creationExpression # mulDivRem_creation
	|	mulDivRemExpression '*' creationExpression # mulDivRem_mul
	|	mulDivRemExpression '/' creationExpression # mulDivRem_div
	|	mulDivRemExpression '%' creationExpression # mulDivRem_rem
	;

creationExpression
	:	'new' typeArray dimensionExpression? # creation_dim
	|	'new' typeArray '(' expression ')' # creation_para
	|	prefixExpression # creation_prefix
	;

dimensionExpression
	:	'[' expression ']' # dimension_
	|	'[' expression ']' dimensionExpression #dimension_dim
	;

prefixExpression
	:	postfixExpression # prefix_postfix
	|	'+' prefixExpression # prefix_positive
	|	'-' prefixExpression # prefix_negative
	|	'!' prefixExpression # prefix_not
	|	'~' prefixExpression # prefix_tilde
	|	'++' prefixExpression # prefix_plusPlus
	|	'--' prefixExpression # prefix_minusMinus
	;

postfixExpression
	:	primaryExpression # postfix_primary
	|	postfixExpression '[' expression ']' # postfix_expression
	|	postfixExpression '(' argumentExpressionList? ')' # postfix_argument
	|	postfixExpression '.' ID # postfix_id
	|	postfixExpression '++' # postfix_incre
	|	postfixExpression '--' # postfix_decre
	;

primaryExpression
	:	ID # primary_id
	|	constant # primary_constant
	|	'(' expression ')' # primary_expression
	;

constant
	:	'null' # constant_null
	|	IntLiteral # constant_int
	|	StringLiteral # constant_string
	|	logicConstant # constant_logic
	;

logicConstant
	:	'true' # logic_true
	|	'false' # logic_false
	;

argumentExpressionList
	:	expression # argument_expression
	|	expression ',' argumentExpressionList # argument_expressionList
	;

selectionStatement
	:	'if' '(' expression ')' statement # selection_if
	|	'if' '(' expression ')' statement 'else' statement #selection_ifElse
	;

iterationStatement
	:	whileStatement
	|	forStatement
	;

whileStatement
	:	'while' '(' expression ')' statement
	;

forStatement
	:	'for' '(' expression? ';' expression? ';' expression? ')' statement
	;

jumpStatement
	:	returnStatement
	|	breakStatement
	|	continueStatement
	;

returnStatement
	:	'return' expression? ';'
	;

breakStatement
	:	'break' ';'
	;

continueStatement
	:	'continue' ';'
	;

variableDeclarationStatement
	:	variableDeclaration ';'
	;

variableDeclaration
	:	typeArray ID # varDecl_
	|	typeArray ID '=' expression # varDecl_init
	;

functionDeclaration
	:	typeArray ID '(' parameterList? ')' blockStatement # functionDecl_returnType
	|	'void' ID '(' parameterList? ')' blockStatement # functionDecl_void
	;

parameterList
	:	typeArray ID # parameter_
	|	typeArray ID ',' parameterList # parameter_list
	;



Break : 'break' ;
Continue : 'continue' ;
Else : 'else' ;
For : 'for' ;
If : 'if' ;
Int : 'int' ;
Void : 'void' ;
While : 'while' ;
Bool : 'bool' ;
String : 'string' ;
Null : 'null' ;
True : 'true' ;
False : 'false' ;
Return : 'return' ;
New : 'new' ;
Class : 'class';

LeftParen : '(';
RightParen : ')';
LeftBracket : '[';
RightBracket : ']';
LeftBrace : '{';
RightBrace : '}';

Less : '<';
LessEqual : '<=';
Greater : '>';
GreaterEqual : '>=';
LeftShift : '<<';
RightShift : '>>';

Plus : '+';
PlusPlus : '++';
Minus : '-';
MinusMinus : '--';
Star : '*';
Div : '/';
Mod : '%';

And : '&';
Or : '|';
AndAnd : '&&';
OrOr : '||';
Caret : '^';
Not : '!';
Tilde : '~';

Question : '?';
Colon : ':';
Semi : ';';
Comma : ',';

Assign : '=';
Equal : '==';
NotEqual : '!=';

Dot : '.';

ID : [a-zA-Z] ('a'..'z'|'A'..'Z'|'_'|'0'..'9')* ;
IntLiteral : [0-9]+ ;

fragment
EscapeSequence
    :   '\\' ["n\\]
    ;

StringLiteral
	: '"' SCharSequence? '"'
	;

fragment
SCharSequence
	: SChar+
	;

fragment
SChar
	: ~["\r\n]
    | EscapeSequence
	;

Whitespace
	: [ \t]+ -> skip
	;

Newline
	: ('\r' '\n'? | '\n' ) -> skip
	;

LineComment
	: '//' ~[\r\n]* -> skip
	;

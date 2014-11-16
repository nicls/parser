/* Nase-parser.*/

%{
	#define YYSTYPE double
	#include <math.h>
	int yylex (void);
	void yyerror (char const *);
%}

%token DELIMITER_SYMBOL
%token EOF_SYMBOL
%token INT_TYPE_SYMBOL
%token COMMA_SYMBOL
%token ASSIGN_SYMBOL
%token MINUS_SYMBOL
%token PLUS_SYMBOL
%token TIMES_SYMBOL
%token DIVIDE_SYMBOL
%token MODULO_SYMBOL
%token OR_SYMBOL
%token AND_SYMBOL
%token OPEN_PARAENTHESIS_SYMBOL
%token CLOSE_PARENTHESIS_SYMBOL
%token INLINE_IF_SYMBOL
%token INLINE_FI_SYMBOL
%token INLINE_THEN_SYMBOL
%token INLINE_ELSE_SYMBOL
%token LT_SYMBOL
%token LE_SYMBOL
%token EQ_SYMBOL
%token GE_SYMBOL
%token GT_SYMBOL
%token NE_SYMBOL
%token READ_SYMBOL
%token WRITE_SYMBOL
%token ANY_DIGIT
%token ANY_LETTER


%% 

/* Grammar rules and actions follow.*/

program : statementSequence EOF_SYMBOL; 

statementSequence : statementSequence statement
				  | /* empty */ ; 

statement : statementType DELIMITER_SYMBOL
		  | DELIMITER_SYMBOL; 

statementType : declaration | assignment | read | write;

declaration : typeName identifier furtherDeclarations;
furtherDeclarations : furtherDeclarations COMMA_SYMBOL identifier
				   | /* empty */ ; 

typeName : INT_TYPE_SYMBOL; 

assignment : identifier ASSIGN_SYMBOL intExpr; 

intExpr : MINUS_SYMBOL intTerm furtherIntTerms
		| intTerm furtherIntTerms; 
furtherIntTerms : furtherIntTerms addOp intTerm
				| /* empty */;

intTerm : intFactor furtherIntFactors;
furtherIntFactors : furtherIntFactors multOp intFactor
				  | /* empty */;

intFactor : integer 
		  | identifier 
		  | OPEN_PARAENTHESIS_SYMBOL intExpr CLOSE_PARENTHESIS_SYMBOL 
		  | inlineIfStatement; 

inlineIfStatement : INLINE_IF_SYMBOL boolExpr INLINE_THEN_SYMBOL intExpr INLINE_ELSE_SYMBOL intExpr INLINE_FI_SYMBOL; 

boolExpr : intExpr relationOp intExpr furtherBoolExpression;
furtherBoolExpression : furtherBoolExpression boolOp intExpr relationOp intExpr
					  | /* empty */; 

addOp : PLUS_SYMBOL | MINUS_SYMBOL; 

multOp : TIMES_SYMBOL | DIVIDE_SYMBOL | MODULO_SYMBOL; 

relationOp : LT_SYMBOL | LE_SYMBOL | EQ_SYMBOL | GE_SYMBOL | GT_SYMBOL | NE_SYMBOL; 

boolOp : AND_SYMBOL | OR_SYMBOL; 

identifier : ANY_LETTER letterAndDigits;
letterAndDigits : letterAndDigits digitOrLetter
				| /* empty */; 

digitOrLetter : ANY_DIGIT | ANY_LETTER

integer : ANY_DIGIT furtherDigits;
furtherDigits : furtherDigits ANY_DIGIT
			  | /* empty */; 

read : READ_SYMBOL identifier; 

write : WRITE_SYMBOL identifier;
%%

#include <ctype.h>
int
yylex (void)
{
	int c;

	/* Skip white space. */
	while ((c = getchar ()) == ' ' || c == '\t');

	/* Process numbers. */
	if (c == '.' || isdigit (c))
	{
		ungetc (c, stdin);
		scanf ("%lf", &yylval);
		return NUM;
	}

	/* Return end-of-input. */
	if (c == EOF)
		return 0;

	/* Return a single char. */
	return c;
}

int
main (void)
{
	return yyparse ();
}

#include <stdio.h>

/* Called by yyparse on error. */
void
yyerror (char const *s)
{
	fprintf (stderr, "%s\n", s);
}
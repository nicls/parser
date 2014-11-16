/* Nase-parser.*/

%{
	#define YYSTYPE double
	#include <math.h>
	#include <malloc.h>
	int yylex (void); /* The parser invokes a scanner by calling yylex. */
	void yyerror (char const *);
%}

/* Decleration of terminal symbols in the form '%token name' 
   Bison will convert this into a #define directive in the parser, 
   so that the function yylex (if it is in this file) can use the 
   name to stand for this token types code.
*/

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

/* Grammar rules and actions follow in the form:

   nonterminal: various terminals or nonterminals {C statements } 
				| ... {C statements }

   whereby the C statement represents the action that is going to 
   be invoked if the corresponding grouping of terminals and 
   nonterminals was recognized. If you dont specify an action for 
   a rule, Bison supplies a default: $$ = $1.

   Referring to semantic values in the C statement:
   $n stands for the semantic value of the nth component
   $$ stands for the semantic value for the grouping being constructed
*/ 

program : statementSequence EOF_SYMBOL {$$ = $1}; 

statementSequence : statementSequence statement {$$ = $1}
				  | /* empty */ ; 

statement : statementType DELIMITER_SYMBOL {$$ = $1}
		  | DELIMITER_SYMBOL {$$ = $1}; 

statementType : declaration {$$ = $1}  
			  | assignment {$$ = $1}  
			  | read {$$ = $1}  
			  | write {$$ = $1}; 

declaration : typeName identifier furtherDeclarations {$$ = $1}; 
furtherDeclarations : furtherDeclarations COMMA_SYMBOL identifier {$$ = $1}
				    | /* empty */ ; 

typeName : INT_TYPE_SYMBOL {$$ = $1};  

assignment : identifier ASSIGN_SYMBOL intExpr {$$ = $1}; 

intExpr : MINUS_SYMBOL intTerm furtherIntTerms {$$ = $1} 
		| intTerm furtherIntTerms {$$ = $1}; 
furtherIntTerms : furtherIntTerms addOp intTerm {$$ = $1}
				| /* empty */;

intTerm : intFactor furtherIntFactors {$$ = $1};
furtherIntFactors : furtherIntFactors multOp intFactor {$$ = $1}
				  | /* empty */;

intFactor : integer {$$ = $1}
		  | identifier {$$ = $1}
		  | OPEN_PARAENTHESIS_SYMBOL intExpr CLOSE_PARENTHESIS_SYMBOL {$$ = $1}
		  | inlineIfStatement {$$ = $1}; 

inlineIfStatement : INLINE_IF_SYMBOL boolExpr INLINE_THEN_SYMBOL intExpr INLINE_ELSE_SYMBOL intExpr INLINE_FI_SYMBOL {$$ = $1}; 

boolExpr : intExpr relationOp intExpr furtherBoolExpression {$$ = $1};
furtherBoolExpression : furtherBoolExpression boolOp intExpr relationOp intExpr {$$ = $1}
					  | /* empty */; 

addOp : PLUS_SYMBOL {$$ = $1}
	  | MINUS_SYMBOL {$$ = $1}; 

multOp : TIMES_SYMBOL {$$ = $1}
	   | DIVIDE_SYMBOL {$$ = $1}
	   | MODULO_SYMBOL {$$ = $1}; 

relationOp : LT_SYMBOL {$$ = $1}
		   | LE_SYMBOL {$$ = $1}
		   | EQ_SYMBOL {$$ = $1}
		   | GE_SYMBOL {$$ = $1}
		   | GT_SYMBOL {$$ = $1}
		   | NE_SYMBOL {$$ = $1}; 

boolOp : AND_SYMBOL {$$ = $1}
	   | OR_SYMBOL {$$ = $1}; 

identifier : ANY_LETTER letterAndDigits {$$ = $1};
letterAndDigits : letterAndDigits digitOrLetter {$$ = $1}
				| /* empty */; 

digitOrLetter : ANY_DIGIT {$$ = $1}
			  | ANY_LETTER {$$ = $1};

integer : ANY_DIGIT furtherDigits {$$ = $1};
furtherDigits : furtherDigits ANY_DIGIT {$$ = $1}
			  | /* empty */; 

read : READ_SYMBOL identifier {$$ = $1}; 

write : WRITE_SYMBOL identifier {$$ = $1};
%%

#include <ctype.h>

/** 
 * The parser invokes the scanner by calling yylex.
 */
int yylex (void)
{
	int c;

	/* Skip white space. */
	while ((c = getchar ()) == ' ' || c == '\t');

	/* Process numbers. */
	if (c == '.' || isdigit (c))
	{
		ungetc (c, stdin);

        // Wartet auf Tastatureingabe und speichert semantischen Wert in yylval. 
        // yylval wird von Bison genutzt um den aktuellen semantischen Wert einer 
        // Eingabe abzurufen.
		scanf ("%lf", &yylval); 
		return ANY_DIGIT;
	}

	/* Return end-of-input. */
	if (c == EOF_SYMBOL) {

        //return 0 for end-of-input
		return 0; 
    }

	/* Return a single char. */
	return c;
}

/** 
 * Main Method thats starts the parsing process.
 */
int main (void)
{
	return yyparse ();
}

#include <stdio.h>

/** 
 * Called by yyparse on error. 
 */
void yyerror (char const *s)
{
	fprintf (stderr, "%s\n", s);
}

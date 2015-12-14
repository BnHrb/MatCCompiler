%{
	#include <stdio.h>
	#include <stdlib.h>	

	#include "symbol.h"
	#include "quad.h"
	#include "quad_list.h"
	#include "mips.h"

	#define YYDEBUG 0

	FILE* yyin;
	int yylex();
	void yyerror(char*);

	Symbol* symbol_table = NULL;
	Symbol* test = NULL;
	Quad* code = NULL;
	int next_quad = 0;
//int main() { matrix A[2][2]={{12,27},{64,42}}; }
//int main(){int a=5; if(a==5){return 6;}; return 0;}
%}

%union {
	char* string; // token ID
	int value; // token NUMBER
	struct symbol* label;
	struct {
		struct symbol* result;
		struct quad* code;
	} code_expression;
	struct {
		struct quad* code;
		struct quad_list* truelist;
		struct quad_list* falselist; 
	} code_condition;
}

%token <string> ID
%token <value> NUM
%token EQUAL
%token ASSIGN
%token WHILE
%token IF
%token ELSE
%token PLUS MIN MUL DIV
%token OP_UNAIRE
%token RETURN
%token TYPE
%token TRUE
%token FALSE
%token OR
%token AND
%token NOT

%type <code_condition> axiom
%type <code_condition> function
%type <code_expression> expr
%type <code_condition> condition
%type <code_condition> stmt
%type <code_condition> stmtlist
%type <label> tag

%left OR
%left AND
%left PLUS
%left MIN
%left DIV
%left MUL
%left EQUAL
%right NOT
%right OP_UNAIRE

%%

axiom:
	function
		{
			printf("DONE\n");

			// Symbol* cst_true = symbol_newcst(&symbol_table, 1);
			// Symbol* cst_false = symbol_newcst(&symbol_table, 0);
			// Symbol* result = symbol_add(&symbol_table, "result");
			// Quad* is_true;
			// Quad* is_false;
			// Quad* jump;
			// Symbol* label_true;
			// Symbol* label_false;

			// label_true = symbol_newcst(&symbol_table, next_quad);
			// is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			// jump = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			// label_false = symbol_newcst(&symbol_table, next_quad);
			// is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			// quad_list_complete($1.truelist, label_true);
			// quad_list_complete($1.falselist, label_false);

			// code = $1.code;
			// quad_add(&code, is_true);
			// quad_add(&code, jump);
			// quad_add(&code, is_false);

			// symbol_table_print(&symbol_table);
			//quad_list_print($1.truelist);
			//quad_list_print($1.falselist);
			//code->quad_print(code);

			code = $1.code;

			//quad_print(code);

			// symbol_add(&test, "a");
			// symbol_add(&test, "b");
			// symbol_newcst(&test, 10);
			// symbol_newtemp(&test);

			//symbol_table_print(&test);

			symbol_table_print(&symbol_table);

			return 0;
		}

function:
	TYPE ID'('')' '{' stmtlist '}'
	{
		printf("function -> TYPE ID () { stmtlist }\n");
		$$.code = $6.code;
	}

stmtlist:
	stmtlist stmt ';'
	{
		printf("stmtlist -> stmtlist stmt\n");
		$$.code = $2.code;
	}
	| stmt ';'
	{
		printf("stmtlist -> stmt\n");
		$$.code = $1.code;
	}
	;

stmt:
	ID ASSIGN expr
		{
			$$.code = $3.code;
		}
	| TYPE ID 
		{

		}
	| TYPE ID ASSIGN expr 											{}
	| TYPE ID arr													{}
	| TYPE ID arr ASSIGN expr										{}
	| ID "++"														{}
	| ID "--"														{}
	| WHILE '(' condition ')' '{' stmtlist '}'						{}
	| IF '(' condition ')' '{' stmtlist '}'
		{
			printf("stmt -> if ( condition ) { stmtlist }\n");

			Symbol* cst_true = symbol_newcst(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result");
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Symbol* label_true;
			Symbol* label_false;

			label_true = symbol_newcst(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			jump = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			label_false = symbol_newcst(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			quad_list_complete($3.truelist, label_true);
			quad_list_complete($3.falselist, label_false);

			symbol_newtemp(&symbol_table);

			$$.code = $3.code;
			quad_add(&$$.code, is_true);
			quad_add(&$$.code, jump);
			quad_add(&$$.code, is_false);
		}
	| IF '(' condition ')' '{' stmtlist '}' ELSE '{' stmtlist '}'	{}
	| RETURN expr													{}
	;

arr:
	'[' NUM ']'														{}
	| '[' NUM ']' arr												{}
	;

expr:	
	expr PLUS expr
		{
			printf("expr -> expr + expr\n");
			$$.result = symbol_newtemp(&symbol_table);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, PLUS_, $1.result, $3.result, $$.result));
		}
	| expr MIN expr
		{
			printf("expr -> expr - expr\n");
			$$.result = symbol_newtemp(&symbol_table);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, MIN_, $1.result, $3.result, $$.result));
		}
	| expr DIV expr
		{
			printf("expr -> expr - expr\n");
			$$.result = symbol_newtemp(&symbol_table);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, DIV_, $1.result, $3.result, $$.result));
		}
	| expr MUL expr
		{
			printf("expr -> expr * expr\n");
			$$.result = symbol_newtemp(&symbol_table);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, MUL_, $1.result, $3.result, $$.result));
		}
	// | '-' expr
	// 	{
	// 		printf("expr -> - expr\n");
	// 		$$.result = symbol_newtemp(&symbol_table);
	// 		$$.code = $2.code;
	// 		quad_add(&$$.code, quad_gen(&next_quad, MIN_, NULL, $2.result, $$.result));
	// 	}
	| '{' innerlist '}'												{}
	| '(' expr ')'
		{
			printf("expression -> ( expression )\n");
			$$.result = $2.result;
			$$.code = $2.code;
		}
	| ID 
		{
			printf("expression -> ID (%s)\n", $1);
			// Find or create the named symbol to hold the identifier value
			$$.result = symbol_lookup(&symbol_table, $1);
			if($$.result == NULL)
				$$.result = symbol_add(&symbol_table, $1);
			// No code is generated for this
			$$.code = NULL;

		}	
	| NUM
		{
			printf("expression -> NUM (%d)\n", $1);
			// Create the tempory symbol to hold the constant value
			$$.result = symbol_newcst(&symbol_table, $1);
			// No code is generated for this
			$$.code = NULL;
		}
	;

innerlist : expr ',' expr											{}
			| expr													{}
			;

condition:
	expr EQUAL expr 
		{ 
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, EQUAL_, $1.result, $3.result, NULL);
			goto_false = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, goto_true);
			quad_add(&$$.code, goto_false);
			$$.truelist = quad_list_new(goto_true);
			$$.falselist = quad_list_new(goto_false);
		}
	| expr '<' expr
		{
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, INF_, $1.result, $3.result, NULL);
			goto_false = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, goto_true);
			quad_add(&$$.code, goto_false);
			$$.truelist = quad_list_new(goto_true);
			$$.falselist = quad_list_new(goto_false);
		}
	| expr '>' expr
		{
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, SUP_, $1.result, $3.result, NULL);
			goto_false = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, goto_true);
			quad_add(&$$.code, goto_false);
			$$.truelist = quad_list_new(goto_true);
			$$.falselist = quad_list_new(goto_false);
		}
	| TRUE		
		{
			printf("condition -> true\n");
			// Goto true
			$$.code = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.truelist = quad_list_new($$.code);
			//quad_list_print($$.truelist);
			$$.falselist = NULL;
		}
	| FALSE 	
		{
			printf("condition -> false\n");
			// Goto false
			$$.code = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.truelist = NULL;
			$$.falselist = quad_list_new($$.code);
			//quad_list_print($$.falselist);
		}
	| condition OR tag condition	
		{
			printf("condition -> condition OR condition\n");
			quad_list_complete($1.falselist, $3);
			$$.code = $1.code;
			quad_add(&$$.code, $4.code);
			$$.falselist = $4.falselist;
			$$.truelist = $1.truelist;
			quad_list_add(&$$.truelist, $4.truelist);
		}
	| condition AND tag condition	
		{
			printf("condition -> condition AND condition\n");
			quad_list_complete($1.truelist, $3);
			quad_list_add(&$1.falselist, $4.falselist);
			$$.falselist = $1.falselist;
			$$.truelist = $4.truelist;
			$$.code = $1.code;
			quad_add(&$$.code, $4.code);
		}
	| NOT condition		
		{
			printf("condition -> NOT condition\n");
			$$.code = $2.code;
			$$.truelist = $2.falselist;
			$$.falselist = $2.truelist;			
		}
	| '(' condition ')'	
		{
			printf("condition -> ( condition ) \n");
			$$.code = $2.code;
			$$.truelist = $2.truelist;
			$$.falselist = $2.falselist;
		}
	;

tag:
	{
		$$ = symbol_newcst(&symbol_table, next_quad);
	}
	;

%%
void yyerror (char *s){
	fprintf (stderr, "[Yacc] %s\n", s);
}

int main(int argc, char* argv[]) {
	#if YYDEBUG
		yydebug = 1;
	#endif

	if(argc == 1) {
		printf("Usage: %s file\n", argv[0]);
		return -1;
	}

	FILE* f = fopen(argv[1], "r");

	if(f == NULL) {
		printf("Unable to open the file\n");
		return -1;
	}

	yyin = f;

	yyparse();

	return 0;
}
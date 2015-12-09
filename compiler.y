%{
	#include <stdio.h>
	#include <stdlib.h>	

	#include "symbol.h"
	#include "quad.h"
	#include "quad_list.h"

	#define YYDEBUG 0

	int yylex();
	void yyerror(char*);

	Symbol* symbol_table = NULL;
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
%token OP_BINAIRE
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
%type <label> tag

%left OR
%left AND
%left OP_BINAIRE
%right NOT
%right OP_UNAIRE

%%

axiom:
	function '\n'
		{
			printf("DONE\n");

			Symbol* cst_true = symbol_newcst(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result");
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Symbol* label_true;
			Symbol* label_false;

			label_true = symbol_newcst(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ':', cst_true, NULL, result);
			jump = quad_gen(&next_quad, 'G', NULL, NULL, NULL);
			label_false = symbol_newcst(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ':', cst_false, NULL, result);
			quad_list_complete($1.truelist, label_true);
			quad_list_complete($1.falselist, label_false);

			code = $1.code;
			quad_add(&code, is_true);
			quad_add(&code, jump);
			quad_add(&code, is_false);

			symbol_table_print(&symbol_table);
			quad_list_print($1.truelist);
			quad_list_print($1.falselist);
			code->quad_print(code);

			return 0;
		}

function:
	TYPE ID'('')' '{' stmtlist '}'									{}

stmtlist:
	stmtlist stmt ';'												{}
	| stmt ';'														{}
	;

stmt:
	ID ASSIGN expr													{}
	| TYPE ID 														{}
	| TYPE ID ASSIGN expr 											{}
	| TYPE ID arr													{}
	| TYPE ID arr ASSIGN expr										{}
	| ID "++"														{}
	| ID "--"														{}
	| WHILE '(' condition ')' '{' stmtlist '}'						{}
	| IF '(' condition ')' '{' stmtlist '}'							{}
	| IF '(' condition ')' '{' stmtlist '}' ELSE '{' stmtlist '}'	{}
	| RETURN expr													{}
	;

arr:
	'[' NUM ']'														{}
	| '[' NUM ']' arr												{}
	;

expr:	
	expr OP_BINAIRE expr											{}
	| OP_UNAIRE expr												{}
	| '{' innerlist '}'												{}
	| '(' expr ')'													{}
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
	ID EQUAL NUM 
		{ }
	| expr '<' expr
		{
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, '<', $1.result, $3.result, NULL);
			goto_false = quad_gen(&next_quad, 'G', NULL, NULL, NULL);
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
			goto_true = quad_gen(&next_quad, '>', $1.result, $3.result, NULL);
			goto_false = quad_gen(&next_quad, 'G', NULL, NULL, NULL);
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
			$$.code = quad_gen(&next_quad, 'G', NULL, NULL, NULL);
			$$.truelist = quad_list_new($$.code);
			quad_list_print($$.truelist);
			$$.falselist = NULL;
		}
	| FALSE 	
		{
			printf("condition -> false\n");
			// Goto false
			$$.code = quad_gen(&next_quad, 'G', NULL, NULL, NULL);
			$$.truelist = NULL;
			$$.falselist = quad_list_new($$.code);
			quad_list_print($$.falselist);
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

int main() {
	#if YYDEBUG
        yydebug = 1;
    #endif
    yyparse();
    quad_free(code);
	return 0;
}
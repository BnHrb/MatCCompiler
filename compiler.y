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
	Quad* code = NULL;
	int next_quad = 0;
%}

%union {
	char* string; // token ID
	int value_int; // token NUMBER
	float value_float;
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
	struct {
		struct symbol* x;
		struct symbol* y;
	} code_array;
	struct {
		struct symbol* list_num;
	} code_list_num;
}

%token <string> ID STRING TYPE
%token <value_int> NUM_INT
%token <value_float> NUM_FLOAT
%token EQUAL SUPEQ INFEQ NOT_EQUAL
%token ASSIGN
%token WHILE FOR
%token IF ELSE
%token INCR DECR
%token PLUS MIN MUL DIV MIN_UNAIRE
%token OP_UNAIRE
%token RETURN PRINTF PRINT PRINTMAT
%token TRUE FALSE
%token OR AND NOT

%type <code_expression> axiom
%type <code_expression> function
%type <code_expression> expr
%type <code_condition> condition
%type <code_expression> stmt
%type <code_expression> stmtlist
%type <code_expression> structure
%type <code_array> arr
%type <code_list_num> arr_init
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

			code = $1.code;

			if(code != NULL)
				quad_print(code);

			if(symbol_table != NULL)
				symbol_table_print(&symbol_table);

			return 0;
		}

function:
	TYPE ID'('')' '{' stmtlist '}'
	{
		printf("function -> TYPE (%s) ID (%s) () { stmtlist }\n", $1,  $2);
		$$.code = $6.code;
	}
	| TYPE ID'('')' '{' '}'
	{
		printf("function -> TYPE (%s) ID (%s) () { }\n", $1,  $2);
	}

stmtlist:
	stmtlist stmt ';'
		{
			printf("stmtlist -> stmtlist stmt\n");
			$$.code = $1.code;
			quad_add(&$$.code, $2.code);
		}
	| stmt ';'
		{
			printf("stmtlist -> stmt\n");
			$$.code = $1.code;
		}
	| stmtlist structure
		{
			printf("stmtlist -> stmtlist structure\n");
			$$.code = $1.code;
			quad_add(&$$.code, $2.code);			
		}
	| structure
		{
			printf("stmtlist -> structure\n");
			$$.code = $1.code;		
		}
	;

stmt:
	ID ASSIGN expr
		{
			printf("stmt -> ID (%s) = expr\n", $1);
			Symbol* s = symbol_lookup(&symbol_table, $1);
			if(s == NULL) {
				printf("Error : variable %s doesn't exist.\n", $1);
				return -1;
			}
			$$.code = $3.code;
			quad_add(&$$.code, quad_gen(&next_quad, ASSIGN_, $3.result, NULL, s));
		}
	| TYPE ID 
		{
			printf("stmt -> TYPE (%s) ID (%s)\n", $1, $2);
			if(strcmp($1, "int") == 0) {
				symbol_add(&symbol_table, $2, INT_);
			}
			else {
				symbol_add(&symbol_table, $2, FLOAT_);
			}
		}
	| TYPE ID ASSIGN expr 	
		{
			printf("stmt -> TYPE (%s) ID (%s) = expr\n", $1, $2);
			Symbol* s = NULL;
			if(strcmp($1, "int") == 0) {
				s = symbol_add(&symbol_table, $2, INT_);
			}
			else {
				s = symbol_add(&symbol_table, $2, FLOAT_);
			}
			$$.code = $4.code;
			quad_add(&$$.code, quad_gen(&next_quad, ASSIGN_, $4.result, NULL, s));
		}
	| TYPE ID arr
		{
			printf("stmt -> TYPE ID (%s) arr\n", $2);
			
			Symbol* s = symbol_add(&symbol_table, $2, ARRAY_);
			
			s->dim.x = $3.x;
			s->dim.y = $3.y;
			$$.code = quad_gen(&next_quad, INIT_ARRAY_, s, NULL, NULL);
		}
	| ID arr ASSIGN expr 
		{
			printf("stmt -> ID (%s) arr = expr\n", $1);
			Symbol* s = symbol_lookup(&symbol_table, $1);
			if(s == NULL) {
				printf("Error : variable %s doesn't exist.\n", $1);
				return -1;
			}
			$$.code = quad_gen(&next_quad, INDEX_ARRAY_X_, s, $2.x, NULL);
			if($2.y != NULL)
				$$.code = quad_gen(&next_quad, INDEX_ARRAY_Y_, s, $2.y, NULL);
			quad_add(&$$.code, quad_gen(&next_quad, ASSIGN_, $4.result, NULL, s));
		}
	| TYPE ID arr ASSIGN '{' arr_init '}'
		{
			printf("stmt -> TYPE ID (%s) arr = { arr_init }\n", $2);
			// Symbol* s = symbol_add(&symbol_table, $2, ARRAY_);
			// s->dim.x = $3.x;
			// s->dim.y = $3.y;

			// $$.code = quad_gen(&next_quad, INIT_ARRAY_, s, NULL, NULL);

			// int i;
			// Symbol* index = NULL;
			// for(i=0; i<$3.x+($3.y*$3.x); i++) {
			// 	index = symbol_newcst_int(&symbol_table, i);
			// 	quad_add(&$$.code, quad_gen(&next_quad, INDEX_ARRAY_, s, index, NULL));
			// 	//printf("==========>>> %d\n", $6.num[i]);
			// 	quad_add(&$$.code, quad_gen(&next_quad, ASSIGN_, $6.num[i], NULL, s));				
			// }
		}
	| ID INCR														
		{
			printf("stmt -> ID (%s) ++\n", $1);
			Symbol* s = symbol_lookup(&symbol_table, $1);
			if(s == NULL) {
				printf("Error : variable %s doesn't exist.\n", $1);
				return -1;
			}
			Symbol* cst_add = symbol_newcst_int(&symbol_table, 1);
			$$.code = quad_gen(&next_quad, ADD_, s, cst_add, s);
		}
	| ID DECR														
		{
			printf("stmt -> ID (%s) --\n", $1);
			Symbol* s = symbol_lookup(&symbol_table, $1);
			if(s == NULL) {
				printf("Error : variable %s doesn't exist.\n", $1);
				return -1;
			}
			Symbol* cst_add = symbol_newcst_int(&symbol_table, 1);
			$$.code = quad_gen(&next_quad, MIN_, s, cst_add, s);			
		}
	| RETURN expr 
		{
			printf("stmt -> RETURN expr\n");
			$$.code = quad_gen(&next_quad, RETURN_, $2.result, NULL, NULL);
		}
	| PRINTF '(' STRING ')'
		{
			printf("stmt -> PRINTF (%s)\n", $3);
			char * str = $3;
			str++;
			str[strlen(str)-1] = 0;
			Symbol* s = symbol_newcst_string(&symbol_table, str);
			$$.code = quad_gen(&next_quad, PRINTF_, s, NULL, NULL);
		}
	| PRINT '(' expr ')'
		{
			printf("stmt -> PRINT ( expr )\n");
			$$.code = quad_gen(&next_quad, PRINT_, $3.result, NULL, NULL);
		}
	| PRINTMAT '(' expr ')'
		{
			printf("stmt -> PRINTMAT ( expr )\n");
			//$$.code = quad_gen(&next_quad, PRINT_, $3.result, NULL, NULL);
		}
	;

arr_init : 
	'{' arr_expr_list '}' ',' arr_init
		{

		}
	| '{' arr_expr_list '}'
		{

		}
	|	arr_expr_list
		{

		}


arr_expr_list :  
	expr ',' arr_expr_list
		{
			// $$.size = $3.size + 1;
			// $$.num = malloc(sizeof(int)*$$.size);

			// memcpy($$.num, &$1, sizeof(int));
			// memcpy($$.num+1, $3.num, $3.size*sizeof(int));
		}
	| expr 
		{
			// $$.num = malloc(sizeof(int));
			// $$.size = 1;
			// memcpy($$.num, &$1, sizeof(int));
		}

structure:
	FOR '('stmt ';' condition ';' stmt')' '{' stmtlist '}'
		{
			printf("stmt -> for ( stmt ; condition ; stmt ) { stmtlist }\n");

			Symbol* cst_true = symbol_newcst_int(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst_int(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result", INT_);
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Symbol* label_true;
			Symbol* label_false;
			Symbol* label_jump;

			label_true = symbol_newcst_int(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			label_jump = symbol_newcst_int(&symbol_table, $5.code->label);
			jump = quad_gen(&next_quad, GOTO_, NULL, NULL, label_jump);
			label_false = symbol_newcst_int(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			quad_list_complete($5.truelist, label_true);
			quad_list_complete($5.falselist, label_false);

			$$.code = $3.code;
			quad_add(&$$.code, $5.code);
			quad_add(&$$.code, is_true);
			quad_add(&$$.code, $7.code);
			quad_add(&$$.code, $10.code);
			quad_add(&$$.code, jump);
			quad_add(&$$.code, is_false);

		}
	| WHILE '(' condition ')' '{' stmtlist '}' 
		{
			printf("stmt -> while ( condition ) { stmtlist }\n");

			Symbol* cst_true = symbol_newcst_int(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst_int(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result", INT_);
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Symbol* label_true;
			Symbol* label_false;
			Symbol* label_jump;

			label_true = symbol_newcst_int(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			label_jump = symbol_newcst_int(&symbol_table, $3.code->label);
			jump = quad_gen(&next_quad, GOTO_, NULL, NULL, label_jump);
			label_false = symbol_newcst_int(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			quad_list_complete($3.truelist, label_true);
			quad_list_complete($3.falselist, label_false);

			$$.code = $3.code;
			quad_add(&$$.code, is_true);
			quad_add(&$$.code, $6.code);
			quad_add(&$$.code, jump);
			quad_add(&$$.code, is_false);
		}
	| IF '(' condition ')' '{' stmtlist '}'
		{
			printf("stmt -> if ( condition ) { stmtlist }\n");

			Symbol* cst_true = symbol_newcst_int(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst_int(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result", INT_);
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Quad* end;
			Symbol* label_true;
			Symbol* label_false;
			Symbol* label_end;

			label_true = symbol_newcst_int(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			label_false = symbol_newcst_int(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			quad_list_complete($3.truelist, label_true);
			quad_list_complete($3.falselist, label_false);

			label_end = symbol_newcst_int(&symbol_table, next_quad);
			end = quad_gen(&next_quad, NOP_, NULL, NULL, NULL);
			jump = quad_gen(&next_quad, GOTO_, NULL, NULL, label_end);


			$$.code = $3.code;
			quad_add(&$$.code, is_true);
			quad_add(&$$.code, $6.code);
			quad_add(&$$.code, jump);
			quad_add(&$$.code, is_false);
			quad_add(&$$.code, end);
		}
	| IF '(' condition ')' stmt ';'
		{
			printf("stmt -> if ( condition )  stmt ;\n");

			Symbol* cst_true = symbol_newcst_int(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst_int(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result", INT_);
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Quad* end;
			Symbol* label_true;
			Symbol* label_false;
			Symbol* label_end;

			label_true = symbol_newcst_int(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			label_false = symbol_newcst_int(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			quad_list_complete($3.truelist, label_true);
			quad_list_complete($3.falselist, label_false);

			label_end = symbol_newcst_int(&symbol_table, next_quad);
			end = quad_gen(&next_quad, NOP_, NULL, NULL, NULL);
			jump = quad_gen(&next_quad, GOTO_, NULL, NULL, label_end);


			$$.code = $3.code;
			quad_add(&$$.code, is_true);
			quad_add(&$$.code, $5.code);
			quad_add(&$$.code, jump);
			quad_add(&$$.code, is_false);
			quad_add(&$$.code, end);

		}
	| IF '(' condition ')' '{' stmtlist '}' ELSE '{' stmtlist '}'	
		{
			printf("stmt -> if ( condition ) { stmtlist } else { stmtlist }\n");

			Symbol* cst_true = symbol_newcst_int(&symbol_table, 1);
			Symbol* cst_false = symbol_newcst_int(&symbol_table, 0);
			Symbol* result = symbol_add(&symbol_table, "result", INT_);
			Quad* is_true;
			Quad* is_false;
			Quad* jump;
			Quad* end;
			Symbol* label_true;
			Symbol* label_false;
			Symbol* label_end;

			label_true = symbol_newcst_int(&symbol_table, next_quad);
			is_true = quad_gen(&next_quad, ASSIGN_, cst_true, NULL, result);
			label_false = symbol_newcst_int(&symbol_table, next_quad);
			is_false = quad_gen(&next_quad, ASSIGN_, cst_false, NULL, result);
			quad_list_complete($3.truelist, label_true);
			quad_list_complete($3.falselist, label_false);

			label_end = symbol_newcst_int(&symbol_table, next_quad);
			end = quad_gen(&next_quad, NOP_, NULL, NULL, NULL);
			jump = quad_gen(&next_quad, GOTO_, NULL, NULL, label_end);


			$$.code = $3.code;
			quad_add(&$$.code, is_true);
			quad_add(&$$.code, $6.code);
			quad_add(&$$.code, jump);
			quad_add(&$$.code, is_false);
			quad_add(&$$.code, $10.code);
			quad_add(&$$.code, end);	
		}

arr:
	'[' expr ']'
		{
			printf("arr -> [ expr ]\n");
			$$.x = $2.result;
			$$.y = 0;
		}
	| '[' expr ']' '[' expr ']'
		{
			printf("arr -> [ expr ] [ expr ]\n");
			$$.x = $2.result;
			$$.y = $5.result;
		}
	;

expr:	
	expr PLUS expr
		{
			printf("expr -> expr + expr\n");
			$$.result = symbol_newtemp(&symbol_table, INT_);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, ADD_, $1.result, $3.result, $$.result));
		}
	| expr MIN expr
		{
			printf("expr -> expr - expr\n");
			$$.result = symbol_newtemp(&symbol_table, INT_);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, MIN_, $1.result, $3.result, $$.result));
		}
	| expr DIV expr
		{
			printf("expr -> expr / expr\n");
			$$.result = symbol_newtemp(&symbol_table, INT_);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, DIV_, $1.result, $3.result, $$.result));
		}
	| expr MUL expr
		{
			printf("expr -> expr * expr\n");
			$$.result = symbol_newtemp(&symbol_table, INT_);
			$$.code = $1.code;
			quad_add(&$$.code, $3.code);
			quad_add(&$$.code, quad_gen(&next_quad, MUL_, $1.result, $3.result, $$.result));
		}
	| MIN expr
		{
			printf("expr -> - expr\n");
			$$.result = symbol_newtemp(&symbol_table, INT_);
			$$.code = $2.code;
			quad_add(&$$.code, quad_gen(&next_quad, MIN_UNAIRE_, $2.result, NULL, $$.result));
		}
	| '(' expr ')'
		{
			printf("expr -> ( expr )\n");
			$$.result = $2.result;
			$$.code = $2.code;
		}
	| ID 
		{
			printf("expr -> ID (%s)\n", $1);
			// Find or create the named symbol to hold the identifier value
			$$.result = symbol_lookup(&symbol_table, $1);
			if($$.result == NULL)
				$$.result = symbol_add(&symbol_table, $1, INT_);
			// No code is generated for this
			$$.code = NULL;

		}	
	| '~' ID 
		{
			printf("expr -> ~ ID (%s)\n", $2);
			// // Find or create the named symbol to hold the identifier value
			// $$.result = symbol_lookup(&symbol_table, $1);
			// if($$.result == NULL)
			// 	$$.result = symbol_add(&symbol_table, $1, INT_);
			// // No code is generated for this
			// $$.code = NULL;

		}	
	| ID arr 
		{
			printf("expr -> ID (%s) arr\n", $1);
			$$.result = symbol_lookup(&symbol_table, $1);
		}
	| NUM_INT
		{
			printf("expr -> NUM_INT (%d)\n", $1);
			// Create the tempory symbol to hold the constant value
			$$.result = symbol_newcst_int(&symbol_table, $1);
			// No code is generated for this
			$$.code = NULL;
		}
	| NUM_FLOAT
		{
			printf("expr -> NUM_FLOAT (%f)\n", $1);
			// Create the tempory symbol to hold the constant value
			$$.result = symbol_newcst_float(&symbol_table, $1);
			// No code is generated for this
			$$.code = NULL;	
		}
	;

condition:
	expr
		{
			printf("condition -> expr\n");
			Quad* goto_true;
			Quad* goto_false;
			Symbol* cst_zero = symbol_newcst_int(&symbol_table, 0);
			goto_true = quad_gen(&next_quad, NOT_EQUAL_, $1.result, cst_zero, NULL);
			goto_false = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.code = $1.code;
			quad_add(&$$.code, goto_true);
			quad_add(&$$.code, goto_false);
			$$.truelist = quad_list_new(goto_true);
			$$.falselist = quad_list_new(goto_false);
		}
	| expr NOT_EQUAL expr 
		{
			printf("condition -> expr != expr\n");
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, NOT_EQUAL_, $1.result, $3.result, NULL);
			goto_false = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.code = $1.code;
			quad_add(&$$.code, goto_true);
			quad_add(&$$.code, goto_false);
			$$.truelist = quad_list_new(goto_true);
			$$.falselist = quad_list_new(goto_false);
		}
	| expr EQUAL expr 
		{ 
			printf("condition -> expr == expr\n");
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
			printf("condition -> expr < expr\n");
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
	| expr INFEQ expr
		{
			printf("condition -> expr <= expr\n");
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, INFEQ_, $1.result, $3.result, NULL);
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
			printf("condition -> expr > expr\n");
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
	| expr SUPEQ expr
		{
			printf("condition -> expr >= expr\n");
			Quad* goto_true;
			Quad* goto_false;
			goto_true = quad_gen(&next_quad, SUPEQ_, $1.result, $3.result, NULL);
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
			$$.falselist = NULL;
		}
	| FALSE 	
		{
			printf("condition -> false\n");
			// Goto false
			$$.code = quad_gen(&next_quad, GOTO_, NULL, NULL, NULL);
			$$.truelist = NULL;
			$$.falselist = quad_list_new($$.code);
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
		$$ = symbol_newcst_int(&symbol_table, next_quad);
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
	FILE* output = fopen("output.s","w");

	if(f == NULL) {
		printf("Unable to open the file\n");
		return -1;
	}

	yyin = f;

	yyparse();

	translate_to_mips(output, symbol_table, code);

	symbol_free(symbol_table);
	quad_free(code);	

	return 0;
}
%{
	#include <stdio.h>
	#include <stdlib.h>	

	#include "quad.h"
	#include "quad_list.h"

	#define YYDEBUG 1

	int yylex();
	void yyerror(char*);
//int main() { matrix A[2][2]={{12,27},{64,42}}; }
%}

%union {
	char* name; // token ID
	int value; // token NUMBER
}

%token <name> ID
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

%left OR
%left AND
%left OP_BINAIRE
%right NOT
%right OP_UNAIRE

%%

axiome:
	function	'\n'												{ printf("DONE\n"); }

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
	| ID 															{}
	| NUM 															{}
	;

innerlist : expr ',' expr											{}
			| expr													{}
			;

condition:
	ID EQUAL NUM 													{}
	| TRUE															{}
	| FALSE 														{}
	| condition OR condition										{}
	| condition AND condition										{}
	| NOT condition													{}
	| '(' condition ')'												{}
	;

%%
void yyerror (char *s)
{
  fprintf (stderr, "[Yacc] %s\n", s);
}

int main() {
	#if YYDEBUG
        yydebug = 1;
    #endif

	return yyparse();
}
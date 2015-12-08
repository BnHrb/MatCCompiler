%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
%}

%option nounput
%option noinput

identifier	[a-zA-Z_]+[0-9a-zA-Z_]*
number 		[0-9]+
floatnumber {number}\.{number}
type		"int"|"float"|"matrix"

%%

"="				{ return ASSIGN; }
"=="			{ return EQUAL; }
"while" 		{ return WHILE; }
"if"			{ return IF; }
"else"			{ return ELSE; }
"true"			{ return TRUE; }
"false"			{ return FALSE; }
"||"			{ return OR; }
"&&"			{ return AND; }
"!"				{ return NOT; }
"+-*/"			{ return OP_BINAIRE; }
"+-∼"			{ return OP_UNAIRE; }
"return"		{ return RETURN; }
","				{ return yytext[0]; }
{type}			{ return TYPE; }
{identifier}	{ yylval.string = strdup(yytext); return ID; }
{number} 		{ yylval.value = atoi(yytext); return NUM; }
[(){}\[\];<>]	{ return yytext[0]; }
[\n]			{ return yytext[0]; }
[ ]				{}
.				{ printf("Caractère inconnu %s\n", yytext); }

%%
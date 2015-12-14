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
string     	\"(\\.|[^\"\\])*\"
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
"-"				{ return MIN; }
"*"				{ return MUL; }
"/"				{ return DIV; }
"+"				{ return PLUS; }
"+-∼"			{ return OP_UNAIRE; }
"return"		{ return RETURN; }
"printf"		{ return PRINTF; }
"print"			{ return PRINT; }
","				{ return yytext[0]; }
{type}			{ yylval.string = strdup(yytext); return TYPE; }
{string} 		{ yylval.string = strdup(yytext); return STRING; }
{identifier}	{ yylval.string = strdup(yytext); return ID; }
{number} 		{ yylval.value_int = atoi(yytext); return NUM_INT; }
{floatnumber} 	{ yylval.value_float = atof(yytext); return NUM_FLOAT; }
[(){}\[\];<>]	{ return yytext[0]; }
[ \t\n]			{}
.				{ printf("Caractère inconnu %s\n", yytext); }

%%
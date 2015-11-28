%{
	#include <stdio.h>
%}

%option noyywrap

type int|float|matrix
operator [+*\-/=();{}~]|"++"|"--"|"["|"]"
keyword if|else|while|for
identifier [a-zA-Z_]+[0-9a-zA-Z_]*
number [1-9][0-9]*|[1-9]*[.][0-9]*

%%

{type}							{ printf("%s", yytext); }
{operator}						{ printf("%s", yytext); }
{keyword}						{ printf("%s", yytext); }
{number}						{ printf("%s", yytext); }
{identifier}					{ printf("%s", yytext); }
[ ]							{ printf("%s", yytext); }
.								{ printf("NOP"); }

%%
int main(int argc, char* argv[])
{
	yylex();
	return 0;
}
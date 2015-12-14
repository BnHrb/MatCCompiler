#ifndef SYMBOL_H
#define SYMBOL_H
#define SYMBOL_MAX_NAME 64

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stdbool.h"

typedef struct symbol {
	bool isConstant;
	char* id;
	int value;
	int type;
	struct symbol* next;
} Symbol;

Symbol* symbol_alloc();
void symbol_free(Symbol* s);
Symbol* symbol_newtemp(Symbol** tds);
Symbol* symbol_newcst(Symbol** tds, int cst);
Symbol* symbol_lookup(Symbol** tds, char* id);
Symbol* symbol_add(Symbol** tds, char* id);
void symbol_print(Symbol* s, bool header);
void symbol_table_print(Symbol** tds);

#endif	/*SYMBOL_H*/
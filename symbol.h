#define SYMBOL_MAX_NAME 64;

#include "stdbool.h"

typedef struct symbol {
	bool isConstant;
	char* id;
	int value;
} symbol;

symbol* symbol_alloc();
void symbol_free(symbol* s);
symbol* symbol_newtemp(symbol** tds);
symbol* symbol_newcst(symbol** tds, int cst);
symbol* symbol_lookup(symbol** tds, char* id);
symbol* symbol_add(symbol** tds, char* id);
void symbol_print(symbol* s);
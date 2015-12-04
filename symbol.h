#define SYMBOL_MAX_NAME 64

#include "stdbool.h"

typedef struct symbol {
	bool isConstant;
	char* id;
	int value;
	struct symbol* next;
} Symbol;

Symbol* symbol_alloc();
void symbol_free(Symbol* s);
Symbol* symbol_newtemp(Symbol** tds);
Symbol* symbol_newcst(Symbol** tds, int cst);
Symbol* symbol_lookup(Symbol** tds, char* id);
Symbol* symbol_add(Symbol** tds, char* id);
void symbol_print(Symbol* s);
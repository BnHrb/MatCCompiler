#ifndef SYMBOL_H
#define SYMBOL_H
#define SYMBOL_MAX_NAME 64

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stdbool.h"

typedef union {
	int int_v;
	float float_v;
	void* null_v;
	char* string_v;
} symbol_value;

typedef enum {
	INT_, FLOAT_, STRING_, NULL_, ARRAY_
} symbol_type;

typedef struct dimension {
	int x;
	int y;
} symbol_dim;

typedef struct symbol {
	bool isConstant;
	char* id;
	symbol_dim dim;
	symbol_value value;
	symbol_type type;
	struct symbol* next;
} Symbol;

Symbol* symbol_alloc();
void symbol_free(Symbol* s);
Symbol* symbol_newtemp(Symbol** tds, symbol_type type);
Symbol* symbol_newcst_int(Symbol** tds, int cst);
Symbol* symbol_newcst_float(Symbol** tds, float cst);
Symbol* symbol_newcst_string(Symbol** tds, char* cst);
Symbol* symbol_lookup(Symbol** tds, char* id);
Symbol* symbol_add(Symbol** tds, char* id, symbol_type type);
void symbol_print(Symbol* s, bool header);
void symbol_table_print(Symbol** tds);

#endif	/*SYMBOL_H*/
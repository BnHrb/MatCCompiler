#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <stdlib.h>

#include "symbol.h"

enum operators
{
	PLUS_, MIN_, MUL_, DIV_, SUP_, INF_, SUPEQ_, INFEQ_, EQUAL_, ASSIGN_, GOTO_
};

typedef struct quad{
	int label;
	int op;
	Symbol* arg1;
	Symbol* arg2;
	Symbol* res;
	struct quad* next;
}Quad;

//               v-- Operator in one character
Quad* quad_gen  (int*, int, Symbol*, Symbol*, Symbol*);
void  quad_add  (Quad**, Quad*);
void  quad_free (Quad*);
char* get_op_name(int);
void  quad_print(Quad*);
#endif /*QUAD_H*/
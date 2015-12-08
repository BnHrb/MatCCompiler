#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <stdlib.h>

#include "symbol.h"

typedef struct quad{
	int label;
	char op;
	Symbol* arg1;
	Symbol* arg2;
	Symbol* res;
	struct quad* next;

	//       Quad to be update-v             v--the next quad 
	void  (*quad_add)  (struct quad*,struct quad*);
	void  (*quad_print)(struct quad*);
}Quad;

//               v-- Operator in one character
Quad* quad_gen  (int*, char, Symbol*, Symbol*, Symbol*);
void  quad_add  (Quad**, Quad*);
void  quad_free (Quad*);

#endif /*QUAD_H*/
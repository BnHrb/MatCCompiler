#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <stdlib.h>

#include "symbol.h"

typedef struct tquad{
	char op;
	Symbol* arg1;
	Symbol* arg2;
	Symbol* res;
	struct tquad* next;

	//       Quad to be update-v             v--the next quad 
	void  (*quad_add)  (struct tquad*,struct tquad*);
	void  (*quad_print)(struct tquad*);
}Quad;

//               v-- Operator in one character
Quad* quad_gen  (char, Symbol*, Symbol*, Symbol*);
void  quad_free (Quad*);

#endif /*QUAD_H*/
#ifndef QUAD_LIST_H
#define QUAD_LIST_H

#include "symbol.h"
#include "quad.h"

typedef struct quad_list{
	Quad *q;
	int count;
	struct quad_list *previous;
	struct quad_list *next;
}Quad_list;

Quad_list* quad_list_new  (Quad*);
void       quad_list_free (Quad_list*);
void 	   quad_list_complete(Quad_list*, Symbol*);
void 	   quad_list_add(Quad_list**, Quad_list*);
void       quad_list_print (Quad_list *);

#endif /*QUAD_LIST_H*/
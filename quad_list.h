#ifndef QUAD_LIST_H
#define QUAD_LIST_H

#include "symbol.h"
#include "quad.h"

typedef struct tquad_list{
	Quad *q;
	int count;
	struct tquad_list *previous;
	struct tquad_list *next;

	void (*quad_list_add)     (struct tquad_list*,struct tquad_list *);
	void (*quad_list_complete)(struct tquad_list*, Symbol*);
	void (*quad_list_print)   (struct tquad_list*);
}Quad_list;

Quad_list* quad_list_new  (Quad*);
void       quad_list_free (Quad_list*);

#endif /*QUAD_LIST_H*/
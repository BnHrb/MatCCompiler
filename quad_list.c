#include "quad_list.h"

void quad_list_print (Quad_list *ql)
{
	puts((ql != NULL?"List of quads:":"Quad list empty."));
	while(ql != NULL){
		quad_print(ql->q);
		ql = ql->next;
	}
}

void quad_list_complete (Quad_list* list, Symbol* label)
{
	while(list != NULL) {
		list->q->res = label;
		list = list->next;
	}
}

void quad_list_add(Quad_list** dest, Quad_list* src) {
	if(*dest == NULL) {
		*dest = src;
	}
	else {
		Quad_list* scan = *dest;
		while(scan->next != NULL)
			scan = scan->next;
		scan->next = src;
	}
}

Quad_list* quad_list_new  (Quad *q)
{
	Quad_list *ql = (Quad_list*)malloc(sizeof(Quad_list));
	ql->q = q;
	ql->previous = NULL;
	ql->next = NULL;
	return ql;
}

void quad_list_free (Quad_list *ql){
	free(ql);
}

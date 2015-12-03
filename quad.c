#include "quad.h"

Quad* quad_gen(char op, Symbol *arg1, Symbol *arg2, Symbol *Res)
{
	Quad *n = (Quad *)malloc(sizeof(Quad));
	n->op = op;
	n->arg1 = arg1;
	n->arg2 = arg2;
	n->res = Res;
	n->next = NULL;
	return n;
}

void  quad_free(Quad* s)
{
	s->op = 0;
	symbol_free(s->arg1);
	symbol_free(s->arg2);
	symbol_free(s->res);	
}
void  quad_add(Quad** list,Quad* n) //concatenacion
{
	if(list == NULL)
		(*list) = n;
	else {
		Quad *s = (*list);
		while(s->next != NULL)
			scan = scan->next;
		scan->next = n;
	}
}
void  quad_print(Quad* list) //print
{
	Quad *temp = list;
	while(temp != NULL)
	{
		printf("%c %7s %7s %7s\n",
			temp->op, temp->arg1->id,
			temp->arg2->id, temp->res);
		temp = temp->next;
	}
}
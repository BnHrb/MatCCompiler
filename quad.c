#include "quad.h" 	//Includes in the .h

void  quad_free(Quad* q)
{
	q->op = 0;
	quad_free(q->next);
	symbol_free(q->arg1);
	symbol_free(q->arg2);
	symbol_free(q->res);	
}

void  quad_add(Quad* q, Quad* nextq)
{
	q->next = nextq;
}

void  quad_print(Quad* q) //print
{
	printf("%c %7s %7s %7s\n",
		q->op, q->arg1->id,
		q->arg2->id, q->res->id);
}

Quad* quad_gen(char op, Symbol *arg1, Symbol *arg2, Symbol *Res)
{
	Quad *n = (Quad *)malloc(sizeof(Quad));
	n->op = op;
	n->arg1 = arg1;
	n->arg2 = arg2;
	n->res = Res;
	n->next = NULL;

	n->quad_add = quad_add;
	n->quad_print = quad_print;
	return n;
}
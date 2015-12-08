#include "quad.h" 	//Includes in the .h

static void  quad_print(Quad* q) //print
{
	printf("%c %7s %7s %7s\n",
		q->op, q->arg1->id,
		q->arg2->id, q->res->id);
}

void quad_add(Quad** q, Quad* nextq)
{
	if(*q == NULL) {
		*q = nextq;
	}
	else {
		Quad* scan = *q;
		while(scan->next != NULL)
			scan = scan->next;
		scan->next = nextq;
	}
}

Quad* quad_gen(int* label, char op, Symbol *arg1, Symbol *arg2, Symbol *Res)
{
	Quad *n = (Quad *)malloc(sizeof(Quad));
	n->label = *label;
	(*label)++;
	n->op = op;
	n->arg1 = arg1;
	n->arg2 = arg2;
	n->res = Res;
	n->next = NULL;

	n->quad_print = quad_print;
	return n;
}

void quad_free(Quad* q)
{
	q->op = 0;
	quad_free(q->next);
	symbol_free(q->arg1);
	symbol_free(q->arg2);
	symbol_free(q->res);	
}

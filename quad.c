#include "quad.h" 	//Includes in the .h

static void  quad_print(Quad* q) //print
{
	printf("Quads: \n");
	while(q != NULL)
	{
		printf("%s %7s %7s %7s\n",
			get_op_name(q->op),
			q->arg1!=NULL?q->arg1->id:"(null)",
			q->arg2!=NULL?q->arg2->id:"(null)",
			q->res!=NULL?q->res->id:"(null)");
		q=q->next;
	}
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

Quad* quad_gen(int* label, int op, Symbol *arg1, Symbol *arg2, Symbol *Res)
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
	Quad *p;
	while(q != NULL){
		p = q->next;
		symbol_free(q->arg1);
		symbol_free(q->arg2);
		symbol_free(q->res);
		free(q);
		q = p;
	}
}

char* get_op_name(int op) {
	switch(op){
		case 0:
			return "PLUS";
			break;
		case 1:
			return "MINUS";
			break;
		case 2:
			return "MUL";
			break;
		case 3:
			return "DIV";
			break;
		case 4:
			return "SUP";
			break;
		case 5:
			return "INF";
			break;
		case 6:
			return "SUPEQ";
			break;
		case 7:
			return "INFEQ";
			break;
		case 8:
			return "EQUAL";
			break;
		case 9:
			return "ASSIGN";
			break;
		case 10:
			return "GOTO";
			break;
	}

	return "NULL";
}

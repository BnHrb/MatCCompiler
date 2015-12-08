#include "quad_list.h"

/*static void quad_list_add (Quad_list *ql1, Quad_list *ql2)
{
	Quad_list *qltemp = ql1;

	while(qltemp->q->op < ql2->q->op && qltemp->next != NULL)
	{
		qltemp = qltemp->next;
	}


N = NULL or not taken into acount
        +qltemp+      +ql2----+
        |N|  |*|----->| 1|  |N|
        |N|  | |<-----|*2|  |N|
        +------+      +-------+
previous-^    ^-next
  region        region

  	qltemp->next = ql2;
  	ql2->previous = qltemp;


These are NOT USED because we don't need to know if a command comes before another.
N = NULL
+qltemp+      +ql2-----+      +ql1temp+
|N|  |*|----->| 1|  |3*|----->| |   |N|
|N|  | |<-----|*2|  |4 |<-----|*|   |N|
+------+      +--------+      +-------+
 ^-previous                     next-^
   region                     region

N = NULL
+ql1temp+      +ql2-----+      +qltemp+
|N|   |*|----->| 1|  |3*|----->| |  |N|
|N|   | |<-----|*2|  |4 |<-----|*|  |N|
+-------+      +--------+      +------+
 ^-previous                     next-^
   region                     region

}
*/

static void quad_list_print (Quad_list *ql)
{
	Quad_list* qltemp = ql;
	puts("LIST of QUADs:");
	do{
		qltemp->q->quad_print(qltemp->q);
		qltemp = qltemp->next;
	}
	while(qltemp->next != NULL);
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

	ql->quad_list_print = quad_list_print;
	return ql;
}

void quad_list_free (Quad_list *ql){
	free(ql);
}

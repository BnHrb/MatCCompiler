#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol.h"

Symbol* symbol_alloc() {
	Symbol* new = malloc(sizeof(Symbol));
	new->id = NULL;
	new->value = 0;
	new->next = NULL;
	new->isConstant = false;
	return new;
}

void symbol_free(Symbol* s) {
	free(s);
}

Symbol* symbol_add(Symbol** tds, char* id) {
	if(*tds == NULL) {
		Symbol* new = symbol_alloc();
		new->id = id;
		return new;
	}
	else {
		Symbol* tmp = *tds;
		while(tmp->next != NULL)
			tmp = tmp->next;
		tmp->next = symbol_alloc();
		tmp->next->id = id;
		return tmp->next;
	}
}

Symbol* symbol_newtemp(Symbol** tds) {
	static int nb_symbol = 0;
	char temp_name[SYMBOL_MAX_NAME];
	snprintf(temp_name, SYMBOL_MAX_NAME, "temp_%d", nb_symbol);
	nb_symbol++;
	return symbol_add(tds, temp_name);
}

Symbol* symbol_newcst(Symbol** tds, int cst) {
	Symbol* new = symbol_newtemp(tds);
	new->isConstant = true;
	new->value = cst;
	return new;
}

Symbol* symbol_lookup(Symbol** tds, char* id) {
	Symbol* tmp = *tds;
	while(tmp != NULL) {
		if(strcmp(tmp->id, id) == 0)
			break;
		tmp = tmp->next;
	}

	if(tmp != NULL)
		return tmp;
	else
		return NULL;
}

void symbol_print(Symbol* s) {
	printf("%s\n", s->id);
	printf("\tconstant : %s\n", s->isConstant);
	printf("\tvalue : %s\n", s->value);
}
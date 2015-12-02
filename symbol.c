#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol.h"

symbol* symbol_alloc() {
	symbol* new = malloc(sizeof(symbol));
	new->id = NULL;
	new->value = 0;
	new->next = NULL;
	new->isConstant = false;
	return new;
}

void symbol_free(symbol* s) {
	free(s);
}

symbol* symbol_add(symbol** tds, char* id) {
	if(*tds == NULL) {
		symbol* new = symbol_alloc();
		new->id = id;
		return new;
	}
	else {
		symbol* tmp = *tds;
		while(tmp->next != NULL)
			tmp = tmp->next;
		tmp->next = symbol_alloc();
		tmp->next->id = id;
		return tmp->next;
	}
}

symbol* symbol_newtemp(symbol** tds) {
	static int nb_symbol = 0;
	char temp_name[SYMBOL_MAX_NAME];
	snprintf(temp_name, SYMBOL_MAX_NAME, "temp_%d", nb_symbol);
	nb_symbol++;
	return symbol_add(tds, temp_name);
}

symbol* symbol_newcst(symbol** tds, int cst) {
	symbol* new = symbol_newtemp(tds);
	new->isConstant = true;
	new->value = cst;
	return new;
}

symbol* symbol_lookup(symbol* tds, char* id) {
	symbol* tmp = tds;
	while(tmp != NULL) {
		if(strcmp(tmp->id, id) == 0)
			break;
		tmp = tmp->next;
	}

	if(tmp != NULL)
		return tmp;
	else
		return NULL;
}

void symbol_print(symbol* s) {
	printf("%s\n", s->id);
	printf("\tconstant : %s\n", s->isConstant);
	printf("\tvalue : %s\n", s->value);
}
#include "symbol.h"

Symbol* symbol_alloc() {
	Symbol* new = malloc(sizeof(Symbol));
	new->id = (char*)malloc(sizeof(char));
	new->value = -100;
	new->next = NULL;
	new->isConstant = false;
	return new;
}

void symbol_free(Symbol* s) {
	if(s!=NULL)
	{
		free(s->id);
		free(s);
	}
}

Symbol* symbol_add(Symbol** tds, char* id) {
	if(*tds == NULL) {
		*tds = symbol_alloc();
		(*tds)->id = strdup(id);
		return *tds;
	}
	else {
		Symbol* tmp = *tds;
		while(tmp->next != NULL)
			tmp = tmp->next;
		tmp->next = symbol_alloc();
		tmp->next->id = strdup(id);
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
	return tmp;
}

void symbol_table_print(Symbol** tds) {	
	Symbol* tmp = *tds;
	printf("Symbol table :\n");
	printf("ID\t\tIsConstant\tValue\n");
	while(tmp != NULL) {
		symbol_print(tmp, false);
		tmp = tmp->next;
	}
}

void symbol_print(Symbol* s, bool header) {
	if(header)
		printf("ID\t\tIsConstant\tValue\n");
	printf("%s\t\t%s\t\t%d\n", s->id, (s->isConstant?"True":"False"), s->value);
}
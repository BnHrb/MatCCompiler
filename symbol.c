#include "symbol.h"

Symbol* symbol_alloc() {
	Symbol* new = malloc(sizeof(Symbol));
	new->id = (char*)malloc(sizeof(char));
	new->type = NULL_;
	new->value.null_v = NULL;
	new->next = NULL;
	new->isConstant = false;
	new->dim.x = 0;
	new->dim.y = 0;
	return new;
}

void symbol_free(Symbol* s) {
	if(s!=NULL)
	{
		free(s->id);
		free(s);
	}
}

Symbol* symbol_add(Symbol** tds, char* id, symbol_type type) {
	if(*tds == NULL) {
		char *temp=malloc(sizeof(char)*strlen(id));
		strcpy(temp,"var_");
		temp = strcat(temp,id);
		*tds = symbol_alloc();
		(*tds)->id = strdup(temp);
		(*tds)->type = type;
		free(temp);
		return *tds;
	}
	else {
		Symbol* tmp = *tds;
		char *temp=malloc(sizeof(char)*strlen(id));
		strcpy(temp,"var_");
		temp = strcat(temp,id);
		while(tmp->next != NULL)
			tmp = tmp->next;
		tmp->next = symbol_alloc();
		tmp->next->id = strdup(temp);
		tmp->next->type = type;
		free(temp);
		return tmp->next;
	}
}

Symbol* symbol_newtemp(Symbol** tds, symbol_type type) {
	static int nb_symbol = 0;
	char temp_name[SYMBOL_MAX_NAME];
	snprintf(temp_name, SYMBOL_MAX_NAME, "temp_%d", nb_symbol);
	nb_symbol++;
	return symbol_add(tds, temp_name, type);
}

Symbol* symbol_newcst_int(Symbol** tds, int cst) {
	Symbol* new = symbol_newtemp(tds, INT_);
	new->isConstant = true;
	new->value.int_v = cst;
	return new;
}

Symbol* symbol_newcst_float(Symbol** tds, float cst) {
	Symbol* new = symbol_newtemp(tds, FLOAT_);
	new->isConstant = true;
	new->value.float_v = cst;
	return new;
}

Symbol* symbol_newcst_string(Symbol** tds, char* cst) {
	Symbol* new = symbol_newtemp(tds, STRING_);
	new->isConstant = true;
	new->value.string_v = strdup(cst);
	return new;
}

Symbol* symbol_lookup(Symbol** tds, char* id) {
	Symbol* tmp = *tds;
	char *temp_id=malloc(sizeof(char)*strlen(id));
	strcpy(temp_id,"var_");
	temp_id = strcat(temp_id,id);
	while(tmp != NULL) {
		if(strcmp(tmp->id, temp_id) == 0)
			break;
		tmp = tmp->next;
	}
	free(temp_id);
	return tmp;
}

void symbol_table_print(Symbol** tds) {	
	Symbol* tmp = *tds;
	printf("\nSymbol table :\n");
	printf("ID\t\tIsConstant\tValue\n");
	while(tmp != NULL) {
		symbol_print(tmp, false);
		tmp = tmp->next;
	}
}

void symbol_print(Symbol* s, bool header) {
	if(header)
		printf("ID\t\tIsConstant\tValue\n");

	switch(s->type) {
		case INT_:
			printf("%s\t\t%s\t\t%d\n", s->id, (s->isConstant?"True":"False"), s->value.int_v);
			break;
		case FLOAT_:
			printf("%s\t\t%s\t\t%f\n", s->id, (s->isConstant?"True":"False"), s->value.float_v);
			break;
		case STRING_:
			printf("%s\t\t%s\t\t%s\n", s->id, (s->isConstant?"True":"False"), s->value.string_v);
			break;
		case NULL_:
			printf("%s\t\t%s\t\t%s\n", s->id, (s->isConstant?"True":"False"), "n/a");
			break;
		case ARRAY_:
			printf("%s\t\t%s\t\tx:%dy:%d\n", s->id, (s->isConstant?"True":"False"), s->dim.x, s->dim.y);
			break;
	}
}

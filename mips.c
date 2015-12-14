#include "mips.h"

int translate_to_mips(FILE *output, Symbol* symbol_table, Quad* code) {
	fprintf(output, "\t.data\n");
	while(symbol_table != NULL){
		if(symbol_table->isConstant)
			fprintf(output, "%s:\t.word %d\n", symbol_table->id, symbol_table->value);
		symbol_table = symbol_table->next;
	}
	fprintf(output, "\t.globl main\n");

	fprintf(output,"main: ");
	while(code!=NULL)
	{
		switch(code->op)
		{
			case ADD_:
				fprintf(stdout, "PLUS %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n",code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "addu $t2, $t0, $t1\n");
				fprintf(output, "sw $t2, %s\n",code->res->id);
			break;
			case MIN_:
				fprintf(stdout, "MIN %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n",code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "subu $t2, $t0, $t1\n");
				fprintf(output, "sw $t2, %s\n",code->res->id);
			break;
			case MUL_:
				fprintf(stdout, "MUL %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n",code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "mul $t2, $t0, $t1\n");
				fprintf(output, "sw $t2, %s\n",code->res->id);
			break;
			case DIV_:
				fprintf(stdout, "DIV %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n",code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "div $t2, $t0, $t1\n");
				fprintf(output, "sw $t2, %s\n",code->res->id);
			break;
			case SUP_:
				fprintf(stdout, "SUPERIOR %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n",code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "sle $t8, $t1, $t0\n");
				fprintf(output, "beq $t8, 1, %s\n",code->res->id);
			break;
			case INF_:
				fprintf(stdout, "INF %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n",code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "sgt $t8, $t0, $t1\n");
				fprintf(output, "beq $t8, 1, %s\n",code->res->id);
			break;
			case SUPEQ_:
				fprintf(stdout, "SUPEQ %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n", code->arg1->id);
				fprintf(output, "lw $t1, %s\n",code->arg2->id);
				fprintf(output, "slt $t8, $t0, $t1\n");
				fprintf(output, "beq $t8, 1, %s\n", code->res->id);
			break;
			case INFEQ_:
				fprintf(stdout, "INFEQ %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n", code->arg1->id);
				fprintf(output, "lw $t1, %s\n", code->arg2->id);
				fprintf(output, "sle $t8, $t0, $t1\n");
				fprintf(output, "beq $t8, 1, %s\n", code->res->id);
			break;
			case EQUAL_:
				fprintf(stdout, "EQUAL %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "lw $t0, %s\n", code->arg1->id);
				fprintf(output, "beq $t8, %s, %s\n", code->arg2->id, code->res->id);
			break;
			case ASSIGN_:
				fprintf(stdout, "ASSIGN %s %s\n",code->arg1->id, code->res->id);
				fprintf(output, "lw $t0, %s\n", code->arg1->id);
				fprintf(output, "sw $t0, %s\n", code->res->id);
			break;
			case GOTO_:
				fprintf(stdout, "GOTO %s\n", code->res->id);
				fprintf(output, "j %s\n",code->res->id);
			break;
		}
		code = code->next;
	}
	return 0;
}
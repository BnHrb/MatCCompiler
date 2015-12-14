#include "mips.h"

int translate_to_mips(FILE *output, Symbol* symbol_table, Quad* code) {
	fprintf(output, "\t.data\n");
	while(symbol_table != NULL){
		if(symbol_table->isConstant)
			fprintf(output, "%s:\t.word %d\n", symbol_table->id, symbol_table->value);
		symbol_table = symbol_table->next;
	}
	fprintf(output, "\t.globl main\n");

	fprintf(output,"\t.text\nmain: ");
	while(code!=NULL)
	{
		if(code->label > 0)
			fprintf(output, "next%d:",code->label);
		switch(code->op)
		{
			case ADD_:
				fprintf(stdout, "PLUS %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\taddu $t2, $t0, $t1\n");
				fprintf(output, "\tsw $t2, %s\n",code->res->id);
			break;
			case MIN_:
				fprintf(stdout, "MIN %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\tsubu $t2, $t0, $t1\n");
				fprintf(output, "\tsw $t2, %s\n",code->res->id);
			break;
			case MUL_:
				fprintf(stdout, "MUL %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\tmul $t2, $t0, $t1\n");
				fprintf(output, "\tsw $t2, %s\n",code->res->id);
			break;
			case DIV_:
				fprintf(stdout, "DIV %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\tdiv $t2, $t0, $t1\n");
				fprintf(output, "\tsw $t2, %s\n",code->res->id);
			break;
			case SUP_:
				fprintf(stdout, "SUPERIOR %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\tsgt $t8, $t0, $t1\n");
				fprintf(output, "\tbne $t8, 1, next%d\n",code->next->label);
			break;
			case INF_:
				fprintf(stdout, "INF %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\tslt $t8, $t0, $t1\n");
				fprintf(output, "\tbne $t8, 1, next%d\n",code->next->label);
			break;
			case SUPEQ_:
				fprintf(stdout, "SUPEQ %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n", code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
				fprintf(output, "\tsge $t8, $t0, $t1\n");
				fprintf(output, "\tbne $t8, 1, next%d\n", code->next->label);
			break;
			case INFEQ_:
				fprintf(stdout, "INFEQ %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n", code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n", code->arg2->id);
				fprintf(output, "\tsle $t8, $t0, $t1\n");
				fprintf(output, "\tbne $t8, 1, next%d\n", code->next->label);
			break;
			case EQUAL_:
				fprintf(stdout, "EQUAL %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				fprintf(output, "\tlw $t0, %s\n", code->arg1->id);
				fprintf(output, "\tlw $t1, %s\n", code->arg2->id);
				fprintf(output, "\tbne $t8, $t1, next%d\n", code->next->label);
			break;
			case ASSIGN_:
				fprintf(stdout, "ASSIGN %s %s\n",code->arg1->id, code->res->id);
				fprintf(output, "\tlw $t0, %s\n", code->arg1->id);
				fprintf(output, "\tsw $t0, %s\n", code->res->id);
			break;
			case GOTO_:
				{
					//Symbol *s = symbol_lookup(&symbol_table, code->res->id);
					fprintf(stdout, "GOTO %s\n", code->res->id);
					fprintf(output, "\tj next%d\n",code->next->label);
				}
			break;
			case NOP_:
				fprintf(output, "\t#NOP\n");
				fprintf(output, "\tnop\n");
			break;
		}
		code = code->next;
	}
	return 0;
}
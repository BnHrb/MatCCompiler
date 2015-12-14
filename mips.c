#include "mips.h"

int translate_to_mips(FILE *output, Symbol* symbol_table, Quad* code) {
	fprintf(output, "\t.data\n");
	while(symbol_table != NULL){
		if(symbol_table->isConstant || 1){
			switch(symbol_table->type){
				case INT_:
					fprintf(output, "%s:\t.word %d\n",
						symbol_table->id, symbol_table->value.int_v);
				break;
				case FLOAT_:
					fprintf(output, "%s:\t.float %f\n",
						symbol_table->id, symbol_table->value.float_v);
				break;
				case STRING_:
					fprintf(output, "%s:\t.asciiz \"%s\"\n",
						symbol_table->id, symbol_table->value.string_v);
				break;
				default:break;
			}
		}
		symbol_table = symbol_table->next;
	}
	fprintf(output, "\t.text\n\t.globl main\n");

	fprintf(output,"main: ");
	while(code!=NULL)
	{
		if(code->label > 0 && code->op != NOP_)
			fprintf(output, "next%d:",code->label);
		switch(code->op)
		{
			case ADD_:
				fprintf(stdout, "PLUS %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				switch(code->arg1->type)
				{
					case INT_:
					fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
					fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
					fprintf(output, "\taddu $t2, $t0, $t1\n");
					fprintf(output, "\tsw $t2, %s\n",code->res->id);
					break;
					case FLOAT_:
					fprintf(output, "\tli.s $f0, %f\n",code->arg1->value.float_v);
					fprintf(output, "\tli.s $f1, %f\n",code->arg2->value.float_v);
					fprintf(output, "\tadd.s $f2, $f0, $f1\n");
					fprintf(output, "\ts.s $f2, %s\n",code->res->id);
					break;
					default:break;
				}
			break;
			case MIN_:
				fprintf(stdout, "MIN %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				switch(code->arg1->type)
				{
					case INT_:
					fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
					fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
					fprintf(output, "\tsubu $t2, $t0, $t1\n");
					fprintf(output, "\tsw $t2, %s\n",code->res->id);
					break;
					case FLOAT_:
					fprintf(output, "\tli.s $f0, %f\n",code->arg1->value.float_v);
					fprintf(output, "\tli.s $f1, %f\n",code->arg2->value.float_v);
					fprintf(output, "\tsub.s $f2, $f0, $f1\n");
					fprintf(output, "\ts.s $f2, %s\n",code->res->id);
					break;
					default:break;
				}
			break;
			case MUL_:
				fprintf(stdout, "MUL %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				switch(code->arg1->type)
				{
					case INT_:
					fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
					fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
					fprintf(output, "\tmul $t2, $t0, $t1\n");
					fprintf(output, "\tsw $t2, %s\n",code->res->id);
					break;
					case FLOAT_:
					fprintf(output, "\tli.s $f0, %f\n",code->arg1->value.float_v);
					fprintf(output, "\tli.s $f1, %f\n",code->arg2->value.float_v);
					fprintf(output, "\tmul.s $f2, $f0, $f1\n");
					fprintf(output, "\ts.s $f2, %s\n",code->res->id);
					break;
					default:break;
				}
			break;
			case DIV_:
				fprintf(stdout, "DIV %s %s %s\n",code->arg1->id, code->arg2->id , code->res->id);
				switch(code->arg1->type)
				{
					case INT_:
					fprintf(output, "\tlw $t0, %s\n",code->arg1->id);
					fprintf(output, "\tlw $t1, %s\n",code->arg2->id);
					fprintf(output, "\tdiv $t2, $t0, $t1\n");
					fprintf(output, "\tsw $t2, %s\n",code->res->id);
					break;
					case FLOAT_:
					fprintf(output, "\tli.s $f0, %f\n",code->arg1->value.float_v);
					fprintf(output, "\tli.s $f1, %f\n",code->arg2->value.float_v);
					fprintf(output, "\tdiv.s $f2, $f0, $f1\n");
					fprintf(output, "\ts.s $f2, %s\n",code->res->id);
					break;
					default:break;
				}
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
				switch(code->arg1->type)
				{
					case INT_:
					fprintf(output, "\tlw $t0, %s\n", code->arg1->id);
					fprintf(output, "\tsw $t0, %s\n", code->res->id);
					break;
					case FLOAT_:
					fprintf(output, "\tli.s $f0, %f\n", code->arg1->value.float_v);
					fprintf(output, "\ts.s $f0, %s\n", code->res->id);
					break;
					default:break;
				}
			break;
			case GOTO_:
				{
					//Symbol *s = symbol_lookup(&symbol_table, code->res->id);
					fprintf(stdout, "GOTO %s\n", code->res->id);
					fprintf(output, "\tj next%d\n",code->next->label);
				}
			break;
			/*case NOP_:
				fprintf(output, "\t#NOP\n");
				fprintf(output, "\tnop\n");
			break;*/
			case PRINTF_:
			case PRINT_:
				switch(code->arg1->type){
					case INT_:
					fprintf(output, "\tli $v0, 1\n");
					fprintf(output, "\tla $a0, %s\n",code->arg1->id);
					break;
					case FLOAT_:
					fprintf(output, "\tli $v0, 2\n");
					fprintf(output, "\tla $f12, %s\n",code->arg1->id);
					break;
					case STRING_:
					fprintf(output, "\tli $v0, 4\n");
					fprintf(output, "\tla $a0, %s\n",code->arg1->id);
					break;
					case NULL_:
					fprintf(output, "\tli $v0, 4\n");
					fprintf(output, "\tla $a0, \"null\"\n");
					break;
				}
				fprintf(output, "\tsyscall\n");
			break;
		}
		code = code->next;
	}
	return 0;
}
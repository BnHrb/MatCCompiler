all:
	yacc -d compiler.y
	lex compiler.l 
	gcc symbol.c quad.c quad_list.c lex.yy.c y.tab.c -lfl -o MatC

clear:
	rm lex.yy.c y.tab.c y.tab.h
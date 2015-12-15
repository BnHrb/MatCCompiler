CFLAGS=-Wall -lfl
YACC_FILE=compiler.y
LEX_FILE=compiler.l
CC=gcc
C_SOURCES=mips.c symbol.c quad.c quad_list.c lex.yy.c y.tab.c
OUTPUT=MatC
FILESTOREMOVE=lex.yy.c y.tab.c y.tab.h $(OUTPUT)

all:
	yacc -d $(YACC_FILE)
	lex $(LEX_FILE)
	$(CC) $(C_SOURCES) $(CFLAGS) -o $(OUTPUT)

clear:
	rm $(FILESTOREMOVE)
#include "symbol.h"

typedef struct tquad{
	char *op;
	Symbol* arg1;
	Symbol* arg2;
	Symbol* res;
}Quad;

                  //  v-- exquad (operatuer em um char)
Quad* quad_gen(int *, char, Symbol*, Symbol*, Symbol*);
void  quad_free(Quad*);
void  quad_add(Quad**,Quad*); //concatenacion
void  quad_print(Quad*); //concatenacion



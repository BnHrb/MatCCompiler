#ifndef MIPS_H
#define MIPS_H
#include <stdlib.h>
#include <stdio.h>
#include "quad.h"

int translate_to_mips(FILE *, Symbol*, Quad*);

#endif /*MIPS_H*/
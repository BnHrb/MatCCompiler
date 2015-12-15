# MatCCompiler
Projet de compilation M1 RISE

Benjamin Herb
Fabricio Santolin da Silva


Utilisation
------------

make
./MatC < file >
spim -f output.s

Fonctionnalités implémentées
-----------------------------------
- Reconnaissance du langage MatC, excepté l'opération d'extraction d'une matrice
- Traduction en quads des opérations : if, if else, while, for, affectation, déclaration, conditions, incrémentation, décrémentation, print, printf, opérations arithmétiques, return, opérations sur un tableau de int à une ou deux dimensions. 
- Gestion du type int et float


Fonctionnalités non implémentées
-----------------------------------------
- La génération en quads et en mips des opérations sur le type matrix 
- La génération en quads et en mips de l'affectation d'une liste de nombre à un tableau (ex: a[ 2 ] = {1,2}; )
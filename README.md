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

Traduction en MIPS
---------------------------
- Distinction des types (int, float, asciiz)
- Opérations : addition, soustraction, multiplication, division, affectation.
- Comparaisons : > , < , >=, <=, ==, !=, 
- Contrôle de flux : goto, for, while, if [else]

Fonctionnalités non implémentées
-----------------------------------------
- La génération en quads et en mips des opérations sur le type matrix 
- La génération en quads et en mips de l'affectation d'une liste de nombre à un tableau (ex: a[ 2 ] = {1,2}; )

Fonctionnalités non implémentées (dans la traduction en Mips)
-------------------------------------------------------------------
- Pas des arrays/matrices
- Sans conversion (int <-> float)
- La fonction "print" n'avais pas "new line" ('\n')
- Le retour est fixé ("hard coded")
- Étiquettes dupliquées
- No scope (variables globales)
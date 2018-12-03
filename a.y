%{
#include <stdio.h>
#include <stdlib.h>
char* concat(char* cad1, char* cad2, int tam);
char* voltear(char* cadena, int tam);
int len(char* cad);
%}

%union{
	int entero;
    double decimal;
    char* cadena;
}
%token <entero> TK_ENTERO
%token <decimal> TK_DECIMAL
%token <cadena> TK_CADENA
%token OP_SUMA
%token OP_RESTA
%token OP_MULTI
%token OP_DIV
%token TK_LF
%token OP_POT

%left OP_SUMA OP_RESTA
%left OP_MULTI OP_DIV OP_POT

%type <entero> enteros
%type <decimal> decimales
%type <cadena> cadenas


%%
input:
    | input line
    ;

line: TK_LF
    | enteros TK_LF { printf("\tResultado: %d\n", $1); }
    | decimales TK_LF { printf("\tResultado: %f\n", $1); }
    | cadenas TK_LF { printf("\tResultado: %s\n", $1); }
    ;

enteros: TK_ENTERO { $$ = $1; }
    | OP_RESTA enteros { $$ = -$2; }
    | enteros OP_SUMA enteros { $$ = $1 + $3; }
    | enteros OP_RESTA enteros { $$ = $1 - $3; }
    | enteros OP_MULTI enteros { $$ = $1 * $3; }
    | enteros OP_DIV enteros { $$ = $1 / $3; }
    ;

cadenas: TK_CADENA { $$ = $1; }
    | cadenas OP_SUMA cadenas {
        int nuevaLen = len($1)+len($3) - 1;
        char* cad = concat($1, $3, nuevaLen);
        $$ = cad;
    }
    | cadenas OP_POT enteros {
        int nuevaLen = 0;
        char* original = $1;
        char* cad = "";
        int i = 0;
	if($3 >= 0){
	   do{
	      nuevaLen = len($1)*$3 + 1;
	      cad = concat(cad, original, nuevaLen);
	      ++i;
	   }
	   while(i < $3);
	}
	else{
	   int k = -$3;
	   original = voltear($1, len($1));
	   do{
	      nuevaLen = len($1)*k + 1;
	      cad = concat(cad, original, nuevaLen);
	      ++i;
	   } while(i < k);
	}
        $$ = cad;
    }
    ;

decimales: TK_DECIMAL { $$ = $1; }
    | OP_RESTA decimales { $$ = -$2; }
    | decimales OP_SUMA decimales { $$ = $1 + $3; }
    | decimales OP_RESTA decimales { $$ = $1 - $3; }
    | decimales OP_MULTI decimales { $$ = $1 * $3; }
    | decimales OP_DIV decimales { $$ = $1 / $3; }

    | enteros OP_SUMA decimales { $$ = $1 + $3; }
    | enteros OP_RESTA decimales { $$ = $1 - $3; }
    | enteros OP_MULTI decimales { $$ = $1 * $3; }
    | enteros OP_DIV decimales { $$ = $1 / $3; }

    | decimales OP_SUMA enteros { $$ = $1 + $3; }
    | decimales OP_RESTA enteros { $$ = $1 - $3; }
    | decimales OP_MULTI enteros { $$ = $1 * $3; }
    | decimales OP_DIV enteros { $$ = $1 / $3; }
    ;

%%
int main(int argc, char **argv){
	yyparse();
	return 0;
}

int yywrap() {
	return 1;
}

void yyerror(const char *s){
	printf("Error: %s\n", s);
}

int len(char* cad){
    int i = 0;
    while(cad[i]){
        i++;
    }

    return i;
}

char* concat(char* cad1, char* cad2, int tam){
    int i = 0, j = 0;
    char* concatenada = malloc(tam);

    while(cad1[i]){
        concatenada[j] = cad1[i];
        j++;
        i++;
    }

    i = 0;
    while(cad2[i]){
        concatenada[j] = cad2[i];
        j++;
        i++;
    }

    concatenada[j] = '\0';   

    return concatenada;
}

char* voltear(char* cadena, int tam){
    char* volteada = malloc(tam);

    int i, j;
    for(i = tam - 1, j = 0; i >= 0; i--, j++){
        volteada[j] = cadena[i];
    }

    return volteada;
}

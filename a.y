%{
#include <stdio.h>
#include <stdlib.h>

char* concat(char* cad1, char* cad2, int tam);
char* voltear(char* cadena, int tam);
int arrtam(char* cad);

struct variable* tabla_simbolos;
int tam_tabla;
int ele_tabla;
%}

%union{
	int entero;
	double decimal;
	char* cadena;
	union {
	   int entero;
	   double db;
	   char* cadena;
	   char* nombre;
	   char* tipo; 
	} variable;
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
%token <variable> TK_VARIABLE
%token OP_ASIGNA
%token TK_T_ENT
%token TK_T_DB
%token TK_T_STR
%token TK_END_E

%left OP_SUMA OP_RESTA
%left OP_MULTI OP_DIV OP_POT

%type <entero> enteros
%type <decimal> decimales
%type <cadena> cadenas
%type <variable> variables

%%

input:
    | input line
    ;

line: TK_LF
    | enteros TK_LF { printf("\tResultado: %d\n", $1); }
    | decimales TK_LF { printf("\tResultado: %f\n", $1); }
    | cadenas TK_LF { printf("\tResultado: %s\n", $1); }
    | variables TK_LF {
	printf("\taaaalv\n");
	if($1.tipo == "int"){
	   printf("\t%d\n", $1.entero);
	}else if($1.tipo == "double"){
	   printf("\t%f\n", $1.db);
	}else if($1.tipo == "string"){
	   printf("\t%s\n", $1.cadena);
	}
    }
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
        int nuevaarrtam = arrtam($1)+arrtam($3) - 1;
        char* cad = concat($1, $3, nuevaarrtam);
        $$ = cad;
    }
    | cadenas OP_POT enteros {
        int nuevaarrtam = 0;
        char* original = $1;
        char* cad = "";
        int i = 0;
	if($3 > 0){
	   do{
	      nuevaarrtam = arrtam($1)*$3 + 1;
	      cad = concat(cad, original, nuevaarrtam);
	      ++i;
	   }
	   while(i < $3);
	}
	else if($3 == 0){
	   cad = "";
	}
	else{
	   int k = -$3;
	   original = voltear($1, arrtam($1));
	   do{
	      nuevaarrtam = arrtam($1)*k + 1;
	      cad = concat(cad, original, nuevaarrtam);
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

variables: TK_VARIABLE { $$ = $1; }
    | TK_T_ENT TK_VARIABLE TK_END_E {
        
    }
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

int arrtam(char* cad){
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

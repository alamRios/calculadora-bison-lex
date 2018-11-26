%{
	#include <stdio.h>
	#include <stdlib.h>

	char* concat(char* str1, char* str2);
	int len(char* str);
%}

%union{
	int entero; 
	double decimal;
	char* cadena;
}

%token <entero> ENTERO; 
%token <decimal> DECIMAL; 
%token <cadena> CADENA;

%left "+" "-"
%left "*" "/"

%type <entero> enteros
%type <decimal> decimales
%type <cadena> cadenas

%%
input: 
	| input line
	;
line: "\n"
	| enteros "\n" { printf("\tResultado: %d\n",$1); }
	| decimales "\n" { printf("\tResultado: %f\n",$1); }
	| cadenas "\n" { printf("\tResultado: %s\n",$1); }
	;
enteros: ENTERO { $$ = $1; }
	| "-" ENTERO { $$ = -$2; }
	| enteros "+" enteros { $$ = $1 + $3; }
	| enteros "-" enteros { $$ = $1 - $3; }
	| enteros "*" enteros { $$ = $1 * $3; }
	| enteros "/" enteros { $$ = $1 / $3; }
	;
decimales: DECIMAL { $$ = $1; }
	| "-" DECIMAL { $$ = -$2; }
	| decimales "+" decimales { $$ = $1 + $3; }
	| decimales "-" decimales { $$ = $1 - $3; }
	| decimales "*" decimales { $$ = $1 * $3; }
	| decimales "/" decimales { $$ = $1 / $3; }
	
	| enteros "+" decimales { $$ = $1 + $3; }
	| enteros "-" decimales { $$ = $1 - $3; }
	| enteros "*" decimales { $$ = $1 * $3; }
	| enteros "/" decimales { $$ = $1 / $3; }

	| decimales "+" enteros { $$ = $1 + $3; }
	| decimales "-" enteros { $$ = $1 - $3; }
	| decimales "*" enteros { $$ = $1 * $3; }
	| decimales "/" enteros { $$ = $1 / $3; }
	;
cadenas: CADENA { $$ = $1; }
	| cadenas "+" cadenas {
		char* aux = concat($1,$3);
		$$ = aux;
		}
	;

%%
int main(int argc, char **argv){
	yyparse();
	return 0;
}

int yywrap(){
	return 1;
}

void yyerror(const char* s){
	printf("Error: %s\n", s);
}

char* concat(char* str1, char* str2){
	int i=0, j=0;
	char* res = malloc(len(str1)+len(str2)+1);
	while(str1[i]){
		res[j++] = str1[i++];
	}
	
	i = 0;
	while(str2[i]){
		res[j++] = str2[i++];
	}
	res[j] = '\0';
	
	return res;
}

int len(char* str){
	int i = 0; 
	while(str[i]){ i++; }
	return i;
}


%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "a.tab.h"
%}

NUMERO [0-9]+
DECIMAL [0-9]*"."[0-9]+
CADENA \"[^\"]\"
%%

{NUMERO} {
	yylval.entero = atoi(yytext);
	return ENTERO;
	}
{DECIMAL} {
	yylval.decimal = atof(yytext);
	return DECIMAL;
	}
{CADENA} {
	char* aux = malloc(255); 
	int i = 0;
	while(yytext[i+2]){
		aux[i++] = yytext[i+1];
		}
	aux[i] = '\0';
	yylval.cadena = aux;
	return CADENA;
	}
"+"|"-"|"/"|"*"|\n { return yytext[0];}
.	;
%%

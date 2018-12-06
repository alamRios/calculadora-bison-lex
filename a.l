%{
#include <stdio.h>
#include <stdlib.h>
#include "a.tab.h"
%}

decimal [0-9]*\.[0-9]+
entero [0-9]+
cadena \"[^\"]+\"
variable [a-zA-Z_]+[a-zA-Z0-9_-]*

%%
; {
	return TK_END_E;
}

int {
	return TK_T_ENT;
}

double {
	return TK_T_DB;
}

string {
	return TK_T_STR;
}

{variable} {
	int i = 0;
	char* cadena = malloc(arrtam(yytext));
	while(yytext[i]){
		cadena[i] = yytext[i];
		i++;
	}
	cadena[i] = '\0';
	yylval.variable.nombre = cadena;
	return TK_VARIABLE;
}

{decimal} {
	yylval.decimal = atof(yytext);
	return TK_DECIMAL;
}

{entero} {
	yylval.entero = atoi(yytext);
	return TK_ENTERO;
}

{cadena} {
	int i = 0;
	char* cadena = malloc(arrtam(yytext));
	while(yytext[i + 2]){
		cadena[i] = yytext[i+1];
		i++;
	}
	cadena[i] = '\0';
	yylval.cadena = cadena;
	return TK_CADENA;
}

\n {
	return TK_LF;
}

\+ {
	return OP_SUMA;
}

\- {
	return OP_RESTA;
}
\* {
	return OP_MULTI;
}
\/ {
	return OP_DIV;
}
\^ {
	return OP_POT;
}
"=" {
	return OP_ASIGNA;
}

.	;

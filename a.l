%{
#include <stdio.h>
#include <stdlib.h>
#include "practica.tab.h"
%}

digito [0-9]
decimal {digito}*\.{digito}+
entero {digito}+
cadena \"[^\"]+\"
%%

{decimal} {
	printf("Número decimal %s\n", yytext);
	yylval.decimal = atof(yytext);
	return TOK_DECIMAL;
}

{entero} {
	printf("Número entero %s\n", yytext);
	yylval.entero = atoi(yytext);
	return TOK_ENTERO;
}

{cadena} {
	printf("Cadena de texto\n");
	int i = 0;
	char* cadena = malloc(cadlen(yytext));
	while(yytext[i + 2]){
		cadena[i] = yytext[i+1];
		i++;
	}
	cadena[i] = '\0';
	yylval.cadena = cadena;
	return TOK_CADENA;
}

\n {
	return TOK_LF;
}

\+ {
	printf("Operador\n");
	return TOK_SUMA;
}

\- {
	printf("Operador\n");
	return TOK_RESTA;
}
\* {
	printf("Operador\n");
	return TOK_MULTI;
}
\/ {
	printf("Operador\n");
	return TOK_DIV;
}

.	;

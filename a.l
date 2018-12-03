%{
#include <stdio.h>
#include <stdlib.h>
#include "a.tab.h"
%}

decimal [0-9]*\.[0-9]+
entero [0-9]+
cadena \"[^\"]+\"
%%

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
	char* cadena = malloc(len(yytext));
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

.	;

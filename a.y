%{
#include <stdio.h>
#include <stdlib.h>

char* concat(char* cad1, char* cad2, int tam);
char* voltear(char* cadena, int tam);
int arrtam(char* cad);
void calcsubs(char* b, int rlen, int lps[]);
int compare(char *a, char *b);
struct variable buscarEnTabla(char* nombre);
struct variable* buscarEnTablaApuntador(char* nombre);

struct variable* tabla_simbolos;
int tam_tabla;

void imprimirTablaSimbolos();
%}

%union{
	int entero;
	double decimal;
	char* cadena;
	struct variable{
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
    | enteros TK_LF { printf("\t%d\n", $1); }
    | decimales TK_LF { printf("\t%f\n", $1); }
    | cadenas TK_LF { printf("\t%s\n", $1); }
    | variables TK_LF {
        //imprimirTablaSimbolos();
        struct variable var = buscarEnTabla($1.nombre);
        if(var.tipo == "int"){
            printf("\t%d\n", var.entero);
        }else if(var.tipo == "double"){
            printf("\t%f\n", var.db);
        }else if(var.tipo == "string"){
            printf("\t'%s'\n", var.cadena);
        }else{
            printf("\tERROR: Variable '%s' no declarada.\n",$1.nombre);
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
    | cadenas OP_RESTA cadenas {
        int pi = ($1,$3);
        char *res;
        if(pi != -1){
            int len = arrtam($1) - arrtam($3);
            int i=0, j=0;
            res = malloc(len);
            while(i < len){
                if(i != pi){
                    res[i] = $1[j];
                }else{
                    j += arrtam($3);
                    res[i] = $1[j];
                }
                i++;
                j++;
            }

            $$ = res;
        }else{
            $$ = $1;
        }
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
    |   TK_T_ENT TK_VARIABLE TK_END_E {
        struct variable* variable_ = malloc(sizeof(struct variable));
        variable_->tipo = "int"; 
        variable_->entero = 0;
        variable_->nombre = $2.nombre;

        tabla_simbolos = (struct variable*)realloc(tabla_simbolos,++tam_tabla*sizeof(struct variable));
        tabla_simbolos[tam_tabla-1] = *variable_;
        $$ = *variable_;
    }
    |   TK_T_ENT TK_VARIABLE OP_ASIGNA enteros TK_END_E {
        struct variable* variable_ = malloc(sizeof(struct variable));
        variable_->tipo = "int"; 
        variable_->entero = $4;
        variable_->nombre = $2.nombre;

        tabla_simbolos = (struct variable*)realloc(tabla_simbolos,++tam_tabla*sizeof(struct variable));
        tabla_simbolos[tam_tabla-1] = *variable_;
        $$ = *variable_;
    }
    |   TK_VARIABLE OP_ASIGNA enteros TK_END_E {
        struct variable* variable_ = buscarEnTablaApuntador($1.nombre);
        variable_->entero = $3;
        $$ = *variable_;
    }
    |   TK_T_DB TK_VARIABLE TK_END_E {
        struct variable* variable_ = malloc(sizeof(struct variable));
        variable_->tipo = "double"; 
        variable_->db = 0;
        variable_->nombre = $2.nombre;

        tabla_simbolos = (struct variable*)realloc(tabla_simbolos,++tam_tabla*sizeof(struct variable));
        tabla_simbolos[tam_tabla-1] = *variable_;
        $$ = *variable_;
    }
    |   TK_T_DB TK_VARIABLE OP_ASIGNA decimales TK_END_E {
        struct variable* variable_ = malloc(sizeof(struct variable));
        variable_->tipo = "int"; 
        variable_->entero = $4;
        variable_->nombre = $2.nombre;

        tabla_simbolos = (struct variable*)realloc(tabla_simbolos,++tam_tabla*sizeof(struct variable));
        tabla_simbolos[tam_tabla-1] = *variable_;
        $$ = *variable_;
    }
    |   TK_VARIABLE OP_ASIGNA decimales TK_END_E {
        struct variable* variable_ = buscarEnTablaApuntador($1.nombre);
        variable_->db = $3;
        $$ = *variable_;
    }
    |   TK_T_STR TK_VARIABLE TK_END_E {
        struct variable* variable_ = malloc(sizeof(struct variable));
        variable_->tipo = "string"; 
        variable_->cadena = "";
        variable_->nombre = $2.nombre;

        tabla_simbolos = (struct variable*)realloc(tabla_simbolos,++tam_tabla*sizeof(struct variable));
        tabla_simbolos[tam_tabla-1] = *variable_;
        $$ = *variable_;
    }
    |   TK_T_STR TK_VARIABLE OP_ASIGNA cadenas TK_END_E {
        struct variable* variable_ = malloc(sizeof(struct variable));
        variable_->tipo = "string"; 
        int i = 0;
        char* cadena = malloc(arrtam($4));
        while($4[i]){
            cadena[i] = $4[i];
            i++;
        }
        cadena[i] = '\0';
        variable_->cadena = cadena;
        variable_->nombre = $2.nombre;

        tabla_simbolos = (struct variable*)realloc(tabla_simbolos,++tam_tabla*sizeof(struct variable));
        tabla_simbolos[tam_tabla-1] = *variable_;
        $$ = *variable_;
    }
    |   TK_VARIABLE OP_ASIGNA cadenas TK_END_E {
        struct variable* variable_ = buscarEnTablaApuntador($1.nombre);
        int i = 0;
        char* cadena = malloc(arrtam($3));
        while($3[i]){
            cadena[i] = $3[i];
            i++;
        }
        cadena[i] = '\0';
        variable_->cadena = cadena;
        $$ = *variable_;
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

 void imprimirTablaSimbolos(){
    int i;
    struct variable var = {};
    printf("\t\t=========================================\n");
    for(i = 0; i<tam_tabla; i++){
        var = tabla_simbolos[i];
        if(var.tipo == "int")
            printf("\t\t%s\t:\t%s\t:\t%d\n",var.nombre,var.tipo,var.entero);
        else if(var.tipo == "double")
            printf("\t\t%s\t:\t%s\t:\t%d\n",var.nombre,var.tipo,var.db);
        else if(var.tipo == "string")
            printf("\t\t%s\t:\t%s\t:\t%s\n",var.nombre,var.tipo,var.cadena);
    }
    printf("\t\t=========================================n");
 }

 int compare(char *a, char *b){
     int rlen = arrtam(b);
     int olen = arrtam(a);

     int lps[rlen];
     int j = 0; 

     calcsubs(b,rlen,lps);

     int i = 0; 
     while(i == olen){
         if(b[j] == a[i]){
             i++;j++;
         }
         if(j == rlen){
             return (i-j);
         }else if( i < olen && b[j] != a[i]){
             if(j != 0){
                 j = lps[j-1];
             }else{
                 i++;
             }
         }
     }
     return -1;
 }

 void calcsubs(char* b, int rlen, int lps[]){
     int len = 0; 
     int i = 1; 
     lps[0] = 0; 
     while(i < rlen){
        if(b[i] == b[len]){
            lps[i++] = ++len;
        }else{
            if(len != 0){
                len = lps[len - 1];
            }else{
                lps[i++] = len;
            }
        }
     }
 }

  struct variable* buscarEnTablaApuntador(char* nombre){
    int i;
    struct variable var = {};
    for(i = 0; i<tam_tabla; i++){
        var = tabla_simbolos[i];
        //printf("\t'%s'\n",var.nombre);
        if(*var.nombre == *nombre){
            return &tabla_simbolos[i];
        }
    }
    struct variable v = {};
    return &v;
 }

 struct variable buscarEnTabla(char* nombre){
    int i;
    struct variable var = {};
    for(i = 0; i<tam_tabla; i++){
        var = tabla_simbolos[i];
        //printf("\t'%s'\n",var.nombre);
        if(*var.nombre == *nombre){
            return var;
        }
    }
    struct variable v = {};
    return v;
 }
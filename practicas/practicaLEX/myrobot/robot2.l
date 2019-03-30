/*********************************************************
**
** Fichero: robot.l
** Autor: Víctor García Carrera, victorgarcia@correo.ugr.es
** Función: A partir de una o varias urls de partida almacenadas en el fichero webs.txt
**			indexa nuevas urls y documentos encontrados al analizarlas en el final de este fichero.
**			Además, realiza una búsqueda en ellas de las palabras claves descritas en este fichero
**
*********************************************************/

/*----- Sección de Declaraciones --------------*/
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WEBS "webs.txt"
#define ANALYZED "analyzedWebs.txt"
#define MAX_URLS 10

unsigned long newlinks = 0, nwords = 0, nlines = 0;		/** variables utilizadas para contar el numero de palabras y lineas analizadas, respectivamente **/
void addLink (char newlink[]);							/** funcion que añade una nueva url a la lista de urls a analizar **/
int searchAnalyzed (char *link);						/** funcion que comprueba si el enlace ya fue analizado **/
%}

/** La siguiente declaración indica que no se va a escribir la función ’yywrap’
*** evita que se tenga que enlazar con -lfl, o que se tenga que escribir ’yywrap’
**/

%option noyywrap

/** expresiones regulares **/

link        "href="[^ #>]*
words       [^ \t\n]+
eol         \n

%%
	/*----- Sección de Reglas ----------------*/
{link}										{	/** cuando encuentra un href **/ newlinks++; addLink(yytext); }
{words}										{	/** lleva la cuenta de las palabras **/ nwords++;}
{eol}										{	/** lleva la cuenta de las líneas **/ nlines++; }
.											{}

%%
/*----- Sección de Procedimientos --------*/

int main ( int argc, char **argv){

    for (int i=0; i<3; i++){

        yyin = fopen ("PRUEBA", "rt");						// lo seleccionamos como la entrada estandar para el lex
	    if (yyin == NULL) {
		printf ("El fichero de analisis no se puede abrir\n");
		exit(-1);
	    }

	yylex();
    }
    printf("%ld %ld", newlinks, nwords);

	return 1;

}

/* recibe un href="...", obtiene la url, comprueba en el fichero analyzedWebs.txt que no se ha analizado previamente
	y añade esta nueva url al final de newWebs.txt para su futuro analisis. Devuelve 1 en caso correcto, 0 en caso de que ya fuera una url analizada, -1 en caso de error */
void addLink (char *newlink){
	FILE * fp;
	int ret;
    int i = 6;
	char addlink[1024];		// como maximo links de 1024 caracteres

    printf("LINK: %s\n", newlink);

    char *copy = newlink + 6;
	
    memset(addlink, '\0', sizeof(addlink));
	strncpy(addlink, copy, strlen(copy)-1);		// -1??
	//addlink[sizeof(addlink)]= "\0";

	ret = searchAnalyzed (addlink);
	if (ret == -1) return;		// si ha habido un error
	else if (ret == 1){				// si ya habia sido analizada la url
		printf ("URL YA ANALIZADA: %s\n", addlink);
		return;
	}
 	else{							// Si la url no ha sido aun analizada, la añadimos a la lista de urls
 		fp = fopen (WEBS, "at");

		if (fp == NULL) {
			fputs ("File error WEBS",stderr); 
			return;
		}

		printf("Añadiendo nuevo link: %s\n", addlink);
		fprintf(fp, "%s\n", addlink );
		fclose(fp);

		return;
 	}

}

/* comprueba si una url esta en la lista de urls ya analizadas, devuelve 1 si esta presente, 0 si no y -1 en caso de error */
int searchAnalyzed (char *link){
	FILE * fp;
	char *linea;

	memset(linea, '\0', sizeof(linea));
	// Vamos a comprobar si la url ya fue analizada
	fp = fopen (WEBS, "rt");

	if (fp == NULL) {
		fputs ("File error",stderr); 
		return -1;
	}

    // !!!!!!!!!!!!!! PROBLEMA AL COMPARAR !!!!!!!!!!!!!

	while(fgets(linea, 1024, (FILE*) fp)) {
		if ( strcmp (linea, link) == 0){		// si encuentra que ya existe el link, es decir, ya fue analizado, devuelve 1
			fclose(fp);
			return 1;
		}

		printf("STRMCP = %d\n", strcmp (linea, link));

	}
	fclose(fp);

	return 0;
}

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
#define HTML "ANALISIS"
#define ANALYZED "analyzedWebs.txt"
#define MAX_URLS 10

unsigned long newlinks = 0, nwords = 0, nlines = 0, nsame = 0;		/** variables utilizadas para contar el numero de enlaces, palabras, lineas y palabras clave 																		encontradas **/
void addLink (char newlink[]);							/** funcion que añade una nueva url a la lista de urls a analizar **/
void encontrado (char *finded);							/** funcion que muestra la coincidencia encontrada **/
%}

/** La siguiente declaración indica que no se va a escribir la función ’yywrap’
*** evita que se tenga que enlazar con -lfl, o que se tenga que escribir ’yywrap’
**/

%option noyywrap

/** expresiones regulares, incluimos las palabras que deseamos buscar **/

link        "href="[^ #><]*
words       [^ \t\n]+
eol         \n
busqueda	"atomo"
busqueda2	"universo"
busqueda3	"luz"

%%
	/*----- Sección de Reglas ----------------*/
{busqueda}									{	/** cuando encuentra una de las palabras clave **/ encontrado(yytext); nsame++;}
{busqueda2}									{	/** cuando encuentra una de las palabras clave **/ encontrado(yytext); nsame++;}
{busqueda3}									{	/** cuando encuentra una de las palabras clave **/ encontrado(yytext); nsame++;}
{link}										{	/** cuando encuentra un href **/ newlinks++; addLink(yytext); }
{words}										{	/** lleva la cuenta de las palabras **/ nwords++;}
{eol}										{	/** lleva la cuenta de las líneas **/ nlines++; }
.											{}

%%
/*----- Sección de Procedimientos --------*/

int main ( int argc, char **argv){
	FILE * fp1;
	FILE * fp2;
	/*int analyzed = 0;
	int ret;
	char linea[1024];
	char command[150];

	fp1 = fopen(WEBS, "rt");

	if (fp1 == NULL) {
		printf ("File error with WEBS\n"); 
		exit(-1);
	}**/


	//while (analyzed < MAX_URLS && fgets(linea, 1024, (FILE*) fp1)){		/* mientras no superemos el num max de urls a analizar o no lleguemos al final */
        //printf("Analisis num %d\n", analyzed);		

		//sprintf(command, "wget -O ANALISIS %s", linea);		// descargamos el fichero html de la url a analizar
		//system(command);

		yyin = fopen (HTML, "rt");						// lo seleccionamos como la entrada estandar para el lex
		if (yyin == NULL) {
			//printf ("El fichero de analisis %s no se puede abrir\n", linea);
			printf("ERROR AL ABRIR FICHERO DE ANALISIS\n");
			exit(-1);
		}

		yylex();

		// Una vez analizada esa url, borramos su fichero html, escribimos la url en la lista de analizadas y actualizamos el contador analyzed

		/**sprintf(command, "rm ANALISIS");		// borramos el fichero html de la url analizada
		system(command);
		analyzed++;								// actualizamos el contador de urls analizadas

		fp2 = fopen (ANALYZED, "at");						// escribimos la url en la lista de analizadas
		if (fp2 == NULL) {
			printf ("El fichero de analizados no se puede abrir\n");
			exit(-1);
		}

		fprintf(fp2, "%s", linea );	// escribimos la url analizada en el fichero de urls analizadas
		fclose(fp2);**/
 
	//}

	//fclose(fp1);

	return 1;

}

/* recibe un href="...", obtiene la url, comprueba en el fichero analyzedWebs.txt que no se ha analizado previamente
	y añade esta nueva url al final de newWebs.txt para su futuro analisis. Devuelve 1 en caso correcto, 0 en caso de que ya fuera una url analizada, -1 en caso de error */
void addLink (char newlink[]){
	FILE * fp;
	int ret;
    int i = 6;
	char addlink[1024];		// como maximo links de 1024 caracteres

    //printf("LINK: %s\n", newlink);

    char *copy = newlink + 6;
	
    memset(addlink, '\0', sizeof(addlink));
	strncpy(addlink, copy, strlen(copy)-1);		// -1??
	//addlink[sizeof(addlink)]= "\0";

	// Añadimos la url a la lista de urls
 	fp = fopen (WEBS, "at");

	if (fp == NULL) {
		fputs ("File error WEBS",stderr); 
		return;
	}

	//printf("Añadiendo nuevo link: %s\n", addlink);
	fprintf(fp, "%s\n", addlink );
	fclose(fp);

	return;

}

void encontrado (char *finded){
	printf ("¡ENCONTRADO: %s! Linea %ld\nNúmero de coincidencias con palabras clave: %ld\n", finded, nlines, nsame);
}

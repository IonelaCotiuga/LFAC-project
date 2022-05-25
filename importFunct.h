#include <stdio.h>
#include<string.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno; 

union valueF{
    int intVal;
    float floatVal;
    char strVal[101]; //const char
    char* charVal; // character
};

struct function{
     char name[50];
     char type[50];
     union valueF valoare;
     int v_int;
     int v_float;
     int v_str;
     int v_char;
     char params[100];

}funct[100];

int noFunct=0;

void paramsTypeVerify(char* name, char* typeDecl){ 
     int i=0;
     char typeDef[100];
     for( i = 0; i < noFunct; i++){ // caut functia ca sa ii iau parametrii definiti
          if(strcmp(funct[i].name, name)==0){
               strcpy(typeDef, funct[i].params);
               break;
          }          
     }

     printf("toti parametrii declarati: %s\n", typeDecl);
     printf("toti parametrii definiti: %s\n", typeDef);

     if(typeDecl == NULL)
         printf("parametrii nu sunt la fel\n");
     else{
          if(strcmp(typeDef, typeDecl) == 0) // string null
               printf("parametrii sunt la fel\n");
          else printf("parametrii nu sunt la fel\n");
     }     

     

}

int insertFunct(char* name, char* type, char* params){ // insereaza variabila in tabel
    int i=0;
    for(i = 0; i < noFunct; i++){
        if(strcmp(funct[i].name, name)==0)
            return -1; //  o variabila a fost deja declarata
    }
     
     strcpy(funct[noFunct].name, name);
     strcpy(funct[noFunct].type, type);
     strcpy(funct[noFunct].params, params);

     noFunct++;
     return 0; // variabila nu a fost declarata anterior si s-a scris acum in tabel

}

int existsFunct(char *s){
    int i = 0;
    for(i = 0; i < noFunct; i++){
        if(strcmp(s, funct[i].name) == 0){
             return i; // pozitia la care o gasesc
        }
            
    }
    return -1;
}


void tabelFunct(){
     printf("\nTabel functii:\n");
     int i=0;
     for(i = 0; i < noFunct; i++){
         printf("name: %s, ", funct[i].name);
         printf("type: %s, ", funct[i].type);
         printf("params: %s ", funct[i].params);
         printf("\n");
    }
    
}

void fisier_functions()
{
     FILE *fptr;
     fptr = fopen("symbol_table_functions.txt", "w");

     if(fptr == NULL)
     {
          printf("Error!");   
          exit(1);             
     }

     int i = 0;

     for(i = 0; i < noFunct; i++){

          fprintf(fptr, "name: %s , ", funct[i].name);
          fprintf(fptr, "type: %s , ", funct[i].type);
          fprintf(fptr, "params: %s ", funct[i].params);
          fprintf(fptr, "\n");

    }
     fclose(fptr);

}


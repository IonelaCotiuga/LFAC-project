%{
#include <stdio.h>
#include<string.h>
#include <stdlib.h>
#include "import.h"
#include "importFunct.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno; 

char params[100];
char arr_values[100];
char typeDecl[100];
int return_value;
char scope[100] = "global";
%}


%union {
int intval;
char* strval;
float floatval; 
struct node* node;
}

%token <strval>TIP
%token <strval>ID
%token <strval>STRING
%token <strval>CHARACTER
%token <strval>VERIFY
%token <strval>BOOL_OP
%token <strval>PLUS
%token <strval>MINUS
%token <strval>MUL
%token <strval>DIV
%token <strval>IF
%token <strval>ELSE
%type <strval>declaratie
%type <strval>statement
%type <strval>list
%type <intval>condition
%type <strval>if
%type <node>exp
%type <node>value

%token <intval>NR
%token <floatval>FLOAT_NR
%left '<' '>' '=' "!=" "<=" ">="
%left PLUS MINUS
%left DIV MUL
%left BOOL_OP

%token BGIN END BGIN_GLOBAL END_GLOBAL BGIN_DEF END_DEF ASSIGN WHILE FOR PRINT //BG EN  //PRINT
%start progr
%%

progr: global definitions bloc{
     tabel();
     tabelFunct();
     }
;

global: BGIN_GLOBAL declaratii END_GLOBAL{
          strcpy(scope, "local"); // se asigneaza pentru urmatorul bloc
}
;

declaratii : declaratie ';' 
	      | declaratii declaratie ';'
;

definitions: BGIN_DEF funct  END_DEF{
     strcpy(scope, "main");

}
;

bloc : BGIN other END{
     }
;


declaratie : TIP ID{ 
               if( insertVar($2, $1, scope) == 0){ // variabila nu a fost deja declarata 
                    printf("variabila %s s-a declarat\n", $2); 
               }
               else printf("[error, linia %d]variabila exista\n", yylineno);
              }
              
          | TIP ID ASSIGN ID {
               if( insertVar($2, $1, scope) == 0){  //daca exista prima variabila. daca nu, o inseram in tabel
                    printf("variabila %s s-a declarat\n", $2); 
                    if(existsVar($4, scope)!=-1 && typeVerify($2, $4) == 1) // daca exista si variabila 2 si au acelasi tip
                    { 
                         insertValVar($2,$4); // a = b
                         printf("am inserat in variabila %s valoarea variabilei %s\n", $2, $4);
                    }
                    else printf("[error, linia %d]nu se poate face asignarea\n", yylineno);
               } 
               else printf("[error, linia %d]variabila exista\n", yylineno);
   
          }
         | TIP ID ASSIGN NR{ 
               if( insertVar($2, $1, scope) == 0){ 
                    printf("variabila %s s-a declarat\n", $2); 
                    if(strcmp($1, "int")==0){
                         insertValInt($2, $4);
                    }
                    else printf("[error,linia %d]nu au acelasi tip: int. Nu se poate face asignarea.\n", yylineno);  
               } 
               else printf("[error, linia %d]variabila exista\n", yylineno);

         }  
         | TIP ID ASSIGN FLOAT_NR{ 
               if( insertVar($2, $1, scope) == 0){ 
                    printf("variabila %s s-a declarat\n", $2); 
                    if(strcmp($1, "float")==0){
                         insertValFloat($2, $4);
                    }
                    else printf("[error,linia %d]nu au acelasi tip: float. Nu se poate face asignarea.\n", yylineno);  
               } 
               else printf("[error, linia %d]variabila exista\n", yylineno);
         }
         | TIP ID ASSIGN CHARACTER {
              if( insertVar($2, $1, scope) == 0){ 
                    printf("variabila %s s-a declarat\n", $2); 
                    if(strcmp($1, "char")==0){
                         insertValChar($2, $4);
                    }
                    else printf("[error,linia %d]nu au acelasi tip: int. Nu se poate face asignarea.\n", yylineno);  
               } 
               else printf("[error, linia %d]variabila exista\n", yylineno);
         }
         | TIP ID ASSIGN STRING{
              if( insertVar($2, $1, scope) == 0){ 
                    printf("variabila %s s-a declarat\n", $2); 
                    if(strcmp($1, "string")==0){
                         insertValString($2, $4);
                    }
                    else printf("[error,linia %d]nu au acelasi tip: int. Nu se poate face asignarea.\n", yylineno);  
               } 
               else printf("[error, linia %d]variabila exista\n", yylineno);
         }

         | TIP ID ASSIGN '(' exp ')'{
               if( insertVar($2, $1, scope) == 0){ 
                    printf("variabila %s s-a declarat\n", $2); 
                    if(strcmp($1, "int")==0){
                         int value = evalAST((struct node*)$5);
                         insertValInt($2, value);
                    }
                    else printf("[error, linia %d]nu au acelasi tip: char. Nu se poate face asignarea.\n", yylineno);  
               } 
               else printf("[error, linia %d]variabila exista\n", yylineno);

         } 
          | TIP ID '[' NR ']' ASSIGN '{' list_val '}' { // int arr[3] = {8,2,3} 
               char nr_to_str[33] , name_arr[33];
               sprintf(nr_to_str, "%d", $4);

               strcpy(name_arr, "");
               strcat(name_arr, $2);
               strcat(name_arr, "[");
               strcat(name_arr, nr_to_str);
               strcat(name_arr, "]");

               if(existArr($2) == 0) // daca nu exista array cu numele dat
               {
                    if( insertVar(name_arr, $1, scope) == 0){ 
                         printf("vectorul %s s-a declarat\n", name_arr); 
                         strcat(arr_values, "}");

                         insertValString(name_arr, arr_values); 
                    } 
               }
               else printf("[error, linia %d]vectorul exista\n", yylineno);

               strcpy(arr_values, " ");
               arr_values[0] = '\0';
          }

           ;

list_val: val
          | list_val ',' val
          ;

val:  NR  { 
          char buffer[33];
          sprintf(buffer, "%d", $1);
          if(arr_values[0] != '{')
               strcat(arr_values, "{");
          strcat(arr_values, buffer); 
          strcat(arr_values, " "); 
     }
     ;

funct: funct_decl '{' other '}'
     | funct funct_decl '{' other '}'
     ;

funct_decl: TIP ID '(' lista_param ')'{
               if( insertFunct($2, $1, params) == 0){
                    printf("functia %s s-a declarat \n", $2);
               }
               else printf("[error, linia %d]functia exista\n", yylineno);
               strcpy(params, " ");
              }

           | TIP ID '(' ')'{
                if( insertFunct($2, $1, " ") == 0){
                    printf("functia %s s-a declarat\n", $2);
               }
               else printf("[error, linia %d]functia exista\n", yylineno);
               strcpy(params, " ");
              }
         ;

other:  declaratii 
     | list 
     | other declaratii
     | other list
     ;

lista_param : param
            | lista_param ','  param 
            ;
            
param : TIP ID {
          strcat(params, $1); strcat(params, " "); 
          }  
      ; 

     
list :  statement ';' 
     | list statement ';'
     | list if
     | list while
     | list for
     | list print ';'
     ;

/* instructiune */
statement: ID ASSIGN ID {
               if(existsVar($1, scope)!=-1 && existsVar($3, scope)!=-1 ){
                    printf("variabilele %s si %s exista. se poate face asignarea\n", $1, $3);
                    if(typeVerify($1, $3) == 1){ 
                         insertValVar($1,$3); 
                    }
                    else printf("[error, linia %d]variabilele nu au acelasi tip. nu se poate face asignarea.\n", yylineno);
               }
               else
                    printf("[error, linia %d]variabilele nu exista \n", yylineno);
          }
         | ID ASSIGN NR{ // a= 10
              if(existsVar($1,scope)!=-1){  
                   
                    printf("variabila %s exista.se poate face asignarea\n", $1);
                    if(strcmp(returnType($1), "int")==0){
                         insertValInt($1, $3);
                    }
                    else printf("[error,linia %d]nu au acelasi tip: int. Nu se poate face asignarea.\n", yylineno);   
              }                 
               else printf("[error,linia %d]variabila nu exista \n", yylineno);
         }  
         | ID ASSIGN FLOAT_NR{  
               if(existsVar($1,scope)!=-1){  
                    printf("variabila %s exista.se poate face asignarea\n", $1);
                    if(strcmp(returnType($1), "float")==0){
                         insertValFloat($1, $3);
                    }
                    else printf("[error, linia %d]nu au acelasi tip: float. Nu se poate face asignarea.\n", yylineno);   
              }                 
               else printf("[error, linia %d]variabila nu exista \n", yylineno);
         }
         | ID ASSIGN CHARACTER {
               if(existsVar($1, scope)!=-1){  
                    printf("variabila %s exista.se poate face asignarea\n", $1);
                    if(strcmp(returnType($1), "char")==0){
                         insertValChar($1, $3);
                    }
                    else printf("[error, linia %d]nu au acelasi tip: char. Nu se poate face asignarea.\n", yylineno);   
              }                 
               else printf("[error, linia %d]variabila nu exista \n", yylineno);
         }
         | ID ASSIGN STRING{
              if(existsVar($1, scope)!=-1){  
                    printf("variabila %s exista.se poate face asignarea\n", $1);
                    if(strcmp(returnType($1), "string")==0){
                         insertValString($1, $3);
                    }
                    else printf("[error, linia %d]nu au acelasi tip: char. Nu se poate face asignarea.\n", yylineno);   
              }                 
               else printf("[error, linia %d]variabila nu exista\n", yylineno);
         }

         | ID '(' lista_apel ')'{
              if(existsFunct($1)!=-1){
                    printf("functia %s exista.se poate apela\n", $1);
                    paramsTypeVerify($1,typeDecl);
              }
              else printf("[error,linia %d]functia nu exista\n", yylineno);
              strcpy(typeDecl, " ");
         }
         | ID '(' ')'{
              if(existsFunct($1)!=-1){
                    printf("functia %s exista. se poate apela\n", $1);
                    paramsTypeVerify($1,typeDecl);
              }
              else printf("[error,linia %d]functia nu exista\n", yylineno);
              strcpy(typeDecl, " ");
         }
         | ID ASSIGN '(' exp ')'{
              if(existsVar($1, scope)!=-1){  
                    printf("variabila %s exista.se poate face asignarea\n", $1);
                    if(strcmp(returnType($1), "int")==0){
                         int value = evalAST((struct node*)$4);
                         insertValInt($1, value);
                    }
                    else printf("[error, linia %d]nu au acelasi tip: char. Nu se poate face asignarea.\n", yylineno);   
              }                 
               else printf("[error, linia %d]variabila nu exista\n", yylineno);
         }
         | ID '[' NR ']' ASSIGN NR { // arr[0] = 8 
               insertArrValue($1, $3, scope, $6);

           }

         ;

print:  PRINT '(' STRING ',' exp ')'{
          int value = evalAST((struct node*)$5);
          printf("%s %d\n", $3, value);
     }
     ;

value: NR {
          struct node* node = (struct node*)malloc(sizeof(struct node));
          node->value.number = $1;
          $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "int");
     }
     | ID {
          struct node* node = (struct node*)malloc(sizeof(struct node));
          strcpy(node->value.identifier, $1);
          $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "id");
     }

     | altceva {
          struct node* node = (struct node*)malloc(sizeof(struct node));
          node->value.number = 0;
          $$ = (struct node*)buildAST((struct node*)node, NULL, NULL, "altceva");
     }
     ;

altceva: FLOAT_NR
          | CHARACTER
          | STRING
          | ID '(' lista_apel ')'
          | ID '('  ')'
          ;

exp:  exp PLUS exp{
          struct node* node = (struct node*)malloc(sizeof(struct node));
          strcpy(node->value.operator, $2);
          $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
     }
     |exp MUL exp{
          struct node* node = (struct node*)malloc(sizeof(struct node));
          strcpy(node->value.operator, $2);
          $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
     }
     | exp DIV exp{
          struct node* node = (struct node*)malloc(sizeof(struct node));
          strcpy(node->value.operator, $2);
          $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
     }
     | exp MINUS exp{
          struct node* node = (struct node*)malloc(sizeof(struct node));
          strcpy(node->value.operator, $2);
          $$ = (struct node*)buildAST((struct node*)node, (struct node*)$1, (struct node*)$3, "op");
     }
     | '(' exp ')' {$$ = $2;}
     | value
     ;


lista_apel : funct_param 
           | lista_apel ',' funct_param        

funct_param : NR {strcat(typeDecl, "int"); strcat(typeDecl, " "); }
           | STRING {strcat(typeDecl, "string"); strcat(typeDecl, " "); }
           | CHARACTER {strcat(typeDecl, "char"); strcat(typeDecl, " "); }
           | FLOAT_NR {strcat(typeDecl, "float"); strcat(typeDecl, " "); }
           | ID {
                if(existsVar($1, scope)!=-1){  
                    strcat(typeDecl, returnType($1)); strcat(typeDecl, " "); 
              }                 
               else printf("[error, linia %d]variabila nu exista \n", yylineno);
           }
           ;


if : IF '(' condition ')' instr {
          switch(return_value) {
               case 1 :
                    printf("conditia este adevarata\n");
                    break;
               case 0:
                    printf("conditia este falsa\n");
                    break;
               default: printf("eroare la verificarea conditiei\n");
               break;
               
          }
     }
   | IF '(' condition ')' instr ELSE instr{
        switch(return_value) {
               case 1 :
                    printf("conditia este adevarata\n");
                    break;
               case 0:
                    printf("conditia este falsa\n");
                    break;
               default: printf("eroare la verificarea conditiei\n");
               break;

          }
   }
   | IF '(' condition ')' instr ELSE if{
        int loc = return_value;
        switch(loc) {
               case 1 :
                    printf("conditia este adevarata\n");
                    break;
               case 0:
                    printf("conditia este falsa\n");
                    break;
               default: printf("eroare la verificarea conditiei\n");
               break;

          }
   }

   ;

instr: '{' '}'
     | '{'list'}'
     ;

while : WHILE '(' condition ')' instr{
     switch(return_value) {
          case 1 :
               printf("conditia este adevarata\n");
               break;
          case 0:
               printf("conditia este falsa\n");
               break;
          default: printf("eroare la verificarea conditiei\n");
          break;
          
     }
}
      ;

for : FOR '(' statement ';' condition ';' statement ')' instr // for(i=0; i<nr; i=i+1)
    ;


// operators

condition : condition BOOL_OP condition{
               return_condition_op_bool($1, $3, $2);
          }

          | ID VERIFY ID{  // if(@a==@b)
               if(existsVar($1, scope)!=-1 && existsVar($3, scope)!=-1 ){
                    printf("variabilele %s si %s exista. se poate face verificarea de tip\n", $1, $3);
                    if(typeVerify($1, $3) == 1){ // verific tipul ambelor variabile
                         printf("variabilele %s si %s au acelasi tip. se poate face verificarea conditiei\n", $1, $3);
                         if(strcmp(returnType($1), "int") == 0){  
                              return_value = return_condition_value_int(returnVal($1) , returnVal($3), $2);
                             $$ = return_value;

                         }
                         if(strcmp(returnType($1), "float") == 0){  
                              return_value = return_condition_value_float(returnVal($1) , returnVal($3), $2);
                              $$ = return_value;
                         }
                         
                    }
                    else printf("[error, linia %d]variabilele nu au acelasi tip. nu se poate verifica conditia.\n", yylineno);
               }
               else
                    printf("[error, linia %d]variabilele nu exista \n", yylineno);

          }
          | NR VERIFY NR {
               return_value = return_condition_value_int($1 , $3, $2);
               $$ = return_value;

          }
          | ID VERIFY NR { 
                if(existsVar($1, scope)!=-1 ){
                    printf("variabila %s exista. se poate face verificarea de tip\n", $1);
                         if(strcmp(returnType($1), "int") == 0){  
                              return_value = return_condition_value_int(returnVal($1) ,$3, $2);
                              $$ = return_value;
                         }
                         else printf("[error, linia %d]variabila %s nu are tipul int. nu se poate verifica conditia.\n", yylineno, $1);
               }
               else
                    printf("[error, linia %d]variabila nu exista \n", yylineno);
          
          }
          | NR VERIFY ID  {
                if(existsVar($3, scope)!=-1 ){
                    printf("variabila %s exista. se poate face verificarea de tip\n", $3);
                         if(strcmp(returnType($3), "int") == 0){  
                              return_value = return_condition_value_int($1, returnVal($3), $2);
                              $$ = return_value;
                         }
                         else printf("[error, linia %d]variabila %s nu are tipul int. nu se poate verifica conditia.\n", yylineno, $3);
               }
               else
                    printf("[error, linia %d]variabila nu exista \n", yylineno);
          
          
          }
          ;
                
%%
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();

fisier_variables();
fisier_functions();

} 

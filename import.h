#include <stdio.h>
#include<string.h>
#include <stdlib.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno; 


union value{
    int intVal;
    float floatVal;
    char strVal[101]; 
    char* charVal; 
};

struct variable{
     char name[50];
     char type[50];
     union value valoare;
     char scope[50];
     int v_int;
     int v_float;
     int v_str;
     int v_char;


}vars[100];


int noVars=0;

int existsVar(char *s, char* scope){
    int i = 0;
    for(i = 0; i < noVars; i++){
        if(strcmp(s, vars[i].name) == 0 ){
             if(strcmp(scope, "main") == 0 && strcmp("global", vars[i].scope) == 0){ // daca o variabila este folosita in maine dar a fost declarata global
                   return i; 
             }
             else if(strcmp(scope, vars[i].scope) == 0)
                    return i; // cazul global, local, main
        }
            
    }
    return -1;
}


int returnVal(char* name){
     int i = 0;
     for(i = 0; i < noVars; i++){
        if(strcmp(name, vars[i].name) == 0){

               if(vars[i].v_int == 1)
                    return vars[i].valoare.intVal;

               if (vars[i].v_float == 1)
                    return vars[i].valoare.floatVal;
        }
            
    }
}

char* returnType(char* name){
     int i = 0;
     for(i = 0; i < noVars; i++){
        if(strcmp(name, vars[i].name) == 0){
             return vars[i].type;
        }
            
    }
}

union root_value{
     int number;
     char identifier[10];
     char operator[10];
};


struct node{
     union root_value value; 
     struct node* left;
     struct node* right;
     char* type;

};

struct node* buildAST(struct node* root, struct node* left_tree, struct node* right_tree, char* type)
{
     root->type = type;
     root->left = left_tree;
     root->right = right_tree;   
     return (root);

};

int evalAST(struct node* ast){ // a = 1 +2*3

     if(strcmp(ast->type, "op") == 0){

          int left_tree, right_tree;
          if(ast->left != NULL) left_tree = evalAST(ast->left);
          if(ast->right != NULL) right_tree = evalAST(ast->right);

          if(strcmp(ast->value.operator, "+") == 0){
               return left_tree + right_tree; 
          }
          else if(strcmp(ast->value.operator, "-") == 0){
               return left_tree - right_tree; 
          }
          else if(strcmp(ast->value.operator, "/") == 0){
               return left_tree / right_tree; 
          }
          else if(strcmp(ast->value.operator, "*") == 0){
               return left_tree * right_tree; 
          }
          
     }
     else if(strcmp(ast->type, "int") == 0){
          return(ast->value.number);
     }
     else if(strcmp(ast->type, "id") == 0){ // caut in tabel sa vad daca exista si este de tip int
          if(existsVar(ast->value.identifier, "main") != -1){ // de corectat!!!
               if(strcmp(returnType(ast->value.identifier), "int")==0){
                    return returnVal(ast->value.identifier);
               }
               else return 0;
          }
          else {
               printf("[error, linia %d]variabila nu exista\n", yylineno);
               return 0;
          }
     }
     else if(strcmp(ast->type, "altceva") == 0){
          return 0;
     }
     
}


int typeVerify(char* name1, char* name2){ 
     int i = 0;
     char type1[50];
     char type2[50];
     for(i = 0; i < noVars; i++){
          if(strcmp(name1, vars[i].name) == 0) // se retine tipul fiecarui id
               strcpy(type1,vars[i].type );
          else if (strcmp(name2, vars[i].name) == 0) 
               strcpy(type2,vars[i].type );
     }
     if(strcmp(type1, type2) == 0) //  se verifica daca tipul id-urilor este acelasi
          return 1;
     
     return -1;
}


int insertVar(char* name, char* type, char* scope){ // insereaza variabila in tabel
    int i=0;
    for(i = 0; i < noVars; i++){
        if(strcmp(vars[i].name, name)==0 && strcmp(vars[i].scope, scope)==0)
            return -1; //  o variabila a fost deja declarata globala sau locala
    }
     
     strcpy(vars[noVars].name, name);
     strcpy(vars[noVars].type, type);
     strcpy(vars[noVars].scope, scope);

     noVars++;
     return 0; // variabila nu a fost declarata anterior si s-a scris acum in tabel

}

void insertValInt(char* name, int val){ //  cazul ID ASSIGN NR
     int i=0;
     for(i = 0; i < noVars; i++){
        if(strcmp(vars[i].name, name)==0){
           vars[i].valoare.intVal = val;
           printf("am inserat in variabila %s, valoarea %d.\n", name, val);
           break; 
        }   
    }
    vars[i].v_int = 1;
     
}

void insertValFloat(char* name, float val){ //  cazul ID ASSIGN FLOAT
     int i=0;
     for(i = 0; i < noVars; i++){
        if(strcmp(vars[i].name, name)==0){
           vars[i].valoare.floatVal = val;
           printf("am inserat in variabila %s, valoarea %f.\n ", name, val);
           break; 
        }      
    }
     vars[i].v_float = 1;
}

void insertValChar(char* name, char* val){ //  cazul ID ASSIGN CHAR
     int i=0;
     for(i = 0; i < noVars; i++){
        if(strcmp(vars[i].name, name)==0){
           vars[i].valoare.charVal = val;
           printf("am inserat in variabila %s, valoarea %s.\n ", name, val);
           break; 
        }      
    }
     vars[i].v_char = 1;
}

void insertValString(char* name, char* val){ //  cazul ID ASSIGN STRING
     int i=0;
     for(i = 0; i < noVars; i++){
        if(strcmp(vars[i].name, name)==0){
          strcpy(vars[i].valoare.strVal, val);
           printf("am inserat in variabila %s, valoarea %s.\n ", name, val);
           break;
        }      
    }
     vars[i].v_str = 1;
}


int existArr(char* name){
     int len = strlen(name);
     char nume_tabel[10];
     char temp[10];
     int i = 0;
     for(i = 0; i < noVars; i++){
          if(strstr(vars[i].name, name)){ // strstr(arr[3], arr)
               strcpy(temp, vars[i].name + len); // temp = [3]
               if(temp[0] == '[')
                    return 1; // daca exista
          }
     }
     return 0; // daca nu exista
}


void insertArrValue(char* name, int pozitie, char* scope, int nr_de_asignat){ 
      int len = strlen(name);
      char temp[10];

     int i = 0;
     for(i = 0; i < noVars; i++)
     { 
          if(strstr(vars[i].name, name))
          {
               strcpy(temp, vars[i].name + len); // temp = [10]

               if(temp[0] == '[')
               {
                     if( ( strcmp(scope, "main") == 0 && strcmp("global", vars[i].scope) == 0 ) || strcmp(scope, vars[i].scope) == 0 )
                    {
                         char dim_str[20];
                         strcpy(dim_str, temp+1); // 10]
                         len = strlen(dim_str);
                         dim_str[len-1] = '\0';
                         int dim_arr = atoi(dim_str); // am luat dimensiunea arr din tabel, conversie to int

                         if(pozitie < dim_arr){
                              // transform nr_de_asignat in char
                              char nr_to_str[30];
                              sprintf(nr_to_str, "%d", nr_de_asignat);

                              int poz_in_arr = 0;
                              char strVal_nou[100];
                              strcpy(strVal_nou, "");
                              strcat(strVal_nou, "{");
                              char *ptr;
                              ptr = strtok(vars[i].valoare.strVal, "{ }");

                              while(ptr != NULL){
                                   if(pozitie == poz_in_arr){
                                        strcat(strVal_nou, nr_to_str);
                                        strcat(strVal_nou, " ");
                                   }
                                   else {
                                        strcat(strVal_nou, ptr);
                                        strcat(strVal_nou, " ");
                                   }
                                   ptr = strtok(NULL, "{ }");
                                   poz_in_arr ++;
                              }
                              strcat(strVal_nou, "}");
                              strcpy(vars[i].valoare.strVal, strVal_nou);
                              printf("valoarea noua de inserat: %s\n", strVal_nou);

                         } else printf("[eroare]pozitia de inserat este mai mare decat dimensiunea array-ului\n");

                    } else printf("[eroare]variabila nu exista\n");

               } else printf("[eroare] vectorul nu exista.\n");

          } 
          
    }
 
     
}

void insertValVar(char* name1, char* name2){ //  cazul ID ASSIGN ID. caut numele amandurora apoi asignez valoarea lui ID2 lui ID1 a=b
     int i=0;
     int poz1, poz2;
     for(i = 0; i < noVars; i++){
        if(strcmp(vars[i].name, name1)==0)
          poz1=i;
        else if(strcmp(vars[i].name, name2)==0)
          poz2=i;       
    }

     if(strcmp(returnType(name1), "int")==0){
          vars[poz1].valoare.intVal = vars[poz2].valoare.intVal;
          vars[poz1].v_int = 1;
     }
     else if (strcmp(returnType(name1), "float")==0){
          vars[poz1].valoare.floatVal = vars[poz2].valoare.floatVal;
          vars[poz1].v_float = 1;
     }
     else if (strcmp(returnType(name1), "char")==0){
          vars[poz1].valoare.charVal = vars[poz2].valoare.charVal;
          vars[poz1].v_char = 1;
     }
     else if (strcmp(returnType(name1), "string")==0){
          strcpy(vars[poz1].valoare.strVal, vars[poz2].valoare.strVal);
          vars[poz1].v_str = 1;
     }
}



int return_condition_op_bool(int nr1, int nr2, char* bool_op){
     if(strcmp(bool_op, "&&") == 0)
          return nr1 && nr2;
     if(strcmp(bool_op, "||") == 0)
          return nr1 || nr2;
}

int return_condition_value_int(int nr1 , int nr2, char* bool_op ){
     if(strcmp(bool_op, "==") == 0)
          return nr1 == nr2;
     else if(strcmp(bool_op, ">") == 0)
          return nr1 > nr2;
     else if(strcmp(bool_op, "<") == 0)
          return nr1 < nr2;
     else if(strcmp(bool_op, ">=") == 0)
          return nr1 >= nr2;
     else if(strcmp(bool_op, "<=") == 0)
          return nr1 <= nr2;
     else if(strcmp(bool_op, "!=") == 0)
          return nr1 != nr2;
}

int return_condition_value_float(float nr1 , float nr2,  char* bool_op ){
     if(strcmp(bool_op, "==") == 0)
          return nr1 == nr2;
     else if(strcmp(bool_op, ">") == 0)
          return nr1 > nr2;
     else if(strcmp(bool_op, "<") == 0)
          return nr1 < nr2;
     else if(strcmp(bool_op, ">=") == 0)
          return nr1 >= nr2;
     else if(strcmp(bool_op, "<=") == 0)
          return nr1 <= nr2;
     else if(strcmp(bool_op, "!=") == 0)
          return nr1 != nr2;
}


void tabel(){
     int i=0;
     printf("\nTabel variabile:\n");
     for(i = 0; i < noVars; i++){
         printf("name: %s, ", vars[i].name);
         printf("type: %s, ", vars[i].type);
         printf("scop: %s ", vars[i].scope);
         if(vars[i].v_int == 1)
               printf(", valoare: %d ", vars[i].valoare.intVal);

         if (vars[i].v_float == 1)
               printf(", valoare: %f", vars[i].valoare.floatVal);

         if (vars[i].v_char == 1)
               printf(", valoare: %s ", vars[i].valoare.charVal);

          if (vars[i].v_str == 1)
               printf(", valoare: %s ", vars[i].valoare.strVal);

         printf("\n");
    }
    
}

void fisier_variables()
{
     FILE *fptr;
     fptr = fopen("symbol_table.txt", "w");

     if(fptr == NULL)
     {
          printf("Error!");   
          exit(1);             
     }

     int i = 0;

     for(i = 0; i < noVars; i++){

          fprintf(fptr, "name: %s , ", vars[i].name);
          fprintf(fptr, "type: %s , ", vars[i].type);
          fprintf(fptr, "scope: %s ", vars[i].scope);

          if(vars[i].v_int == 1)
               fprintf(fptr, ", valoare: %d ", vars[i].valoare.intVal);

         if (vars[i].v_float == 1)
               fprintf(fptr, ", valoare: %f", vars[i].valoare.floatVal);

         if (vars[i].v_char == 1)
               fprintf(fptr, ", valoare: %s ", vars[i].valoare.charVal);

          if (vars[i].v_str == 1)
               fprintf(fptr, ", valoare: %s ", vars[i].valoare.strVal);

         fprintf(fptr, "\n");

    }

     fclose(fptr);

}



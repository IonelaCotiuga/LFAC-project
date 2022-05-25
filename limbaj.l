%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "limbaj.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool" {yylval.strval=strdup(yytext);  return TIP;} // pentru a stii tipul variabilei  
"=="|">"|"<"|"!="|">="|"<=" {yylval.strval=strdup(yytext);  return VERIFY;}
"&&"|"||" {yylval.strval=strdup(yytext);  return BOOL_OP;}
"+" {yylval.strval=strdup(yytext);  return PLUS;}
"-" {yylval.strval=strdup(yytext);  return MINUS;}
"*" {yylval.strval=strdup(yytext);  return MUL;}
"/" {yylval.strval=strdup(yytext);  return DIV;}

"if" {yylval.strval=strdup(yytext); return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"begin_progr" {return BGIN;}
"end_progr" {return END;}
"begin_global" {return BGIN_GLOBAL;}
"end_global" {return END_GLOBAL;}
"begin_definitions" {return BGIN_DEF;}
"end_definitions" {return END_DEF;}
"Print" {return PRINT;}

[_a-zA-Z][_a-zA-Z0-9]* {yylval.strval=strdup(yytext); return ID;} // pt a stii numele variabilei
"=" {return ASSIGN;}
["][a-zA-Z0-9 \t]*["]+ {yylval.strval=strdup(yytext); return STRING;} 
'[a-zA-Z]' {yylval.strval=strdup(yytext); return CHARACTER;}
[0-9]+ {yylval.intval=atoi(yytext); return NR;}
[0-9]+"."[0-9]*	{ yylval.floatval = atof(yytext); return FLOAT_NR;}
[ \t] ; // ignoram spatiile albe
\n {yylineno++;} // va fi incrementata de cate ori va fi un rand nou
. {return yytext[0];}




                      
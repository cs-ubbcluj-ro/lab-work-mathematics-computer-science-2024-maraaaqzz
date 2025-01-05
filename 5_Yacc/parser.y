%{
#include "parser.h"
#include <stdio.h>
#include <stdlib.h>

extern char *yytext;
int yylval;
void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;

int last_production = 0; 
%}

%token DEF PRINT INPUT IF ELSE WHILE FOR IN RANGE TRUE FALSE
%token ID INT_CONSTANT FLOAT_CONSTANT REL_OP ADD_OP MUL_OP
%token COLON NEWLINE LPAREN RPAREN COMMA EQ LT GT STRING_CONSTANT
%token INDENT DEDENT 

%left MUL_OP
%left ADD_OP
%nonassoc EQ
%nonassoc ELSE

%%

program
    : DEF ID LPAREN RPAREN COLON NEWLINE INDENT stmtlist  
      {
        last_production = 1;
        printf("Production used %d\n", last_production);
        printf("Parsed a program\n");
      }
    ;


stmtlist
    : stmt stmtlist        { last_production = 2; printf("Parsed stmt followed by stmtlist\n"); }
    | stmt                 { last_production = 2; printf("Parsed single statement\n"); }
    | NEWLINE stmtlist     { last_production = 3; printf("Parsed stmtlist with leading newline\n"); }
    | NEWLINE              { last_production = 3; printf("Parsed newline\n"); }
    ;

stmt
    : simplestmt
      {
        last_production = 4;
        printf("Parsed a simple statement\n");
      }
    | structstmt
      {
        last_production = 4;
        printf("Parsed a structured statement\n");
      }
    ;

simplestmt
    : assignstmt
    | iostmt
      {
        last_production = 5;
        printf("Production used %d\n", last_production);
        printf("Parsed a simple statement\n");
      }
    ;

structstmt
    : ifstmt
    | whilestmt
    | forstmt
      {
        last_production = 6;
        printf("Production used %d\n", last_production);
        printf("Parsed a structured statement\n");
      }
    ;

assignstmt
    : ID EQ expression
      {
        last_production = 7;
        printf("Production used %d\n", last_production);
        printf("Parsed an assignment: %s = %d\n", yytext, yylval); 
      }
    ;

iostmt
    : PRINT LPAREN expression RPAREN
      {
        last_production = 8;
        printf("Production used %d\n", last_production);
        printf("Parsed a print statement\n");
      }
    | ID EQ INPUT LPAREN RPAREN
      {
        last_production = 9;
        printf("Production used %d\n", last_production);
        printf("Parsed an input statement\n");
      }
    ;

whilestmt
    : WHILE LPAREN condition RPAREN COLON NEWLINE INDENT stmtlist DEDENT
      {
        last_production = 12;
        printf("Production used %d\n", last_production);
        printf("Parsed a while statement\n");
      }
    ;

ifstmt
    : IF LPAREN condition RPAREN COLON NEWLINE INDENT stmtlist DEDENT
      {
        last_production = 10;
        printf("Production used %d\n", last_production);
        printf("Parsed an if statement\n");
      }
    | IF LPAREN condition RPAREN COLON NEWLINE INDENT stmtlist DEDENT ELSE COLON NEWLINE INDENT stmtlist DEDENT
      {
        last_production = 11;
        printf("Production used %d\n", last_production);
        printf("Parsed an if-else statement\n");
      }
    ;

forstmt
    : FOR ID IN range COLON NEWLINE INDENT stmtlist DEDENT
      {
        last_production = 13;
        printf("Production used %d\n", last_production);
        printf("Parsed a for loop\n");
      }
    ;

range
    : RANGE LPAREN expression RPAREN
      {
        last_production = 14;
        printf("Production used %d\n", last_production);
        printf("Parsed a range with one argument\n");
      }
    | RANGE LPAREN expression COMMA expression RPAREN
      {
        last_production = 15;
        printf("Production used %d\n", last_production);
        printf("Parsed a range with two arguments\n");
      }
    ;

expression
    : expression ADD_OP term
      {
        last_production = 16;
        printf("Production used %d\n", last_production);
        printf("Parsed an addition/subtraction\n");
      }
    | term
      {
        last_production = 17;
        printf("Production used %d\n", last_production);
        printf("Parsed an expression\n");
      }
    ;

term
    : term MUL_OP factor
      {
        last_production = 18;
        printf("Production used %d\n", last_production);
        printf("Parsed a multiplication/division\n");
      }
    | factor
      {
        last_production = 19;
        printf("Production used %d\n", last_production);
        printf("Parsed a term\n");
      }
    ;

factor
    : LPAREN expression RPAREN
      {
        last_production = 20;
        printf("Production used %d\n", last_production);
        printf("Parsed a grouped expression\n");
      }
    | ID
      {
        last_production = 21;
        printf("Production used %d\n", last_production);
        printf("Parsed an identifier\n");
      }
    | constant
      {
        last_production = 22;
        printf("Production used %d\n", last_production);
        printf("Parsed a constant\n");
      }
    ;

condition
    : expression REL_OP expression
      {
        last_production = 23;
        printf("Production used %d\n", last_production);
        printf("Parsed a condition\n");
      }
    ;

constant
    : INT_CONSTANT
    | FLOAT_CONSTANT
    | STRING_CONSTANT
    | TRUE
    | FALSE
      {
        last_production = 24;
        printf("Production used %d\n", last_production);
        printf("Parsed a constant\n");
      }
    ;

%%

void yyerror(const char *s) {
    extern int yylineno;
    extern char *yytext; 
    fprintf(stderr, "Error at line %d: %s at token '%s'\n", yylineno, s, yytext);
    fprintf(stderr, "Error in production: %d\n", last_production);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error opening file");
            return 1;
        }
    }

    if (yyparse() == 0) {
        printf("Parsing completed successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }

    if (yyin) fclose(yyin);
    return 0;
}

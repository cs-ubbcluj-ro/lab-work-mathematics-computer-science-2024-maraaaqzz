%{
#include "parser.h"
#include <stdio.h>
#include <stdlib.h>

int yylineno = 1;
int current_indent = 0;
int indent_stack[100];
int indent_index = 0;
int yylval;
%}

%%

"def"         { return DEF; }
"print"       { return PRINT; }
"input"       { return INPUT; }
"if"          { return IF; }
"else"        { return ELSE; }
"while"       { return WHILE; }
"for"         { return FOR; }
"in"          { return IN; }
"range"       { return RANGE; }
"True"        { return TRUE; }
"False"       { return FALSE; }

"=="          { return REL_OP; }
"!="          { return REL_OP; }
"<="          { return REL_OP; }
">="          { return REL_OP; }
"<"           { return LT; }
">"           { return GT; }

"+"           { return ADD_OP; }
"-"           { return ADD_OP; }
"*"           { return MUL_OP; }
"/"           { return MUL_OP; }
"="           { return EQ; }

":"           { return COLON; }
"("           { return LPAREN; }
")"           { return RPAREN; }
","           { return COMMA; }

[a-zA-Z_][a-zA-Z0-9_]*    { printf("Lexing ID: %s\n", yytext); return ID; }
[0-9]+                    { yylval = atoi(yytext); return INT_CONSTANT; }
[0-9]+\.[0-9]+            { yylval = atof(yytext); return FLOAT_CONSTANT; }
"\"[^\"]*\""              { return STRING_CONSTANT; }

^[ \t]+ {
    int new_indent = yyleng; 
    if (new_indent > current_indent) {
        indent_stack[indent_index++] = current_indent;
        current_indent = new_indent;
        return INDENT;
    }
    while (new_indent < current_indent && indent_index > 0) {
        indent_index--;
        current_indent = indent_stack[indent_index];
        unput('\n'); // push the NEWLINE back to reprocess after DEDENT
        return DEDENT;
    }
}

\n {
    yylineno++;
    return NEWLINE;
}

[ \t]+ ; 

. {
    fprintf(stderr, "Unrecognized token: %s at line %d\n", yytext, yylineno);
}

%%

int yywrap() {
    return 1;
}

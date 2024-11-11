%{
    #include <string.h>
    #include <stdio.h>

    typedef struct {
        char token[257];
        int symbolTableCode;
    } ProgramInternalForm;

    typedef struct {
        char token[257];
        int index;
    } SymbolTable;

    SymbolTable ST[100];
    int stLength = 0;

    ProgramInternalForm PIF[300];
    int pifLength = 0;

    int errorFound = 0;
    int lineNumber = 1;

    int addToST(char* token) {
        for (int i = 0; i < stLength; i++) {
            if(strcmp(ST[i].token, token) == 0) {
                return ST[i].index;
            }
        }

        strcpy(ST[stLength].token, token);
        ST[stLength].index = stLength;
        stLength++;

        return stLength - 1;
    }

    void addToPIF(char* token, int stCode) {
        strcpy(PIF[pifLength].token, token);

        PIF[pifLength].symbolTableCode = stCode;
        pifLength++;
    }

    void showSymbolTable() {
        printf("SYMBOL TABLE\n");

        for (int i = 0; i < stLength; i++) {
            printf(" %s  %d", ST[i].token, ST[i].index);
            printf("\n");
        }

        printf("END TABLE\n");
    }

    void showProgramInternalForm() {
        printf("PIF\n");

        for (int i = 0; i < pifLength; i++) {
            printf(" %s  %d", PIF[i].token, PIF[i].symbolTableCode);
            printf("\n");
        }

        printf("END PIF\n");
    }
%}

LETTER          [A-Za-z]
DIGIT           [0-9]
ID              {LETTER}({LETTER}|{DIGIT}|_)*
INT_CONST       [+-]?{DIGIT}+
FLOAT_CONST     [+-]?{DIGIT}+(\.{DIGIT}+)
WS              [ \t]+
NEWLINE         \n

%%

int             { addToPIF(yytext, -1); }
float           { addToPIF(yytext, -1); }
if              { addToPIF(yytext, -1); }
else            { addToPIF(yytext, -1); }
while           { addToPIF(yytext, -1); }
for             { addToPIF(yytext, -1); }
print           { addToPIF(yytext, -1); }
input           { addToPIF(yytext, -1); }
true            { addToPIF(yytext, -1); }
false           { addToPIF(yytext, -1); }
def             { addToPIF(yytext, -1); }
main            { addToPIF(yytext, -1); }

"="             { addToPIF(yytext, -1); }
"=="            { addToPIF(yytext, -1); }
"!="            { addToPIF(yytext, -1); }
"<"             { addToPIF(yytext, -1); }
"<="            { addToPIF(yytext, -1); }
">"             { addToPIF(yytext, -1); }
">="            { addToPIF(yytext, -1); }
"+"             { addToPIF(yytext, -1); }
"-"             { addToPIF(yytext, -1); }
"*"             { addToPIF(yytext, -1); }
"/"             { addToPIF(yytext, -1); }

"("             { addToPIF(yytext, -1); }
")"             { addToPIF(yytext, -1); }
"{"             { addToPIF(yytext, -1); }
"}"             { addToPIF(yytext, -1); }
";"             { addToPIF(yytext, -1); }
":"             { addToPIF(yytext, -1); }


{ID}            { int stCode = addToST(yytext); addToPIF(yytext, stCode); }
{INT_CONST}     { int stCode = addToST(yytext); addToPIF(yytext, stCode); }
{FLOAT_CONST}   { int stCode = addToST(yytext); addToPIF(yytext, stCode); }

{NEWLINE}       { lineNumber++; } // count where the lines to show where is the error
[ \t]+          { /* Ignore spaces and tabs */ }
.               { errorFound = 1; printf("Illegal token %s at line %d!\n", yytext, lineNumber); }

%%

int yywrap() { return 1; }

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("File opening failed");
        return EXIT_FAILURE;
    }

    yyin = fp;
    yylex();

    if (errorFound == 0) {
        showSymbolTable();
        showProgramInternalForm();
    }

    fclose(fp);
    return 0;
}

// Each entry in the PIF stores a token and a code indicating the symbol table index 
// or -1 if the token is a keyword.

// The symbol table stores unique tokens (such as identifiers or constants) and their associated indices
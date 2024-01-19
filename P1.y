/* Definitions */
%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>

  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;

  void yyerror(const char *s);

  void add(char key[], char args[][100], int argLength, char value[]);
  int getIndex(char key[]);
  char* get(char key[], char argInputs[][100]);
  int countArgs(char str[]);
  void argsToArray(char str[], char argsArray[][100]);
%}

%union {
    char *sval;
}

/* TOKENS */
%token<sval> IDENTIFIER;
%token<sval> INTEGER;
%token<sval> DEFINE SYSPRINT COMMENT;
%token<sval> CLASS PUBLIC STATIC VOID MAIN STRING RETURN DOT COMMA;
%token<sval> LPAREN RPAREN LBRACE RBRACE LSQBRA RSQBRA SEMICOLON;
%token<sval> INTARRAY BOOLEAN INT;
%token<sval> IF ELSE DO WHILE;
%token<sval> TRUE FALSE;
%token<sval> THIS NEW LENGTH;
%token<sval> NOT AND OR NOTEQ EQ GREATER LESS GREATEREQ LESSEQ ASSIGN;
%token<sval> PLUS MINUS MULTIPLY DIVIDE;

%type <sval> goal MainClass MacroDefintions MacroDefintion MacroDefStatement MacroDefExpression Identifiers Statements Statement Expressions Expression PrimaryExpression Objects Object TypeIdentifiers MethodDeclarations MethodDeclaration Type Arguments;


/* RULES */
%%

goal : MacroDefintions MainClass Objects { printf("%s", $1); printf("%s\n", $2); printf("%s", $3); free($1); free($2); free($3); };
MainClass : CLASS IDENTIFIER LBRACE PUBLIC STATIC VOID MAIN LPAREN STRING IDENTIFIER RPAREN LBRACE SYSPRINT LPAREN Expression RPAREN SEMICOLON RBRACE RBRACE
    { 
      $$ = malloc(strlen("class  {\n   public static void main(String[] ){\n     System.out.println();\n    }\n}") + strlen($2) + strlen($10) + strlen($15) + 1);
      sprintf($$, "class %s{\n  public static void main(String[] %s){\n    System.out.println(%s);\n  }\n}", $2, $10, $15);
    }
;

MacroDefintions : { $$ = strdup(""); }
    | MacroDefintions MacroDefintion { $$ = strdup(""); };
MacroDefintion : MacroDefExpression 
    | MacroDefStatement;
MacroDefStatement : DEFINE IDENTIFIER LPAREN Identifiers RPAREN LBRACE Statements RBRACE
{
  char args[5][100];
  int c = countArgs($4);
  argsToArray($4, args);

  add($2, args, c, $7);
  
}
;
MacroDefExpression : DEFINE IDENTIFIER LPAREN Identifiers RPAREN LPAREN Expression RPAREN
{
  char args[5][100];
  int c = countArgs($4);
  argsToArray($4, args);

  add($2, args, c, $7);
}
;

Identifiers : { $$ = strdup(""); }
    | IDENTIFIER { $$ = strdup($1); }
    | Identifiers COMMA IDENTIFIER 
    { $$ = malloc(strlen(", ") + strlen($1) + strlen($3) + 1); sprintf($$, "%s, %s", $1, $3); }
;
Statements : Statement 
    | Statements Statement
    { 
      $$ = malloc(strlen("\n") + strlen($1) + strlen($2)+ 1);
      sprintf($$, "%s%s", $1, $2);
    }
;
Statement : SYSPRINT LPAREN Expression RPAREN SEMICOLON
    { $$ = malloc(strlen("System.out.println();\n") + strlen($3) + 1);
      sprintf($$, "System.out.println(%s);", $3);
    }
    | IDENTIFIER ASSIGN Expression SEMICOLON
    { $$ = malloc(strlen(" = ;\n") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s = %s;\n", $1, $3);
    }
    | IDENTIFIER LSQBRA Expression RSQBRA ASSIGN Expression SEMICOLON
    { $$ = malloc(strlen("[] = ;\n") + strlen($1) + strlen($3) + strlen($6) + 1);
      sprintf($$, "%s[%s] = %s;\n", $1, $3, $6);
    }
    | IF LPAREN Expression RPAREN Statement
    { $$ = malloc(strlen("if ()\n    \n") + strlen($3) + strlen($5) + 1);
      sprintf($$, "if (%s)\n    %s\n", $3, $5);
    }
    | IF LPAREN Expression RPAREN Statement ELSE Statement
    { $$ = malloc(strlen("if ()\n          else\n      \n") + strlen($3) + strlen($5) + strlen($7) + 1);
      sprintf($$, "if (%s)\n      %s    else\n      %s\n", $3, $5, $7);
    }
    | IF LPAREN Expression RPAREN LBRACE Statements RBRACE
    { $$ = malloc(strlen("if () {\n}\n") + strlen($3) + strlen($6) + 1);
      sprintf($$, "if (%s) {\n%s}\n", $3, $6);
    }
    | IF LPAREN Expression RPAREN LBRACE Statements RBRACE ELSE LBRACE Statements RBRACE
    { $$ = malloc(strlen("if () {} \nelse {}\n") + strlen($3) + strlen($6) + strlen($10) + 1);
      sprintf($$, "if (%s) {%s} \nelse {%s}\n", $3, $6, $10);
    }
    | DO Statement WHILE LPAREN Expression RPAREN SEMICOLON
    { $$ = malloc(strlen("do {\n} while ();\n") + strlen($2) + strlen($5) + 1);
      sprintf($$, "do {\n%s} while (%s);\n", $2, $5);
    }
    | WHILE LPAREN Expression RPAREN Statement
    { $$ = malloc(strlen("while () {\n}\n") + strlen($3) + strlen($5) + 1);
      sprintf($$, "while (%s) {\n%s}\n", $3, $5);
    }
    | WHILE LPAREN Expression RPAREN LBRACE Statements RBRACE
    { $$ = malloc(strlen("while () {\n}\n") + strlen($3) + strlen($6) + 1);
      sprintf($$, "while (%s) {\n%s}\n", $3, $6);
    }
    | IDENTIFIER LPAREN Expressions RPAREN SEMICOLON
    { 
      if (getIndex($1) != -1){
        if ($3[0]=='\0'){ /* no arguments */
          char emptyArgs[5][100];
          char* result = get($1, emptyArgs);
          $$ = malloc(strlen("()") + strlen(result) + 1);
          sprintf($$, "%s", result);
        }else{
          char actualArgs[5][100];
          argsToArray($3, actualArgs);
          char* result = get($1, actualArgs); 
          $$ = malloc(strlen("()") + strlen(result) + 1);
          sprintf($$, "%s", result);
        }
      }else{
        $$ = malloc(strlen("();") + strlen($1) + strlen($3) + 1);
        sprintf($$, "%s(%s);", $1, $3);
      }
    }
;
Expressions : { $$ = strdup(""); }
    | Expression
    | Expressions COMMA Expression
    { $$ = malloc(strlen(", ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s, %s", $1, $3);
    }
;
Expression : PrimaryExpression AND PrimaryExpression
    { $$ = malloc(strlen(" && ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s && %s", $1, $3);
    }
    | PrimaryExpression OR PrimaryExpression
    { $$ = malloc(strlen(" || ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s || %s", $1, $3);
    }
    | PrimaryExpression NOTEQ PrimaryExpression
    { $$ = malloc(strlen(" != ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s != %s", $1, $3);
    }
    | PrimaryExpression LESSEQ PrimaryExpression
    { $$ = malloc(strlen(" <= ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s <= %s", $1, $3);
    }
    | PrimaryExpression PLUS PrimaryExpression
    { $$ = malloc(strlen(" + ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s + %s", $1, $3);
    }
    | PrimaryExpression MINUS PrimaryExpression
    { $$ = malloc(strlen(" - ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s - %s", $1, $3);
    }
    | PrimaryExpression MULTIPLY PrimaryExpression
    { $$ = malloc(strlen(" * ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s * %s", $1, $3);
    }
    | PrimaryExpression DIVIDE PrimaryExpression
    { $$ = malloc(strlen(" / ") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s / %s", $1, $3);
    }
    | PrimaryExpression LSQBRA PrimaryExpression RSQBRA
    { $$ = malloc(strlen("[]") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s[%s]", $1, $3);
    }
    | PrimaryExpression LENGTH
    { $$ = malloc(strlen(".length") + strlen($1) + 1);
      sprintf($$, "%s.length", $1);
    }
    | PrimaryExpression
    { $$ = strdup($1); }
    | PrimaryExpression DOT IDENTIFIER LPAREN Expressions RPAREN
    { $$ = malloc(strlen(".()") + strlen($1) + strlen($3) + 1);
      sprintf($$, "%s.%s(%s)", $1, $3, $5);
    }
    | IDENTIFIER LPAREN Expressions RPAREN
    { 

      if (getIndex($1) != -1){
        if ($3[0]=='\0'){ /* no arguments */
          char emptyArgs[5][100];
          char* result = get($1, emptyArgs);
          $$ = malloc(strlen("()") + strlen(result) + 1);
          sprintf($$, "%s", result);
        }else{
          char actualArgs[5][100];
          argsToArray($3, actualArgs);
          char* result = get($1, actualArgs); 
          $$ = malloc(strlen("()") + strlen(result) + 1);
          sprintf($$, "%s", result);
        }
      }else{
        $$ = malloc(strlen("();") + strlen($1) + strlen($3) + 1);
        sprintf($$, "%s(%s);", $1, $3);
      }
    }
;
PrimaryExpression : INTEGER { $$ = strdup($1); } | TRUE { $$ = strdup("true"); } | 
    FALSE { $$ = strdup("false"); } | IDENTIFIER { $$ = strdup($1); } | THIS { $$ = strdup("this"); }
    | NEW INT LSQBRA Expression RSQBRA 
    { $$ = malloc(strlen("new int[]{}") + strlen($4) + 1);
      sprintf($$, "new int[]{%s}", $4);
    }
    | NEW IDENTIFIER LPAREN RPAREN
    { $$ = malloc(strlen("new ()") + strlen($2) + 1);
      sprintf($$, "new %s()", $2);
    }
    | NOT Expression
    { $$ = malloc(strlen("!") + strlen($2) + 1);
      sprintf($$, "!%s", $2);
    }
    | LPAREN Expression RPAREN
    { $$ = malloc(strlen("()") + strlen($2) + 1);
      sprintf($$, "(%s)", $2);
    }
;

Objects : { $$ = strdup("\n"); }
    | Objects Object     
    { $$ = malloc(strlen("\n") + strlen($1) + strlen($2)+ 1);
      sprintf($$, "%s%s\n", $1, $2);
    }
;
Object : CLASS IDENTIFIER LBRACE TypeIdentifiers MethodDeclarations RBRACE
    { $$ = malloc(strlen("class {\n}\n") + strlen($2) + strlen($4) + strlen($5) + 1);
      sprintf($$, "class %s{\n  %s\n%s}\n", $2, $4, $5);
    }
;

TypeIdentifiers : { $$ = strdup("\n"); }
    | TypeIdentifiers Type IDENTIFIER SEMICOLON
    { $$ = malloc(strlen("  ;\n") + strlen($1) + strlen($2) + strlen($3) + 1);
      sprintf($$, "%s%s %s;\n", $1, $2, $3);
    }
;

MethodDeclarations : { $$ = strdup("\n"); }
    | MethodDeclarations MethodDeclaration
    { 
      $$ = malloc(strlen("\n") + strlen($1) + strlen($2)+ 1);
      sprintf($$, "%s%s\n", $1, $2);
    }
;
MethodDeclaration : PUBLIC Type IDENTIFIER LPAREN Arguments RPAREN LBRACE TypeIdentifiers Statements RETURN Expression SEMICOLON RBRACE
    { $$ = malloc(strlen("  public () {\n            return ; \n  }\n") + strlen($2) + strlen($3) + strlen($5) + strlen($8) + strlen($9) + strlen($11) + 1);
      sprintf($$, "  public %s %s(%s) {\n    %s    %s    return %s; \n  }\n", $2, $3, $5, $8, $9, $11);
    }
;

Type : INTARRAY { $$ = strdup("int[]"); }
    | BOOLEAN { $$ = strdup("boolean"); }
    | INT { $$ = strdup("int"); }
    | IDENTIFIER { $$ = strdup($1); }
;

Arguments : { $$ = strdup(""); }
    | Type IDENTIFIER
    { $$ = malloc(strlen("  ") + strlen($1) + strlen($2) + 1);
      sprintf($$, "%s %s", $1, $2);
    }
    | Arguments COMMA Type IDENTIFIER
    { $$ = malloc(strlen(",  ") + strlen($1) + strlen($3) + strlen($4) + 1);
      sprintf($$, "%s, %s %s", $1, $3, $4);
    }
;
%%
/* C Code */

int macrosLength = 0;

struct Macro{
    char key[100];
    char args[5][100];
    int numArgs;
    char value[100];
};

struct Macro macros[10];
int getIndex(char key[]){
    for (int i = 0; i < macrosLength; i++){
        if (strcmp(key, macros[i].key) == 0){
            return i;
        }
    }
    return -1;
}
void add(char key[], char args[][100], int argLength, char value[]){
    int index = getIndex(key);
    if (index == -1){
        strcpy(macros[macrosLength].key, key);
        macros[macrosLength].numArgs = argLength;
        for (int i = 0; i < argLength; i++){
            strcpy(macros[macrosLength].args[i], args[i]);
        }
        strcpy(macros[macrosLength].value, value);
        macrosLength++;
    
    }else{
        for (int i = 0; i < argLength; i++){
            strcpy(macros[index].args[i], args[i]);
        }
        strcpy(macros[index].value, value);
    }
}
char* get(char key[], char argInputs[][100]){
    int index = getIndex(key);
    if (index == -1) return "false";

    size_t resultSize = strlen(macros[index].value);
    char* result = (char*) malloc(resultSize+1);

    strcpy(result, macros[index].value);

    char* argCheck;
    char* val;
    char* replace;

    for (int i = 0; i < macros[index].numArgs; i++){
        argCheck = macros[index].args[i];
        val = argInputs[i];

        replace = strstr(result, argCheck);
        

        while (replace != NULL){
            int diff = replace - result;

            /* shifts everything after argument replacement to match the length of the argument */
            memmove(replace + strlen(val), replace + strlen(argCheck), strlen(replace + strlen(argCheck)) + 1);
            /* copies the argument into the correct spot */
            memcpy(replace, val, strlen(val)); 

            replace = strstr(replace + strlen(val), argCheck);
        }
    }
    return result;
}
void printMacroMap(){
    for (int i = 0; i < macrosLength; i++){
        printf("%s(",macros[i]);
        for (int j = 0; j < macros[i].numArgs-1; j++){
            printf("%s,", macros[i].args[j]);
        }
        printf("%s", macros[i].args[macros[i].numArgs-1]);
        printf(")  ->  %s\n", macros[i].value);
    }
}

int countArgs(char str[]){

  if (str[0] == '\0'){ return 0; }
  int count = 1;

  for (int i = 0; str[i] != '\0'; i++){
    if (str[i] == ','){
      count++;
    }
  }
  return count;
}

void argsToArray(char str[], char argsArray[][100]){
    int numArguments = countArgs(str);

    char* token = strtok((char*)str, ",");
    int i = 0;

    while (token != NULL && i < numArguments) {
        strcpy(argsArray[i], token);
        token = strtok(NULL, ",");
        i++;
    }
}

int main(int, char**) {
    /* read from file instead of stdin */
    FILE *myfile = fopen("X.java", "r");
    if (!myfile) {
        printf("Invalid File\n");
        return -1;
    }
    yyin = myfile;

    yyparse();
    fclose(myfile);
    
    return 0;
}

void yyerror(const char *s){
    printf("//Failed to parse macrojava code: %s\n", s);
    /* halt program */
    exit(-1);
}
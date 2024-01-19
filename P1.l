/* Definitions */
%{
    extern int yylex();
    #include "P1.tab.h"
    #include <string.h>
%}

%option noyywrap

/* Rules */
%%
#define { return DEFINE; }
System.out.println { return SYSPRINT; }
public { return PUBLIC; }
static { return STATIC; }
void { return VOID; }
main { return MAIN; }
return { return RETURN; }
String\[\] { return STRING; }
class { return CLASS; }
\( { return LPAREN; }
\) { return RPAREN; }
\{ { return LBRACE; }
\} { return RBRACE; }
\[ { return LSQBRA; }
\] { return RSQBRA; }
\. { return DOT; }
\, { return COMMA; }
int { return INT; }
int\[\] { return INTARRAY; }
boolean { return BOOLEAN; }
if { return IF; }
else { return ELSE; }
do { return DO; }
while { return WHILE; }
true { return TRUE; }
FALSE { return FALSE; }
this { return THIS; }
new { return NEW; }
.length { return LENGTH; }
! { return NOT; }
&& { return AND; }
\|\| { return OR; }
; { return SEMICOLON; }
!= { return NOTEQ; }
== { return EQ; }
= { return ASSIGN; }
\> { return GREATER; }
\< { return LESS; }
\>= { return GREATEREQ; }
\<= { return LESSEQ; }
\+ { return PLUS; }
\- { return MINUS; }
\* { return MULTIPLY; }
\/ { return DIVIDE; }
\/\/.* { return COMMENT; }
[0-9]+ {
    yylval.sval = strdup(yytext);
    return INTEGER;
}
[A-Za-z_$][A-Za-z0-9_$]* {
    yylval.sval = strdup(yytext);
    return IDENTIFIER;
}
<<EOF>> { return 0; yyterminate(); }
. {}
%%

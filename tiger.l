%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

#define BUFSIZE 1024

int charPos=1;
int commentDepth = 0;

char strbuf[BUFSIZE];
int strLength;

int yywrap(void)
{
 charPos=1;
 return 1;
}

void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

void init(void){
    *strbuf = '\0';
    strLength = 0;
}

void append(char* str){
    if (strLength + strlen(str) < BUFSIZE){
        strcat(strbuf, str);
        strLength += strlen(str);
    }
}

char* fin(void){
    char *s = checked_malloc(strlen(strbuf) + 1);
    strcpy(s, strbuf);
    return s;
}


%}
%x COMMENT STR
%%
while   {adjust(); return WHILE;}
for     {adjust(); return FOR;}
to      {adjust(); return TO;}
break   {adjust(); return BREAK;}
let     {adjust(); return LET;}
in      {adjust(); return IN;}
end     {adjust(); return END;}
function {adjust(); return FUNCTION;}
var     {adjust(); return VAR;}
type    {adjust(); return TYPE;}
array   {adjust(); return ARRAY;}
if      {adjust(); return IF;}
then    {adjust(); return THEN;}
else    {adjust(); return ELSE;}
do      {adjust(); return DO;}
of      {adjust(); return OF;}
nil     {adjust(); return NIL;}

","     {adjust(); return COMMA;}
":"     {adjust(); return COLON;}
";"     {adjust(); return SEMICOLON;}
"("     {adjust(); return LPAREN;}
")"     {adjust(); return RPAREN;}
"["     {adjust(); return LBRACK;}
"]"     {adjust(); return RBRACK;}
"{"     {adjust(); return LBRACE;}
"}"     {adjust(); return RBRACE;}
"."     {adjust(); return DOT;}
"+"     {adjust(); return PLUS;}
"-"     {adjust(); return MINUS;}
"*"     {adjust(); return TIMES;}
"/"     {adjust(); return DIVIDE;}
"="     {adjust(); return EQ;}
"<"     {adjust(); return LT;}
">"     {adjust(); return GT;}
"<>"    {adjust(); return NEQ;}
"<="    {adjust(); return LE;}
">="    {adjust(); return GE;}
"&"     {adjust(); return AND;}
"|"     {adjust(); return OR;}
":="    {adjust(); return ASSIGN;}

[a-zA-Z][_0-9a-zA-Z]*   {adjust(); return ID;}


"-"?[1-9][0-9]*     {adjust(); yylval.ival=atoi(yytext); return INT;}

"/*"    {adjust(); BEGIN(COMMENT);}
<COMMENT>{
    "/*"    {adjust(); commentDepth++;}
    [^\n]   {adjust();}
    (\n|\r\n)   {adjust(); EM_newline();}
    "*/"    {adjust(); if(--commentDepth == 0) BEGIN(INITIAL);}
}

\"      {adjust(); BEGIN(STR); init();}
<STR>{
    \" {
        adjust();
        yylval.sval = fin();
        BEGIN(INITIAL);
        return STRING;
    }
    \\n {
        adjust();
        append("\n");
    }
    \\t {
        adjust();
        append("\t");
    }
    \\\" {
        adjust();
        append(yytext);
    }
    \\\\ {
        adjust();
        append(yytext);
    }
    \\[0-9]{3} {
        adjust();
        append(yytext);
    }
    \\^[GHIJLM] {
        adjust();
        append(yytext);
    }
    \\[ \n\t\r\f]+\\ {
        adjust();
    }
    \\(.|\n)    {adjust(); EM_error(EM_tokPos, "illegal token");}
    \n          {adjust(); EM_error(EM_tokPos, "illegal token");}
    [^\"\\\n]+  {adjust(); append(yytext);}
}

" "     {adjust(); continue;}
\n      {adjust(); EM_newline(); continue;}

.       {adjust(); EM_error(EM_tokPos,"illegal token");}
%%

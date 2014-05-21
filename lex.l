/*calculator :(),variable*/
/*let variable name support string*/
/*if while*/
/*if-else*/
%{
#include "main.hpp"//lex和yacc要共用的头文件，里面包含了一些头文件，重定义了YYSTYPE
#include "yacc.tab.h"//由yacc自动生成的所有标记声明，实际上都是C宏

extern "C"//为了能够在C++程序里面调用C函数，必须把每一个需要使用的C函数，其声明都包括在extern "C"{}块里面，这样C++链接时才能成功链接它们。extern "C"用来在C++环境下设置C链接类型。
{
	int yywrap(void);
	int yylex(void);//这个是lex生成的词法分析函数，yacc的yyparse()里会调用它，如果.l文件里不声明，生成的yacc.tab.c在编译时会找不到该函数
}
%}
%%

[0-9]+	{
	yylval.val=atoi(yytext);
	return INTEGER;
}

[-+*/()={}<>;]	{
	return *yytext;
}

">="	return GE;
"<="	return LE;
"=="	return EQ;
"!="	return NE;
"if"	return IF;
"else"	return ELSE;
"while" return WHILE;

[A-Za-z][A-Za-z0-9]*	{
	yylval.sym=createSymbol(yytext);
	return VARIABLE;
}

[\t]	;
[\n]	{yylineno++;}
.	yyerror("Unknow character");


%%

int yywrap(){
	return 1;
}

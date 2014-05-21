#ifndef MAIN_HPP
#define MAIN_HPP

#include <stdio.h>
#include <malloc.h>	
#include <string.h>
#include <stdlib.h>
#include<string>
#include <vector>
#include <iostream>

using namespace std;

extern "C" struct Symbol* createSymbol(char* name);
extern "C" int yylineno;
extern "C" void yyerror(char *s);
struct BStruct
{
 	int T;
	int F;	
};
/*下面的这个宏定义用来取消Lex和Yacc默认的YYSTYPE定义，因为默认的YYSTYPE定义仅仅只能够记录整数信息，
要保存额外的信息必须这样定义宏，可以参见Yacc自动生成的标记头文件frame.tab.h*/
#define YYSTYPE Type//yacc会把变量yylval定义为YYSTYPE类型，这里重定义了YYSTYPE的类型，也就是指定yylval的类型

#endif

 

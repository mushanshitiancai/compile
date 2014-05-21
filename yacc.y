/*calculator :(),variable*/
%{
#include "main.hpp"//lex和yacc要共用的头文件，里面包含了一些头文件，重定义了YYSTYPE

extern "C"//为了能够在C++程序里面调用C函数，必须把每一个需要使用的C函数，其声明都包括在extern "C"{}块里面，这样C++链接时才能成功链接它们。extern "C"用来在C++环境下设置C链接类型。
{
	void yyerror(char *s);
	extern int yylex(void);//该函数是在lex.yy.c里定义的，yyparse()里要调用该函数，为了能编译和链接，必须用extern加以声明
	using namespace std;
	void yyerror(char *); 
	int sym[26];
	int temp_num=0;
	int yylineno;
	char buff[1024];
	struct Symbol{
		char* name;
		int value;
	};

	typedef struct Symbol_List{
		struct Symbol* sym;
		struct Symbol_List* next;
	}SymbolList;
	SymbolList* symbolList;
	struct Symbol* createSymbol(char* name);
}
	vector<string> code;
	int base = 100;
	int ip = base;
	int param_num = 0;
	int merge(int chain1, int chain2);
	void emit(string result, string op1, string oper, string op2);
	void emit(string result, string oper, string op);
	void emit(string result, string op);
	void emit_push(string param);
	void emit_call(string name);
	void emit_goto(string ip);
	void emit_if(string condition);
	int get_ip();
	void back_patch(int chain, int now);
%}

%union{
	int val;
	char data[16];
	struct Symbol* sym;
	struct BStruct bs;
}

%token <val> INTEGER
%token <sym> VARIABLE
%token IF WHILE
%left GE LE EQ NE '<' '>'
%left '+' '-'
%left '*' '/'

%nonassoc IFX
%nonassoc ELSE

%type <data> expr
%type <bs> B
%type <val> statement
%type <val> if_m
%type <val> if_n
%type <val> while_w
%type <val> statement_list
%%

program:
program statement
|
;

statement:
';'	{$$=0;}
|expr ';'				{$$=0;}
| VARIABLE '=' expr ';' {cout<<"VARIABLE = expr "<<endl;emit($1->name,$3); $$=0;}
| if_m statement %prec IFX 
	{
		$$=merge($2,$1);
		back_patch($$,get_ip());
	}
| if_n statement 
	{
		$$=merge($2,$1);
		back_patch($$,get_ip());
	}	
| while_d statement {$$=0;}
| '{' statement_list '}'	{$$=0;}
| '{' '}'	{$$=0;}
;


statement_list:
statement			{}
|statement_list statement	{}
;

if_m:
IF '(' B ')' {
	back_patch($3.T,get_ip());
	$$=$3.F;
}
;
if_n:
if_m statement ELSE {
		int q=get_ip();
		emit_goto("0");
		back_patch($1,get_ip());
		$$=merge($2,q);	
}
;
while_w:
WHILE {
	$$=get_ip();
}
;
while_d:
while_w '(' B ')' {
}
;
B:
expr {
 $$.T=get_ip();
 emit_if($1);
 $$.F=get_ip();
 emit_goto("0"); 
}
;


expr:
INTEGER    {sprintf($$,"%d",$1);}
| VARIABLE 		{strcpy($$,$1->name);}
| expr '+' expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"+",$3);}
| expr '-' expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"-",$3);}
| expr '*' expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"*",$3);}
| expr '/' expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"/",$3);}
| expr GE expr {sprintf($$,"T%d",temp_num++);emit($$,$1,">=",$3);}
| expr LE expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"<=",$3);}
| expr EQ expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"==",$3);}
| expr NE expr {sprintf($$,"T%d",temp_num++);emit($$,$1,"!=",$3);}
| '(' expr ')'  {sprintf($$,"T%d",temp_num++);emit($$,$2);}
;

%%

void emit(string result, string op1, string oper, string op2) {
	code.push_back(result+" = "+op1+" "+oper+" "+op2);
	ip++;
}

void emit(string result, string oper, string op) {
	code.push_back(result+" = "+oper+" "+op);
	ip++;
}

void emit(string result, string op) {
	code.push_back(result+" = "+op);
	ip++;
}


void emit_push(string param) {
	param_num++;
	code.push_back("param "+param);
	ip++;
}

void emit_call(string name) {
	char buff[1024];
	sprintf(buff, "%d", param_num);
	code.push_back("call "+name+","+buff);
	param_num = 0;
	ip++;
}

void emit_goto(string _ip) {
	code.push_back("goto "+_ip);
	ip++;
}

void emit_if(string condition) {
	code.push_back("if "+condition+" goto 0");
	ip++;
}

int get_ip() {
	return ip;
}

void back_patch(int chain, int now) {
	cout<<"back_patch:chain "<<chain<<"  now "<<now<<endl;
	string codestring = code[chain-base];
	int pos = codestring.find("goto");
	int patch_ip = 0;
	char buff[16];
	
	if (string::npos == pos) {
		return ;
	}
	
	patch_ip = atoi(codestring.substr(pos+5).c_str());
	sprintf(buff, "%d", now);
	code[chain-base] = codestring.replace(pos+5, string(buff).length(),buff);

	if (0 != patch_ip) {
		back_patch(chain, patch_ip);
	}
}

int merge(int chain1, int chain2) {
	string codestring = code[chain2-base];
	int pos = codestring.find("goto");
	int patch_ip = 0;
	char buff[16];
	cout<<"merge chain1 "<<chain1<<"  chain2 "<<chain2<<endl;
	if (string::npos == pos) {
		return chain2;
	}
	
	patch_ip = atoi(codestring.substr(pos+5).c_str());
	if (0 == patch_ip) {
		sprintf(buff, "%d", chain1);
		code[chain2-base] = codestring.replace(pos+5, string(buff).length(),buff);
	} else {
		merge(chain1, patch_ip);
	}
	
	return chain2;
}

void generate_code() {
	vector<string>::iterator it = code.begin();
	for (int i = base; it < code.end(); ++it, ++i) {
		cout<<i<<": "<<*it<<endl;
	}
}

void yyerror(char *s){
    fprintf(stderr,"line:%d %s\n",yylineno,s);
}

struct Symbol* createSymbol(char* name){
	SymbolList* p=symbolList;
	while(p->next){
		struct Symbol* cur=p->next->sym;
		//printf("item:%s",cur->name);
		if(!strcmp(cur->name,name)){
			//printf("find!");
			return cur;
		}
		p=p->next;
	}
	//printf("No find!");
	p->next=(SymbolList*)malloc(sizeof(SymbolList));
	p->next->sym=(struct Symbol*)malloc(sizeof(struct Symbol));
	p->next->sym->name=strdup(name);
	p->next->next=NULL;
	return p->next->sym;
}

int main(){
	symbolList=(SymbolList*)malloc(sizeof(SymbolList));
	symbolList->next=NULL;
	yyparse();
	generate_code();
	return 0;
}


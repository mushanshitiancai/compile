LEX=flex
YACC=bison
CC=g++

main:lex.yy.o yacc.tab.o
	$(CC) lex.yy.o yacc.tab.o -o main
	@ls -l
#	@./main

lex.yy.o:lex.yy.c yacc.tab.h main.hpp
	$(CC) -c lex.yy.c

yacc.tab.o:yacc.tab.c main.hpp
	$(CC) -c yacc.tab.c

yacc.tab.c yacc.tab.h:yacc.y
	$(YACC) -d yacc.y

lex.yy.c:lex.l
	$(LEX) lex.l

clean:
	@rm -f main *.o  *.c *.h

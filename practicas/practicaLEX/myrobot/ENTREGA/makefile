robot: lex.yy.c
	gcc -o robot lex.yy.c -ll

robot2: lex.yy.c
	gcc -o robot2 lex.yy.c -ll

lex.yy.c: robot.l
	lex -l robot.l

clean:
	rm -rf robot robot2 lex.yy.c main.o

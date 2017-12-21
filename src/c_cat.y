%{

#include <stdio.h>

extern FILE * yyin;
extern int yylineno;
int yyerror(char *, ...);
int yylex();

// extern void lexer_init();
// extern void lexer_cleanup();

%}

%union {
	char * s;
	char c;
}

%token<c> ESC_C
%token<s> ESC_S CMT_L CMT_B STR KEY OP

%%

all: /* nothing */
| all STR { printf("STR(%s) ", $2); }
| all CMT_L { printf("CMT_L(%s) ", $2); }
| all CMT_B { printf("CMT_B(%s) ", $2); }
;

%%

int main(int argc, char ** argv)
{
	if (argc < 2)
	{
		printf("usage: %s cppfile\n", argv[0]);
		return 1;
	}

	// lexer_init();

	yyin = fopen(argv[1], "rb");
	if (!yyin) return 2;
	yyparse();

	// lexer_cleanup();
	return 0;
}

int yyerror(char * s, ...)
{
	fprintf(stderr, "error: %s\n", s);

	// lexer_cleanup();
	return 0;
}

int yywrap()
{
	return 0;
}

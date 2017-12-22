%option nodefault
%option noyywrap

%x _ESC_N
%x _CMT_L _CMT_B
%x _STR _STR_ESC _STR_ESCX

%{

#include "c_cat.tab.hpp"

#include "buffer.hpp"
Buffer buffer(1024 * 4);

#include "escapes.hpp"

static void on_STR_ESC_1();
static void on_STR_ESC_2();
static void on_STR_ESC_3();

%}

%%

"\\"\r?\n { }

"//" { BEGIN(_CMT_L); }
<_CMT_L>"\\"\r?\n { }
<_CMT_L>[^\r\n]* { BEGIN(INITIAL); yylval.s = yytext; return CMT_L; }
<_CMT_L>[\r\n] { BEGIN(INITIAL); yylval.s = ""; return CMT_L; }

"/\*" { BEGIN(_CMT_B); buffer.reset(); }
<_CMT_B>"\\"\r?\n { }
<_CMT_B>"\*/" { BEGIN(INITIAL); yylval.s = buffer.get(); return CMT_B; }
<_CMT_B>.|[\r\n] { buffer.putc(*yytext); }

("u8"|"u"|"U"|"L")?\" { BEGIN(_STR); buffer.reset(); }
<_STR>"\\"\r?\n { }
<_STR>[^"\\] { buffer.putc(*yytext); }
<_STR>"\"" { BEGIN(INITIAL); yylval.s = buffer.get(); return STR; }
<_STR>"\\" { BEGIN(_STR_ESC); }

<_STR_ESC>\r?\n { BEGIN(_STR); }
<_STR_ESC>['"?\\] { BEGIN(_STR); buffer.putc(*yytext); }
<_STR_ESC>[abfnrtv] { BEGIN(_STR); on_STR_ESC_1(); }
<_STR_ESC>x { BEGIN(_STR_ESCX); }
<_STR_ESC>[0-7]{1,3} { BEGIN(_STR); on_STR_ESC_2(); }
<_STR_ESCX>[0-9A-Fa-f]+ { BEGIN(_STR); on_STR_ESC_3(); }

. { printf("\nMystery character |%c|.\n", *yytext); yyterminate(); }
\r?\n { printf("CR?LF "); }

<<EOF>> { printf("--"); yyterminate(); }

%%

void on_STR_ESC_1() {
	char const c = trans_esc_char(*yytext);
	if (c) buffer.putc(c);
	else printf("[Unrecognized escape char |%c|] ", c);
}

void on_STR_ESC_2() {
	char const c = trans_esc_octal(yytext, yyleng);
	if (c) buffer.putc(c);
	else printf("[Unrecognized octal escape literal |%s|] ", yytext);
}

void on_STR_ESC_3() {
	char const c = trans_esc_hex(yytext, yyleng);
	if (c) buffer.putc(c);
	else printf("[Unrecognized hex escape literal |%s|] ", yytext);
}

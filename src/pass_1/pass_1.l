%option nodefault
%option noyywrap

%x _ESC_N
%x _CMT_L _CMT_B
%x _STR _STR_ESC _STR_ESCX

%{

#include <iostream> // cout
#include <string>
#include <stdio.h> // fopen
#include <utils.hpp>

static void on_STR_ESC_1();
static void on_STR_ESC_2();
static void on_STR_ESC_3();

#define E_OK 0
#define E_NEED_ARGS -1
#define E_SRC_NOT_FOUND -2
#define E_DST_EXISTS -3
#define E_SRC_CAN_NOT_OPEN -4

#define E_NOT_IMPLEMENTED -101

%}

%%

"\\"\r?\n { }

"//" { BEGIN(_CMT_L); }
<_CMT_L>"\\"\r?\n { }
<_CMT_L>[^\r\n]* { BEGIN(INITIAL); }
<_CMT_L>[\r\n] { BEGIN(INITIAL); }

"/\*" { BEGIN(_CMT_B); }
<_CMT_B>"\\"\r?\n { }
<_CMT_B>"\*/" { BEGIN(INITIAL); }
<_CMT_B>.|[\r\n] { }

("u8"|"u"|"U"|"L")?\" { BEGIN(_STR); ECHO; }
<_STR>"\\"\r?\n { }
<_STR>[^"\\] { ECHO; }
<_STR>"\"" { BEGIN(INITIAL); ECHO; }
<_STR>"\\" { BEGIN(_STR_ESC); }

<_STR_ESC>\r?\n { BEGIN(_STR); }
<_STR_ESC>['"?\\] { BEGIN(_STR); ECHO; }
<_STR_ESC>[abfnrtv] { BEGIN(_STR); on_STR_ESC_1(); }
<_STR_ESC>x { BEGIN(_STR_ESCX); }
<_STR_ESC>[0-7]{1,3} { BEGIN(_STR); on_STR_ESC_2(); }
<_STR_ESCX>[0-9A-Fa-f]+ { BEGIN(_STR); on_STR_ESC_3(); }

. { printf("\nMystery character |%c|.\n", *yytext); yyterminate(); }
\r?\n { printf("[CR?LF]"); }

<<EOF>> { printf("[END]"); yyterminate(); }

%%

static void on_STR_ESC_1() {
	switch (*yytext) {
		case 'a': /* std::cout << '\a'; */ break;
		case 'b': std::cout << ' '; /* std::cout << '\b'; */ break;
		case 'f': std::cout << ' '; /* std::cout << '\f'; */ break;
		case 'n': std::cout << '\n'; break;
		case 'r': std::cout << ' '; /* std::cout << '\r'; */ break;
		case 't': std::cout << ' '; break;
		case 'v': std::cout << ' '; /* std::cout << '\v'; */ break;
		default: std::cout << "[Unrecognized escape char '" << *yytext << "']"; break;
	}
}

static void on_STR_ESC_2() {
	std::cout << "[Unrecognized octal escape literal '" << yytext << "']";
}

static void on_STR_ESC_3() {
	std::cout << "[Unrecognized hex escape literal '" << yytext << "']";
}

static int main_1(char ** argv) {
	yyin = fopen(argv[1], "rb");
	if (!yyin) {
		std::cout << "SRC could not be opened for input: \"" << argv[1] << "\"; try closing other applications first.";
		return E_SRC_CAN_NOT_OPEN;
	}
	yylex();
	return E_OK;
}

static int main_2(char ** /*argv*/) {
	return E_NOT_IMPLEMENTED;
}

static void print_usage(char ** argv) {
	bool const need_quotes = stringutils::has_space(argv[0]);
	std::string const argv0 = stringutils::quote_if(need_quotes, argv[0]);
	std::cout << "usage: " << argv0 << " SRC [DST]\n";
}

static int validate_args(int argc, char ** argv) {
	if (argc >= 2 && !fileutils::is_file(argv[1])) {
		std::cout << "SRC does not exist: \"" << argv[1] << "\"; need path to C/C++ file for input.\n";
		return E_SRC_NOT_FOUND;
	}
	else if (argc >= 2 && fileutils::is_path(argv[2])) {
		std::cout << "DST already exists: \"" << argv[2] << "\"; manually delete it first.\n";
		return E_DST_EXISTS;
	}
	return E_OK;
}

int main(int argc, char ** argv) {

	int const args_status = validate_args(argc, argv);
	if (E_OK != args_status)
		return args_status;

	if (argc >= 3) {
		return main_2(argv);
	}
	else if (argc >= 2) {
		return main_1(argv);
	}
	else {
		print_usage(argv);
		return E_NEED_ARGS;
	}

	return E_OK;
}

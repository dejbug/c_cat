#include "escapes.hpp"

char trans_esc_char(char c) {
	switch(c) {
		case 'a': return '\a';
		case 'b': return '\b';
		case 'f': return '\f';
		case 'n': return '\n';
		case 'r': return '\r';
		case 't': return '\t';
		case 'v': return '\v';
	}
	return 0;
}

char trans_esc_octal(char * /*c*/, int /*len*/) {
	return 0;
}

char trans_esc_hex(char * /*c*/, int /*len*/) {
	return 0;
}

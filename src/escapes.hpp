#ifndef CAT_ESCAPES_HPP
#define CAT_ESCAPES_HPP

char trans_esc_char(char c);

char trans_esc_octal(char * c, int len);

char trans_esc_hex(char * c, int len);

#endif // !CAT_ESCAPES_HPP

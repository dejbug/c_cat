#ifndef CAT_UTILS_HPP
#define CAT_UTILS_HPP

#include <strsafe.h>
#include <string>

namespace fileutils {

bool file_exists(char const * path);
bool is_path(char const * path);
bool is_file(char const * path);
bool is_dir(char const * path);

} // namespace fileutils

namespace stringutils {

bool has_space(char const * text);
bool has_whitespace(char const * text);
std::string quote_if(bool condition, char const * text, char qc='\"');

} // namespace stringutils

#endif

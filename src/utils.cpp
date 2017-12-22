#include "utils.hpp"
#include <stdio.h>
#include <io.h>
#include <sstream>

bool fileutils::file_exists(char const * path) {
	FILE * handle = fopen(path, "rb");
	if (!handle) return false;
	return fclose(handle), true;
}

bool fileutils::is_path(char const * path) {
	struct _finddata_t fd;
	long const seek_handle = _findfirst(path, &fd);
	return -1 != seek_handle;
}

bool fileutils::is_file(char const * path) {
	struct _finddata_t fd;
	long const seek_handle = _findfirst(path, &fd);
	if (-1 == seek_handle) return false;
	return (_A_SUBDIR & fd.attrib) != _A_SUBDIR;
}

bool fileutils::is_dir(char const * path) {
	struct _finddata_t fd;
	long const seek_handle = _findfirst(path, &fd);
	if (-1 == seek_handle) return false;
	return (_A_SUBDIR & fd.attrib) == _A_SUBDIR;
}

bool stringutils::has_space(char const * text) {
	return NULL != strchr(text, ' ');
}

bool stringutils::has_whitespace(char const * text) {
	return NULL != strpbrk(text, " \f\n\r\t\v");
}

std::string stringutils::quote_if(bool condition, char const * text, char qc) {
	if (condition) {
		std::stringstream ss;
		ss << qc << text << qc;
		return ss.str();
	}
	return text;
}

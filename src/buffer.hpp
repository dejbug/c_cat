#ifndef BUFFER_H
#define BUFFER_H

#include <cstdint>
#include <string>

struct Buffer
{
	size_t const requested_size;
	size_t const allocated_size;
	std::string data;
	size_t pos = 0;

	Buffer(size_t size);
	virtual ~Buffer();

	void reset();
	void putc(char c);
	char * get();
};

#endif

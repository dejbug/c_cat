#include "buffer.hpp"
#include <cassert>
#include <stdexcept>

Buffer::Buffer(size_t size) : requested_size(size), allocated_size(size+1) {
	/// We will add one more char position to the buffer, for
	/// the terminating '\0'. This will also ensure that even
	/// Buffer(0) will allocate a single char.
	size_t const max_size = (size_t) -1;
	assert(requested_size < max_size);
	/// We don't call resize() here, since we'll be using
	/// this like a simple C-type array. I.e. we'll be
	/// setting only data[pos] to '\0', not memset()-ing
	/// the entire buffer.
	data.reserve(allocated_size);
	assert(data.capacity() == allocated_size);
	data[pos = 0] = 0;
}

Buffer::~Buffer() {
	/// Not really necessary.
	data[pos = 0] = 0;
}

void Buffer::reset() {
	data[pos = 0] = 0;
}

void Buffer::putc(char c) {
	if (pos >= requested_size-1)
		throw std::out_of_range("Buffer:putc : pos >= requested_size-1");
	data[pos++] = c;
	assert(pos < allocated_size);
	data[pos] = 0;
}

char * Buffer::get() {
	// assert(pos < allocated_size);
	// data[pos] = 0;
	return &data[0];
}

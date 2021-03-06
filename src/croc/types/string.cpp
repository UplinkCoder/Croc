
#include <functional>

#include "croc/api.h"
#include "croc/types/base.hpp"
#include "croc/util/misc.hpp"
#include "croc/util/str.hpp"
#include "croc/util/utf.hpp"

#define STRING_EXTRA_SIZE(len) (1 + (sizeof(char) * (len)))

namespace croc
{
	namespace
	{
		String* createInternal(VM* vm, crocstr data, std::function<uword(bool&)> getCPLen)
		{
			auto h = data.toHash();

			if(auto s = vm->stringTab.lookup(data, h))
				return *s;

			bool okay;
			auto cpLen = getCPLen(okay);

			if(!okay)
				return nullptr;

			auto ret = ALLOC_OBJSZ_ACYC(vm->mem, String, STRING_EXTRA_SIZE(data.length));
			ret->type = CrocType_String;
			ret->hash = h;
			ret->length = data.length;
			ret->cpLength = cpLen;
			ret->setData(data);
			*vm->stringTab.insert(vm->mem, ret->toDArray()) = ret;
			return ret;
		}
	}

	// Create a new string object. String objects with the same data are reused. Thus,
	// if two string objects are identical, they are also equal.
	String* String::create(VM* vm, crocstr data)
	{
		return createInternal(vm, data, [&](bool& okay)
		{
			uword cpLen;

			if(verifyUtf8(data, cpLen) != UtfError_OK)
				croc_eh_throwStd(*vm->curThread, "UnicodeError", "Invalid UTF-8 sequence");

			okay = true;
			return cpLen;
		});
	}

	String* String::createUnverified(VM* vm, crocstr data, uword cpLen)
	{
		return createInternal(vm, data, [&](bool& okay) { okay = true; return cpLen; });
	}

	String* String::tryCreate(VM* vm, crocstr data)
	{
		return createInternal(vm, data, [&](bool& okay)
		{
			uword cpLen;
			okay = verifyUtf8(data, cpLen) == UtfError_OK;
			return cpLen;
		});
	}

	// Free a string object.
	void String::free(VM* vm, String* s)
	{
		bool b = vm->stringTab.remove(s->toDArray());
		assert(b);
#ifdef NDEBUG
		(void)b;
#endif
		FREE_OBJ(vm->mem, String, s);
	}

	// Compare two string objects.
	crocint String::compare(String* other)
	{
		return this->toDArray().cmp(other->toDArray());
	}

	// See if the string contains the given substring.
	bool String::contains(crocstr sub)
	{
		return strLocate(this->toDArray(), sub) != this->length;
	}

	// The slice indices are in codepoints, not byte indices.
	// And these indices better be good.
	String* String::slice(VM* vm, uword lo, uword hi)
	{
		return createUnverified(vm, utf8Slice(this->toDArray(), lo, hi), hi - lo);
	}
}
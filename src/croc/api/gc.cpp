
#include <string.h>

#include "croc/api.h"
#include "croc/base/gc.hpp"
#include "croc/internal/apichecks.hpp"
#include "croc/internal/stack.hpp"
#include "croc/types.hpp"

namespace croc
{
	namespace
	{
		uword gcInternal(Thread* t, bool fullCollect)
		{
			auto vm = t->vm;

			if(vm->mem.gcDisabled > 0)
				return 0;

			auto beforeSize = vm->mem.totalBytes;
			gcCycle(vm, fullCollect ? GCCycleType_Full : GCCycleType_Normal);
			// runFinalizers(t); TODO:api

			vm->stringTab.minimize(vm->mem);
			vm->weakrefTab.minimize(vm->mem);

			auto ret = beforeSize > vm->mem.totalBytes ? beforeSize - vm->mem.totalBytes : 0; // This is.. possible? TODO: figure out how.

			croc_vm_pushRegistry(*t);

			// TODO:api
			// field(t, -1, "gc.postGCCallbacks");

			// foreach(word v; foreachLoop(t, 1))
			// {
			// 	dup(t, v);
			// 	pushNull(t);
			// 	call(t, -2, 0);
			// }

			croc_popTop(*t);

			return ret;
		}
	}

extern "C"
{
	uword_t croc_gc_maybeCollect(CrocThread* t_)
	{
		auto t = Thread::from(t_);

		if(t->vm->mem.gcDisabled > 0)
			return 0;

		if(t->vm->mem.couldUseGC())
			return croc_gc_collect(t_);
		else
			return 0;
	}

	uword_t croc_gc_collect(CrocThread* t_)
	{
		return gcInternal(Thread::from(t_), false);
	}

	uword_t croc_gc_collectFull(CrocThread* t_)
	{
		return gcInternal(Thread::from(t_), true);
	}

	uword_t croc_gc_setLimit(CrocThread* t_, const char* type, uword_t lim)
	{
		auto t = Thread::from(t_);
		uword_t* p;

		if(strncmp(type, "nurseryLimit",         30) == 0) p = &t->vm->mem.nurseryLimit;       else
		if(strncmp(type, "metadataLimit",        30) == 0) p = &t->vm->mem.metadataLimit;      else
		if(strncmp(type, "nurserySizeCutoff",    30) == 0) p = &t->vm->mem.nurserySizeCutoff;  else
		if(strncmp(type, "cycleCollectInterval", 30) == 0) p = &t->vm->mem.nextCycleCollect;   else
		if(strncmp(type, "cycleMetadataLimit",   30) == 0) p = &t->vm->mem.cycleMetadataLimit; else
		croc_eh_throwStd(t_, "ValueError", "Invalid limit type '{}'", type);

		auto ret = *p;
		*p = lim;
		return ret;
	}

	uword_t croc_gc_getLimit(CrocThread* t_, const char* type)
	{
		auto t = Thread::from(t_);

		if(strncmp(type, "nurseryLimit",         30) == 0) return t->vm->mem.nurseryLimit;       else
		if(strncmp(type, "metadataLimit",        30) == 0) return t->vm->mem.metadataLimit;      else
		if(strncmp(type, "nurserySizeCutoff",    30) == 0) return t->vm->mem.nurserySizeCutoff;  else
		if(strncmp(type, "cycleCollectInterval", 30) == 0) return t->vm->mem.nextCycleCollect;   else
		if(strncmp(type, "cycleMetadataLimit",   30) == 0) return t->vm->mem.cycleMetadataLimit; else
		croc_eh_throwStd(t_, "ValueError", "Invalid limit type '{}'", type);

		assert(false);
	}
}
}
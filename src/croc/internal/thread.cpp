
#include "croc/api.h"
#include "croc/internal/calls.hpp"
#include "croc/internal/eh.hpp"
#include "croc/internal/stack.hpp"
#include "croc/internal/thread.hpp"
#include "croc/types.hpp"

namespace croc
{
	void yieldImpl(Thread* t, AbsStack firstValue, word numValues, word expectedResults)
	{
		auto ar = pushAR(t);

		assert(t->arIndex > 1);
		*ar = t->actRecs[t->arIndex - 2];

		ar->func = nullptr;
		ar->returnSlot = firstValue;
		ar->expectedResults = expectedResults;
		ar->firstResult = 0;
		ar->numResults = 0;

		if(numValues == -1)
			t->numYields = t->stackIndex - firstValue;
		else
		{
			t->stackIndex = firstValue + numValues;
			t->numYields = numValues;
		}

		t->state = CrocThreadState_Suspended;
	}

	void resume(Thread* t, Thread* from, AbsStack slot, uword expectedResults, uword numParams)
	{
		// Set up AR on the calling thread, which is used to get yielded values from the resumed thread
		auto ar = pushAR(from);
		ar->base = slot;
		ar->savedTop = from->stackIndex;
		ar->vargBase = slot;
		ar->returnSlot = slot;
		ar->func = nullptr;
		ar->pc = nullptr;
		ar->expectedResults = expectedResults;
		ar->numTailcalls = 0;
		ar->firstResult = 0;
		ar->numResults = 0;
		ar->unwindCounter = 0;
		ar->unwindReturn = nullptr;
		from->stackIndex = slot;

		auto savedState = from->state;
		from->state = CrocThreadState_Waiting;
		t->threadThatResumedThis = from;

		auto ehSlot = from->stackIndex - 1;
		assert(ehSlot > 0);

		auto failed = tryCode(from, ehSlot, [&t, &from, &slot, &numParams]
		{
			if(t->state == CrocThreadState_Initial)
			{
				checkStack(t, cast(AbsStack)(numParams + 2));
				t->stack[1] = Value::from(t->coroFunc);
				t->stack.slicea(2, 2 + numParams, from->stack.slice(slot + 1, slot + 1 + numParams));
				t->stackIndex += numParams;

				// TODO:api
				// auto result = callPrologue(t, cast(AbsStack)1, -1, numParams);
				// assert(result == true, "resume callPrologue must return true");
			}
			else
			{
				// Get rid of 'this'
				numParams--;
				saveResults(t, from, slot + 2, numParams);
				callEpilogue(t);
			}

			// TODO:api
			// execute(t);
		});

		// TODO:halt
		// catch(CrocHaltException e)
		// {
		// 	assert(t.arIndex == 0);
		// 	assert(t.upvalHead is null);
		// 	assert(t.resultIndex == 0);
		// 	assert(t.trIndex == 0);
		// 	assert(t.nativeCallDepth == 0);
		// }

		from->state = savedState;
		from->vm->curThread = from;

		if(failed)
		{
			continueTraceback(from, *getValue(from, ehSlot));
			croc_eh_rethrow(*from);
		}

		// Move the values from the yielded thread's stack to the calling thread's stack
		saveResults(from, t, t->stackIndex - t->numYields, t->numYields);
		t->stackIndex -= t->numYields;
		callEpilogue(from);
	}
}
cmake_minimum_required(VERSION 2.8)

set(CROC_ALL_ADDONS "false" CACHE BOOL "Enable this to compile in all addons.")

set(CROC_DEVIL_ADDON  "${CROC_ALL_ADDONS}" CACHE BOOL "Compiles in the DevIL addon.")
set(CROC_GLFW_ADDON   "${CROC_ALL_ADDONS}" CACHE BOOL "Compiles in the GLFW addon.")
set(CROC_NET_ADDON    "${CROC_ALL_ADDONS}" CACHE BOOL "Compiles in the net addon.")
set(CROC_PCRE_ADDON   "${CROC_ALL_ADDONS}" CACHE BOOL "Compiles in the libPCRE addon.")
set(CROC_OPENAL_ADDON "${CROC_ALL_ADDONS}" CACHE BOOL "Compiles in the OpenAL addon.")
set(CROC_IMGUI_ADDON  "${CROC_ALL_ADDONS}" CACHE BOOL "Compiles in the ImGui addon.")

set(CROC_BUILD_SHARED "false" CACHE BOOL "If enabled, builds Croc as a shared library; otherwise builds it as a static library.")

if(NOT DEFINED CROC_BUILD_BITS)
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(CROC_BUILD_BITS 64)
	else()
		set(CROC_BUILD_BITS 32)
	endif()
endif()

set(croc_SRC
	croc/addons/all.hpp
	croc/addons/al.cpp
	croc/addons/al.hpp
	croc/addons/glfw.cpp
	croc/addons/glfw.hpp
	croc/addons/il.cpp
	croc/addons/il.hpp
	croc/addons/imgui.cpp
	croc/addons/pcre.cpp
	croc/api/apichecks.hpp
	croc/api/array.cpp
	croc/api/basic.cpp
	croc/api/calls.cpp
	croc/api/class.cpp
	croc/api/compiler.cpp
	croc/api/debug.cpp
	croc/api/eh.cpp
	croc/api/funcdef.cpp
	croc/api/function.cpp
	croc/api/gc.cpp
	croc/api/mem.cpp
	croc/api/memblock.cpp
	croc/api/nativeref.cpp
	croc/api/namespace.cpp
	croc/api/reflection.cpp
	croc/api/stack.cpp
	croc/api/table.cpp
	croc/api/thread.cpp
	croc/api/typequeries.cpp
	croc/api/valuetypes.cpp
	croc/api/variables.cpp
	croc/api/vm.cpp
	croc/api/weakref.cpp
	croc/base/darray.hpp
	croc/base/deque.cpp
	croc/base/deque.hpp
	croc/base/gc.cpp
	croc/base/gc.hpp
	croc/base/gcobject.hpp
	croc/base/hash.hpp
	croc/base/leakdetector.cpp
	croc/base/leakdetector.hpp
	croc/base/memory.cpp
	croc/base/memory.hpp
	croc/base/metamethods.cpp
	croc/base/metamethods.hpp
	croc/base/opcodes.cpp
	croc/base/opcodes.hpp
	croc/base/sanity.hpp
	croc/base/writebarrier.cpp
	croc/base/writebarrier.hpp
	croc/compiler/ast.cpp
	croc/compiler/ast.hpp
	croc/compiler/astvisitor.cpp
	croc/compiler/astvisitor.hpp
	croc/compiler/builder.cpp
	croc/compiler/builder.hpp
	croc/compiler/codegen.cpp
	croc/compiler/codegen.hpp
	croc/compiler/docgen.cpp
	croc/compiler/docgen.hpp
	croc/compiler/docparser.cpp
	croc/compiler/docparser.hpp
	croc/compiler/lexer.cpp
	croc/compiler/lexer.hpp
	croc/compiler/parser.cpp
	croc/compiler/parser.hpp
	croc/compiler/semantic.cpp
	croc/compiler/semantic.hpp
	croc/compiler/types.hpp
	croc/compiler/types.cpp
	croc/ex/common.cpp
	croc/ex/compilation.cpp
	croc/ex/docs.cpp
	croc/ex/imports.cpp
	croc/ex/library.cpp
	croc/ex/paramchecks.cpp
	croc/ex/strbuffer.cpp
	croc/ext/jhash.cpp
	croc/ext/jhash.hpp
	croc/internal/basic.cpp
	croc/internal/basic.hpp
	croc/internal/calls.cpp
	croc/internal/calls.hpp
	croc/internal/class.cpp
	croc/internal/class.hpp
	croc/internal/debug.cpp
	croc/internal/debug.hpp
	croc/internal/eh.cpp
	croc/internal/eh.hpp
	croc/internal/gc.cpp
	croc/internal/gc.hpp
	croc/internal/interpreter.cpp
	croc/internal/interpreter.hpp
	croc/internal/stack.cpp
	croc/internal/stack.hpp
	croc/internal/thread.cpp
	croc/internal/thread.hpp
	croc/internal/variables.cpp
	croc/internal/variables.hpp
	croc/stdlib/all.hpp
	croc/stdlib/array.cpp
	croc/stdlib/ascii.cpp
	croc/stdlib/compiler.cpp
	croc/stdlib/console.cpp
	croc/stdlib/debug.cpp
	croc/stdlib/docs.cpp
	croc/stdlib/doctools.cpp
	croc/stdlib/env.cpp
	croc/stdlib/exceptions.cpp
	croc/stdlib/file.cpp
	croc/stdlib/gc.cpp
	croc/stdlib/hash.cpp
	croc/stdlib/helpers/format.cpp
	croc/stdlib/helpers/format.hpp
	croc/stdlib/helpers/json.cpp
	croc/stdlib/helpers/json.hpp
	croc/stdlib/helpers/oscompat.cpp
	croc/stdlib/helpers/oscompat.hpp
	croc/stdlib/helpers/register.cpp
	croc/stdlib/helpers/register.hpp
	croc/stdlib/json.cpp
	croc/stdlib/math.cpp
	croc/stdlib/memblock.cpp
	croc/stdlib/misc.cpp
	croc/stdlib/misc_vector.cpp
	croc/stdlib/modules.cpp
	croc/stdlib/object.cpp
	croc/stdlib/os.cpp
	croc/stdlib/path.cpp
	croc/stdlib/repl.cpp
	croc/stdlib/serialization.cpp
	croc/stdlib/stream.cpp
	croc/stdlib/string.cpp
	croc/stdlib/string_stringbuffer.cpp
	croc/stdlib/text.cpp
	croc/stdlib/time.cpp
	croc/stdlib/thread.cpp
	croc/types/array.cpp
	croc/types/base.cpp
	croc/types/base.hpp
	croc/types/class.cpp
	croc/types/funcdef.cpp
	croc/types/function.cpp
	croc/types/instance.cpp
	croc/types/memblock.cpp
	croc/types/namespace.cpp
	croc/types/string.cpp
	croc/types/table.cpp
	croc/types/thread.cpp
	croc/types/weakref.cpp
	croc/util/array.hpp
	croc/util/misc.cpp
	croc/util/misc.hpp
	croc/util/rng.cpp
	croc/util/rng.hpp
	croc/util/str.cpp
	croc/util/str.hpp
	croc/util/utf.cpp
	croc/util/utf.hpp
)

if(CROC_GLFW_ADDON)
	set(croc_SRC ${croc_SRC}
		croc/addons/gl.cpp
		croc/addons/gl.hpp
		croc/ext/glad.cpp
		croc/ext/glad/glad.hpp
		croc/ext/KHR/khrplatform.hpp
	)
endif()

set(croc_CROCSRC
	croc/stdlib/console.croc
	croc/stdlib/docs.croc
	croc/stdlib/doctools_output.croc
	croc/stdlib/doctools_console.croc
	croc/stdlib/doctools_trac.croc
	croc/stdlib/hash_weaktables.croc
	croc/stdlib/modules.croc
	croc/stdlib/repl.croc
	croc/stdlib/serialization.croc
	croc/stdlib/stream.croc
	croc/stdlib/text.croc
)

set(croc_API
	croc/api.h
	croc/apifuncs.h
	croc/apitypes.h
	croc/apiex.h
)

set(croc_CROCSRC_CONVERTED)

add_executable(convert croc/ext/convert.cpp)

foreach(crocsrc ${croc_CROCSRC})
	set(infile "${CMAKE_CURRENT_SOURCE_DIR}/${crocsrc}")
	set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${crocsrc}.hpp")

	if(MINGW)
		# CMake bug 5939: http://www.cmake.org/Bug/view.php?id=5939
		string(REGEX REPLACE "/" "\\\\" infileNative "${infile}")
		string(REGEX REPLACE "/" "\\\\" outfileNative "${outfile}")
	else()
		set(infileNative "${infile}")
		set(outfileNative "${outfile}")
	endif()

	get_filename_component(outpath "${outfileNative}" PATH)
	# message("outpath: ${outpath}")
	file(MAKE_DIRECTORY "${outpath}")

	# message("in: ${infileNative}, out: ${outfileNative}")
	add_custom_command(
		OUTPUT ${outfile}
		COMMAND convert ${infileNative} > ${outfileNative}
		DEPENDS ${infile} convert
		COMMENT "Converting ${infileNative}, output ${outfileNative}"
	)
	list(APPEND croc_CROCSRC_CONVERTED "${outfile}")
endforeach()

include_directories("${CMAKE_CURRENT_BINARY_DIR}")
add_custom_target(ConvertCrocFiles ALL DEPENDS ${croc_CROCSRC_CONVERTED})

set(croc_ALLSRC
	${croc_SRC}
	${croc_API}
	${croc_CROCSRC_CONVERTED}
)

if(CMAKE_COMPILER_IS_GNUCXX)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -pedantic-errors -Wall -Wextra -Werror -fno-exceptions")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmax-errors=2 -m${CROC_BUILD_BITS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DCROC_BUILTIN_DOCS=1 -DCROC_BUILD_BITS=${CROC_BUILD_BITS}")

	if(CROC_BUILD_SHARED AND WIN32)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DCROCAPI=__declspec(dllexport)")
	else()
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DCROCAPI=extern")
	endif()

	if(CROC_BUILD_BITS EQUAL 32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xlinker \"-melf_i386\" -Xlinker \"--oformat=elf32-i386\"")
	endif()

	if(MINGW)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-pedantic-ms-format")
	endif()

	set(CROC_ADDON_FLAGS "")

	# This should proooooobably be done using a CMake-generated config header
	if(CROC_DEVIL_ADDON)
		set(CROC_ADDON_FLAGS "${CROC_ADDON_FLAGS} -DCROC_DEVIL_ADDON")
	endif()
	if(CROC_GLFW_ADDON)
		set(CROC_ADDON_FLAGS "${CROC_ADDON_FLAGS} -DCROC_GLFW_ADDON")
	endif()
	if(CROC_NET_ADDON)
		set(CROC_ADDON_FLAGS "${CROC_ADDON_FLAGS} -DCROC_NET_ADDON")
	endif()
	if(CROC_PCRE_ADDON)
		set(CROC_ADDON_FLAGS "${CROC_ADDON_FLAGS} -DCROC_PCRE_ADDON")
	endif()
	if(CROC_OPENAL_ADDON)
		set(CROC_ADDON_FLAGS "${CROC_ADDON_FLAGS} -DCROC_OPENAL_ADDON")
	endif()
	if(CROC_IMGUI_ADDON)
		set(CROC_ADDON_FLAGS "${CROC_ADDON_FLAGS} -DCROC_IMGUI_ADDON")
	endif()

	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CROC_ADDON_FLAGS}")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DCROC_STOMP_MEMORY=1 -DCROC_LEAK_DETECTOR=1")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-rtti -O3")
elseif(MSVC)
	message(FATAL_ERROR "VC not supported yet")
else()
	message(FATAL_ERROR "Dunno what compiler you have but I don't support it")
endif()

if(CROC_BUILD_SHARED)
	add_library(croc SHARED ${croc_ALLSRC})
else()
	add_library(croc STATIC ${croc_ALLSRC})
endif()

add_dependencies(croc ConvertCrocFiles)

if(CROC_IMGUI_ADDON)
	add_subdirectory(croc/ext/imgui)
	add_dependencies(croc imgui)
	target_link_libraries(croc imgui)
endif()
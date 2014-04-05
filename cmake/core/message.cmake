function(message)
	cmake_parse_arguments("" "POP_AFTER;DEBUG;INFO;FORMAT;JSON;PUSH;POP;POP_LEVEL" "PUSH_LEVEL;LEVEL;ADD_LISTENER;REMOVE_LISTENER" "" ${ARGN})


	global_get(__message_listeners)
	if(_ADD_LISTENER)	
		ref_isvalid(${_ADD_LISTENER} isref)
		if(NOT isref)
			list_new(ref)
			set(${_ADD_LISTENER} ${ref} PARENT_SCOPE)
			set(_ADD_LISTENER ${ref})
		endif()

		global_append(__message_listeners ${_ADD_LISTENER})
	endif()
	if(_REMOVE_LISTENER)
		list(REMOVE_ITEM __message_listeners ${_REMOVE_LISTENER})
		global_set(__message_listeners ${__message_listeners})
	endif()

	global_get(__message_indent_level)
	if(NOT __message_indent_level)
		set(__message_indent_level 0)
	endif()
	if(_PUSH)
		math(EXPR __message_indent_level "${__message_indent_level} + 1")	
		global_set(__message_indent_level ${__message_indent_level})
	endif()
	if(_POP)
		math(EXPR __message_indent_level "${__message_indent_level} - 1")	
		global_set(__message_indent_level ${__message_indent_level})	
	endif()


	set(indent)
	foreach(i RANGE ${__message_indent_level})
		set(indent "${indent}  ")
	endforeach()
	if(_POP_AFTER)
		math(EXPR __message_indent_level "${__message_indent_level} - 1")	
		global_set(__message_indent_level ${__message_indent_level})	
	endif()
	string(SUBSTRING "${indent}" 2 -1 indent)
	if(NOT _UNPARSED_ARGUMENTS)
		return()
	endif()


	if(_DEBUG)
		if(NOT _LEVEL)
			set(_LEVEL 3)
		endif()
		set(_UNPARSED_ARGUMENTS STATUS ${_UNPARSED_ARGUMENTS})
	endif()
	if(_INFO)
		if(NOT _LEVEL)
			set(_LEVEL 2)
		endif()
		set(_UNPARSED_ARGUMENTS STATUS ${_UNPARSED_ARGUMENTS})
	endif()
	if(NOT _LEVEL)
		set(_LEVEL 0)
	endif()

	if(NOT MESSAGE_LEVEL)
		set(MESSAGE_LEVEL 3)
	endif()

	list(GET _UNPARSED_ARGUMENTS 0 modifier)
	if(${modifier} MATCHES "FATAL_ERROR|STATUS|AUTHOR_WARNING|WARNING|SEND_ERROR")
		list(REMOVE_AT _UNPARSED_ARGUMENTS 0)
	else()
		set(modifier)
	endif()


	set(msg "${_UNPARSED_ARGUMENTS}")
	if(_FORMAT)
		map_format(msg "${msg}")
	endif()

	if(_JSON)
		json_serialize(res "${msg}" INDENTED)
		set(msg ${res})
	endif()

	if(NOT MESSAGE_DEPTH )
		set(MESSAGE_DEPTH -1)
	endif()

	if(NOT msg)
		return()
	endif()

	foreach(listener ${__message_listeners})
		ref_append(${listener} ${modifier} "${msg}")

	endforeach()

	if(_LEVEL GREATER MESSAGE_LEVEL)
		return()
	endif()
	if(MESSAGE_QUIET)
		return()
	endif()
	# check if deep message are to be ignored
	if(NOT MESSAGE_DEPTH LESS 0)
		if(${__message_indent_level} GREATER ${MESSAGE_DEPTH})
			return()
		endif()
	endif()
	_message(${modifier} "${indent}" "${msg}")


	

endfunction()
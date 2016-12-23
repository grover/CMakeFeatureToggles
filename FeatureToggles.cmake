#
# The MIT License (MIT)
#
# Copyright (c)
#   2016 Michael Fröhlich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

set(FEATURE_TOGGLES_FILE ${CMAKE_CURRENT_LIST_FILE})
cmake_policy(SET CMP0012 NEW)

#
# Adds a feature toggle definition to a target.
#
# Toggles can be of any type, booleans being the obvious typical use. However
# numerical values are also supported.
#
# TARGET - the name of the target as specified in add_library, add_executable or similar
# toggle - the name of the toggle. It will automatically be prepended with TARGET_FEATURE_
# description - the description of the toggle
# default_value - the default value of the toggle.
#
function(add_feature_toggle TARGET toggle description default_value)
  string(TOUPPER ${TARGET} UTARGET)
  set(${UTARGET}_FEATURE_${toggle} ${default_value} CACHE STRING ${description})

  get_target_property(TFEATURE_TOGGLES ${TARGET} FEATURE_TOGGLES)
  if (NOT TFEATURE_TOGGLES)
    set(TFEATURE_TOGGLES ${UTARGET}_FEATURE_${toggle})
  else()
    set(TFEATURE_TOGGLES "${TFEATURE_TOGGLES};${UTARGET}_FEATURE_${toggle}")
  endif()

  set_target_properties(${TARGET} PROPERTIES FEATURE_TOGGLES "${TFEATURE_TOGGLES}")
endfunction()

#
# Configures the feature toggle header to generate for a target.
#
# TARGET - the target to generate the header for
# HEADER_FILE - the path of the header file to generate
#
function(set_feature_toggle_header TARGET HEADER_FILE)
  get_target_property(TFEATURE_TOGGLES ${TARGET} FEATURE_TOGGLES)
  if (NOT TFEATURE_TOGGLES)
    message(FATAL_ERROR "Feature toggles not defined.")
  endif()

  set(FEATURE_STATE "")
  foreach (_variable_name ${TFEATURE_TOGGLES})
    if(${_variable_name})
      set(FEATURE_STATE "${FEATURE_STATE};-D${_variable_name}=${${_variable_name}}")
    endif()
  endforeach()

  add_custom_command(OUTPUT ${HEADER_FILE}
    COMMAND "${CMAKE_COMMAND}" -DFEATURE_TOGGLE_GENERATE=TRUE -DTARGET="${TARGET}" -DHEADER_FILE="${CMAKE_CURRENT_LIST_DIR}/${HEADER_FILE}" -DFEATURE_TOGGLES="${TFEATURE_TOGGLES}" ${FEATURE_STATE} -P "${FEATURE_TOGGLES_FILE}")
endfunction()

if (${FEATURE_TOGGLE_GENERATE})
  string(TOUPPER ${TARGET} UTARGET)

  string(REPLACE " " ";" FEATURE_TOGGLES_LIST ${FEATURE_TOGGLES})
  list(SORT FEATURE_TOGGLES_LIST)

  set(CONFIG_FILE_HEADER "")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER}/**\n")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER} * Automatically generated configuration header file from CMake options\n")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER} *\n")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER} * The license of the project that created this configuration file\n")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER} * applies.\n")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER} *\n")
  set(CONFIG_FILE_HEADER "${CONFIG_FILE_HEADER} */\n\n")
  
  set(_file_contents "${CONFIG_FILE_HEADER}")
  set(_file_contents "${_file_contents}#ifndef ${UTARGET}_CONFIG_H\n")
  set(_file_contents "${_file_contents}#define ${UTARGET}_CONFIG_H\n\n")

  foreach (_variable_name ${FEATURE_TOGGLES_LIST})
    if ("${_variable_name}" STREQUAL "ON")
      set(_file_contents "${_file_contents}#define ${_variable_name} 1\n")
    elseif (${_variable_name})
      set(_file_contents "${_file_contents}#define ${_variable_name} ${${_variable_name}}\n")
    else()
      set(_file_contents "${_file_contents}#undef ${_variable_name}\n")
    endif()
  endforeach ()

  set(_file_contents "${_file_contents}\n#endif /* ${UTARGET}_CONFIG_H */\n")

  file(WRITE "${CMAKE_BINARY_DIR}/${UTARGET}_config.h.tmp" "${_file_contents}")
	    execute_process(COMMAND ${CMAKE_COMMAND}
	        -E copy_if_different
	        "${CMAKE_BINARY_DIR}/${UTARGET}_config.h.tmp"
	        "${HEADER_FILE}"
  )
  file(REMOVE "${CMAKE_BINARY_DIR}/${UTARGET}_config.h.tmp")
endif()

# Applies external/patches/*.patch to a fetched source tree, run as
# FetchContent's PATCH_COMMAND: cmake -DPATCH_DIR=... -P apply_patches.cmake
# in the source directory. Idempotent, since the patch step can run again on
# a re-configure: a patch that already reverse-applies is skipped.
file(GLOB patches "${PATCH_DIR}/*.patch")
list(SORT patches)
find_package(Git REQUIRED QUIET)
# The sdist's sources have no .git: stop git finding an enclosing repository
# (or a stray .git file), which would make it skip or refuse the patch.
get_filename_component(parent "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY)
set(ENV{GIT_CEILING_DIRECTORIES} "${parent}")
foreach(patch IN LISTS patches)
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" apply --reverse --check "${patch}"
    RESULT_VARIABLE already OUTPUT_QUIET ERROR_QUIET)
  if(already EQUAL 0)
    continue()
  endif()
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" apply "${patch}" RESULT_VARIABLE failed)
  if(failed)
    message(FATAL_ERROR "Could not apply ${patch}")
  endif()
  message(STATUS "Applied ${patch}")
endforeach()

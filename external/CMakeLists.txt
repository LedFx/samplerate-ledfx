include(FetchContent)

# libsamplerate
set(BUILD_TESTING OFF CACHE BOOL "Disable libsamplerate test build")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Tracks master: the newest release, 0.2.2, is from 2021. Since then master
# has SSE2 lrint() on x86-64 (faster, same output) and CMake fixes, among them
# a minimum version CMake 4 accepts. Renovate bumps the commit; move back to a
# tag once a release includes these.
set(LIBSAMPLERATE_COMMIT 0844c208f683527c08ea8a80acc13b398aa9c8bf) # master
# The sdist ships this commit's sources (setup.py), so building it needs no
# network (piwheels builds offline). A git checkout clones them.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/libsamplerate/CMakeLists.txt)
  set(_libsamplerate_source URL ${CMAKE_CURRENT_SOURCE_DIR}/libsamplerate)
else()
  set(_libsamplerate_source
      GIT_REPOSITORY https://github.com/libsndfile/libsamplerate
      GIT_TAG ${LIBSAMPLERATE_COMMIT})
endif()
FetchContent_Declare(
  libsamplerate
  ${_libsamplerate_source}
  # Fixes from upstream PRs that are not merged yet; see each patch's header.
  PATCH_COMMAND ${CMAKE_COMMAND} -DPATCH_DIR=${CMAKE_CURRENT_SOURCE_DIR}/patches
                -P ${CMAKE_CURRENT_SOURCE_DIR}/apply_patches.cmake
)
string(SUBSTRING "${LIBSAMPLERATE_COMMIT}" 0 7 _libsamplerate_short)
set(LIBSAMPLERATE_VERSION "0.2.2+git.${_libsamplerate_short}" CACHE STRING "libsamplerate version" FORCE)

FetchContent_MakeAvailable(libsamplerate)

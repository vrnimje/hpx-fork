include(FetchContent)

FetchContent_Declare(
    tracy
    GIT_REPOSITORY https://github.com/wolfpld/tracy .git
    GIT_TAG master
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
)

FetchContent_MakeAvailable(tracy)
include_directories("${CMAKE_BINARY_DIR}/_deps/tracy-src/public/tracy")

set(TracyClient_DIR
      "${CMAKE_BINARY_DIR}/_deps/tracy-build/"
      CACHE INTERNAL ""
)
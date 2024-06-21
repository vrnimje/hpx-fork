# Copyright (c) 2020 ETH Zurich
# Copyright (c) 2017 John Biddiscombe
#
# SPDX-License-Identifier: BSL-1.0
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

# This is a dummy file to trigger the upload of the perftests reports

# set(CTEST_TEST_TIMEOUT 300)
# set(CTEST_BUILD_PARALLELISM 20)
# set(CTEST_TEST_PARALLELISM 4)
set(CTEST_CMAKE_GENERATOR Ninja)
set(CTEST_SITE "verve")
set(CTEST_UPDATE_COMMAND "git")
set(CTEST_BUILD_NAME "Linux, C++17")
# set(CTEST_UPDATE_VERSION_ONLY "ON")
# set(CTEST_SUBMIT_RETRY_COUNT 5)
# set(CTEST_SUBMIT_RETRY_DELAY 60)

ctest_start(Experimental TRACK "${CTEST_TRACK}")

# ctest_update()
# ctest_submit(
#   PARTS Update
#   BUILD_ID __ctest_build_id
#   RETURN_VALUE __update_result
# )

set(CTEST_CONFIGURE_COMMAND
    "${CTEST_CONFIGURE_COMMAND} -DHPX_WITH_NANOBENCH=ON"
)

ctest_configure()
ctest_submit(
  PARTS Configure
  BUILD_ID __ctest_build_id
  RETURN_VALUE __configure_result
)
if(NOT CTEST_BUILD_ID AND __ctest_build_id)
  set(CTEST_BUILD_ID ${__ctest_build_id})
endif()
set(ctest_submission_result ${ctest_submission_result} "Configure: "
                            ${__configure_result} "\n"
)

set(benchmarks
  minmax_element_performance
  small_vector_benchmark
  future_overhead_report
)

foreach(benchmark ${benchmarks})
  ctest_build(TARGET ${benchmark}_cdash_results FLAGS)
endforeach()

ctest_submit(
  PARTS Build
  BUILD_ID __ctest_build_id
  RETURN_VALUE __build_result
)
if(NOT CTEST_BUILD_ID AND __ctest_build_id)
  set(CTEST_BUILD_ID ${__ctest_build_id})
endif()
set(ctest_submission_result ${ctest_submission_result} "Build: "
                            ${__build_result} "\n"
)

set(bench_regex_list "")

foreach(benchmark ${benchmarks})
  set(bench_regex_list ${bench_regex_list} ${benchmark}_perftest)
endforeach()

string(JOIN "|" bench_regex ${bench_regex_list})

ctest_test(INCLUDE ${bench_regex})
ctest_submit(
  PARTS Test
  BUILD_ID __ctest_build_id
  RETURN_VALUE __test_result
)

if(NOT CTEST_BUILD_ID AND __ctest_build_id)
  set(CTEST_BUILD_ID ${__ctest_build_id})
endif()
set(ctest_submission_result ${ctest_submission_result} "Tests: "
                            ${__test_result} "\n"
)
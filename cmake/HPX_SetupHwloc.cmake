# Copyright (c) 2007-2019 Hartmut Kaiser
# Copyright (c) 2011-2014 Thomas Heller
# Copyright (c) 2007-2008 Chirag Dekate
# Copyright (c)      2011 Bryce Lelbach
# Copyright (c)      2011 Vinay C Amatya
# Copyright (c)      2013 Jeroen Habraken
# Copyright (c) 2014-2016 Andreas Schaefer
# Copyright (c) 2017      Abhimanyu Rawat
# Copyright (c) 2017      Google
# Copyright (c) 2017      Taeguk Kwon
#
# SPDX-License-Identifier: BSL-1.0
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

if(HPX_WITH_FETCH_HWLOC)
  hpx_info("System: ${CMAKE_SYSTEM_NAME}")
  set(HWLOC_VERSION "2.9")
  set(HWLOC_RELEASE "2.9.3")
  hpx_info(
    "HPX_WITH_FETCH_HWLOC=${HPX_WITH_FETCH_HWLOC}, Hwloc v${HWLOC_RELEASE} will be fetched using CMake's FetchContent"
  )
  if(UNIX)
    include(FetchContent)
    fetchcontent_declare(
      HWLoc
      URL https://download.open-mpi.org/release/hwloc/v${HWLOC_VERSION}/hwloc-${HWLOC_RELEASE}.tar.gz
      TLS_VERIFY true
    )
    if(NOT HWLoc_POPULATED)
      fetchcontent_populate(HWLoc)
      execute_process(
        COMMAND
          sh -c
          "cd ${CMAKE_BINARY_DIR}/_deps/hwloc-src && ./configure --prefix=${CMAKE_BINARY_DIR}/_deps/hwloc-installed && make -j && make install"
      )
    endif()
    set(HWLOC_ROOT "${CMAKE_BINARY_DIR}/_deps/hwloc-installed")
  elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    fetchcontent_declare(
      HWLoc
      URL https://download.open-mpi.org/release/hwloc/v${HWLOC_VERSION}/hwloc-win64-build-${HWLOC_RELEASE}.zip
      TLS_VERIFY true
    )
    fetchcontent_populate(HWLoc)
    set(HWLOC_ROOT
        "${CMAKE_BINARY_DIR}/_deps/hwloc-src"
        CACHE INTERNAL ""
    )
    set(Hwloc_INCLUDE_DIR
        ${HWLOC_ROOT}/include
        CACHE INTERNAL ""
    )
    add_library(HWLoc MODULE)
    add_custom_command(TARGET HWLoc POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${HWLOC_ROOT}/bin/libhwloc-15.dll"
        ${CMAKE_BINARY_DIR}
    )
  else()
    fetchcontent_declare(
      HWLoc
      URL https://download.open-mpi.org/release/hwloc/v${HWLOC_VERSION}/hwloc-win32-build-${HWLOC_RELEASE}.zip
      TLS_VERIFY true
    )
    fetchcontent_populate(HWLoc)
    set(HWLOC_ROOT
        "${CMAKE_BINARY_DIR}/_deps/hwloc-src"
        CACHE INTERNAL ""
    )
    set(Hwloc_INCLUDE_DIR
        ${HWLOC_ROOT}/include
        CACHE INTERNAL ""
    )
  endif() # End hwloc installation
endif()

find_package(Hwloc)
if(NOT Hwloc_FOUND)
  hpx_error(
    "Hwloc could not be found, please specify Hwloc_ROOT to point to the correct location"
  )
endif()

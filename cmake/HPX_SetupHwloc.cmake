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

if(NOT HPX_WITH_FETCH_HWLOC)
  find_package(Hwloc)
  if(NOT Hwloc_FOUND)
    hpx_error(
      "Hwloc could not be found, please specify Hwloc_ROOT to point to the correct location"
    )
  endif()
else()
  # Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 3.24
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
    cmake_policy(SET CMP0135 NEW)
  endif()

  if(NOT HPX_WITH_HWLOC_VERSION)
    set(HPX_WITH_HWLOC_VERSION "2.9")
    set(HPX_WITH_HWLOC_RELEASE "2.9.3")
  endif()

  hpx_info(
    "HPX_WITH_FETCH_HWLOC=${HPX_WITH_FETCH_HWLOC}, Hwloc v${HPX_WITH_HWLOC_RELEASE} will be fetched using CMake's FetchContent"
  )

  if(UNIX)
    include(FetchContent)
    fetchcontent_declare(
      HWLoc
      URL https://download.open-mpi.org/release/hwloc/v${HPX_WITH_HWLOC_VERSION}/hwloc-${HPX_WITH_HWLOC_RELEASE}.tar.gz
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
    set(Hwloc_INCLUDE_DIR
        ${HWLOC_ROOT}/include
        CACHE INTERNAL ""
    )
    if(APPLE)
      set(Hwloc_LIBRARY
          ${HWLOC_ROOT}/lib/libhwloc.dylib
          CACHE INTERNAL ""
      )
    else()
      set(Hwloc_LIBRARY
          ${HWLOC_ROOT}/lib/libhwloc.so
          CACHE INTERNAL ""
      )
    endif()

  elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(hwloc_subdir win64)
    else()
      set(hwloc_subdir win32)
    endif()

    fetchcontent_declare(
      HWLoc
      URL https://download.open-mpi.org/release/hwloc/v${HPX_WITH_HWLOC_VERSION}/hwloc-${hwloc_subdir}-build-${HPX_WITH_HWLOC_RELEASE}.zip
      TLS_VERIFY true
    )
    if(NOT HWLoc_POPULATED)
      fetchcontent_populate(HWLoc)
    endif()
    set(HWLOC_ROOT
        "${CMAKE_BINARY_DIR}/_deps/hwloc-src"
        CACHE INTERNAL ""
    )
    include_directories(${HWLOC_ROOT}/include)
    link_directories(${HWLOC_ROOT}/lib)
    set(Hwloc_INCLUDE_DIR
        ${HWLOC_ROOT}/include
        CACHE INTERNAL ""
    )
    set(Hwloc_LIBRARY
        ${HWLOC_ROOT}/lib/libhwloc.dll.a
        CACHE INTERNAL ""
    )
  else()
    hpx_error(
      "Building HWLOC as part of HPX' configuration process is not supported on this platform"
    )
  endif() # End hwloc installation

  add_library(Hwloc::hwloc INTERFACE IMPORTED)
  target_include_directories(Hwloc::hwloc INTERFACE ${Hwloc_INCLUDE_DIR})
  target_link_libraries(Hwloc::hwloc INTERFACE ${Hwloc_LIBRARY})

  if(HPX_WITH_FETCH_HWLOC AND "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    add_custom_target(
      HwlocDLL ALL
      COMMAND ${CMAKE_COMMAND} -E make_directory
              "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/"
      COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
        "${HWLOC_ROOT}/bin/libhwloc-15.dll"
        "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/"
    )
    add_hpx_pseudo_target(HwlocDLL)
  endif()
endif()

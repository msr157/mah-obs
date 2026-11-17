cmake_minimum_required(VERSION 3.28...3.30)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/common/bootstrap.cmake" NO_POLICY_SCOPE)

project(${_name} VERSION ${_version})

option(ENABLE_FFMPEG "Decode H.264 from phone (requires FFmpeg); MJPEG web path works without it" OFF)

include(compilerconfig)
include(defaults)
include(helpers)

add_library(${CMAKE_PROJECT_NAME} MODULE)

list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR}/.deps/obs-studio-32.2.1/build_x64/libobs)
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR}/.deps/obs-studio-32.2.1/build_x64/deps/w32-pthreads)

find_package(libobs REQUIRED)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::libobs)

if(OS_WINDOWS)
  find_package(w32-pthreads REQUIRED)
  target_link_libraries(
    ${CMAKE_PROJECT_NAME}
    PRIVATE
      OBS::w32-pthreads
      ws2_32
      iphlpapi
  )
elseif(OS_MACOS)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE "-framework Security")
elseif(OS_LINUX)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE pthread)
endif()

if(ENABLE_FFMPEG)
  find_package(FFmpeg 6.0 COMPONENTS avcodec avutil)
  if(FFmpeg_FOUND)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE MAH_HAVE_FFMPEG=1)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE FFmpeg::avcodec FFmpeg::avutil)
    message(STATUS "mah-mobile-cam: H.264 decode enabled (FFmpeg)")
  else()
    message(WARNING "ENABLE_FFMPEG=ON but FFmpeg not found; building MJPEG-only")
  endif()
else()
  message(STATUS "mah-mobile-cam: H.264 decode disabled (ENABLE_FFMPEG=OFF; MJPEG web path)")
endif()

target_sources(
  ${CMAKE_PROJECT_NAME}
  PRIVATE
    src/mah-mobile-cam.c
    src/mah-web.c
    src/mah-web.h
    src/mah-h264.c
    src/mah-h264.h
    src/stb_image.h
)

set_target_properties_plugin(${CMAKE_PROJECT_NAME} PROPERTIES OUTPUT_NAME ${_name})
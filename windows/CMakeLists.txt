# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "pg_db_ui")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.27)

# Define build-specific option.
get_property(IS_IN_TRY_MODE GLOBAL PROPERTY IN_TRY_MODE)
if(IS_IN_TRY_MODE)
  add_compile_definitions(FLUTTER_TRY_MODE)
endif()

# Use Unicode for all projects.
add_compile_definitions(UNICODE)
add_compile_definitions(_UNICODE)

# Define the application title and version strings.
set(APPLICATION_TITLE "PG DB Browser")
set(APPLICATION_VERSION "1.0.0")

# ==============================================================================
# Build configuration options
# ==============================================================================

# Use the highest available C++ standard.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Use precompiled headers on Windows.
target_precompile_headers(${BINARY_NAME} PRIVATE "pch.h")

# ==============================================================================
# Platform-specific configuration
# ==============================================================================

# Windows-specific configuration.
if(WIN32)
  # For Windows, the application's version resource is set using a resource
  # script.
  set(RES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/runner/resources/app.rc")
  if(EXISTS "${RES_FILE}")
    set(FLUTTER_APP_RESOURCE_FILE "${RES_FILE}")
  endif()

  # For Windows, the application's icon is set using a resource script.
  set(ICON_FILE "${CMAKE_CURRENT_SOURCE_DIR}/runner/resources/app_icon.ico")
  if(EXISTS "${ICON_FILE}")
    set(FLUTTER_APP_ICON_FILE "${ICON_FILE}")
  endif()
endif()

# ==============================================================================
# Application sources
# ==============================================================================

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build files.
add_subdirectory("runner")

# ==============================================================================
# Installation
# ==============================================================================

# Only install on Windows for now.
if(WIN32)
  install(TARGETS ${BINARY_NAME}
    RUNTIME DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
    COMPONENT Runtime)

  install(FILES "${FLUTTER_APP_ICON_FILE}"
    DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
    COMPONENT Runtime)

  install(FILES "${FLUTTER_APP_RESOURCE_FILE}"
    DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
    COMPONENT Runtime)
endif()


include(FetchContent)

FetchContent_Populate(
  swift-log
  GIT_REPOSITORY https://github.com/apple/swift-log.git
  GIT_TAG 1.15.0
)

set(SWIFT_LOG_SOURCE_DIR "${swift-log_SOURCE_DIR}")
message(STATUS "swift-log source directory:")
message(STATUS "  ${SWIFT_LOG_SOURCE_DIR}")

file(
  GLOB_RECURSE
  LOGGING_SOURCES
  CONFIGURE_DEPENDS
  "${SWIFT_LOG_SOURCE_DIR}/Sources/Logging/*.swift"
)

message(STATUS "Logging source files:")
message(STATUS "  ${LOGGING_SOURCES}")

add_library(Logging STATIC ${LOGGING_SOURCES})

target_compile_options(Logging PRIVATE "SHELL:-package-name swift-log")
target_link_libraries(
  Logging
  PRIVATE
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
)
set_target_properties(
  Logging
  PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES
  ${CMAKE_Swift_MODULE_DIRECTORY}
)

install_swift_module(Logging)
set_property(GLOBAL APPEND PROPERTY PUPPY_EXPORTS Logging)

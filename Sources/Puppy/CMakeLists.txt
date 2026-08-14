set(PUPPY_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "Puppy source directory:")
message(STATUS "  ${PUPPY_SOURCE_DIR}")

file(
  GLOB_RECURSE
  PUPPY_SOURCES
  CONFIGURE_DEPENDS
  "${PUPPY_SOURCE_DIR}/*.swift"
)

message(STATUS "Puppy source files:")
message(STATUS "  ${PUPPY_SOURCES}")

add_library(Puppy STATIC ${PUPPY_SOURCES})

target_compile_options(Puppy PUBLIC "SHELL:-package-name Puppy")
target_link_libraries(
  Puppy
  PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  $<$<NOT:$<PLATFORM_ID:Darwin>>:CPuppy>
  Logging
)
set_target_properties(
  Puppy
  PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES
  ${CMAKE_Swift_MODULE_DIRECTORY}
)

install_swift_module(Puppy)
set_property(GLOBAL APPEND PROPERTY PUPPY_EXPORTS Puppy)

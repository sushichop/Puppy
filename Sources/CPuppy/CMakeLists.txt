add_library(CPuppy STATIC
  src/CPuppy.c)

target_include_directories(CPuppy PUBLIC
  include)

set_target_properties(CPuppy PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

set_property(GLOBAL APPEND PROPERTY PUPPY_EXPORTS CPuppy)

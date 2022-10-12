add_library(Puppy
  Compatibility.swift
  ConsoleLogger.swift
  FileError.swift
  FileLogger.swift
  FileLoggerable.swift
  FileManager+Windows.swift
  FileRotationLogger.swift
  LogColor.swift
  LogFormatter.swift
  Loggerable.swift
  LogLevel.swift
  OSLogger.swift
  Puppy.swift
  PuppyLogHandler.swift
  SystemLogger.swift)

target_link_libraries(Puppy PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  $<$<NOT:$<PLATFORM_ID:Darwin>>:CPuppy>
  Logging)
set_target_properties(Puppy PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

install_swift_module(Puppy)
set_property(GLOBAL APPEND PROPERTY PUPPY_EXPORTS Puppy)

include(FetchContent)

FetchContent_Declare(swift-log
  GIT_REPOSITORY https://github.com/apple/swift-log.git
  GIT_TAG 1.14.0
)
FetchContent_MakeAvailable(swift-log)

add_library(Logging
  ${swift-log_SOURCE_DIR}/Sources/Logging/Handlers/MultiplexLogHandler.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Handlers/StreamLogHandler.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Handlers/SwiftLogNoOpLogHandler.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Locks.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/LogEvent.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/LogHandler.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Logger+Attributes.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Logger+With.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Logger.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/LoggingSystem.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/MetadataProvider.swift)

target_compile_options(Logging PRIVATE
    "$<$<COMPILE_LANGUAGE:Swift>:-package-name>"
    "$<$<COMPILE_LANGUAGE:Swift>:swift-log>")
target_link_libraries(Logging PRIVATE
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>)
set_target_properties(Logging PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

install_swift_module(Logging)
set_property(GLOBAL APPEND PROPERTY PUPPY_EXPORTS Logging)

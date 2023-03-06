include(FetchContent)

FetchContent_Declare(swift-log
  GIT_REPOSITORY https://github.com/apple/swift-log.git
  GIT_TAG 1.5.2
)
FetchContent_MakeAvailable(swift-log)

add_library(Logging
  ${swift-log_SOURCE_DIR}/Sources/Logging/Locks.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/LogHandler.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/Logging.swift
  ${swift-log_SOURCE_DIR}/Sources/Logging/MetadataProvider.swift)

target_link_libraries(Logging PRIVATE
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>)
set_target_properties(Logging PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

install_swift_module(Logging)
set_property(GLOBAL APPEND PROPERTY PUPPY_EXPORTS Logging)

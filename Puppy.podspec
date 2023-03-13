Pod::Spec.new do |s|
  s.name              = "Puppy"
  s.version           = "0.7.0"
  s.summary           = "A flexible logging library written in Swift"
  s.homepage          = "https://github.com/sushichop/Puppy"
  s.license           = { :type => "MIT", :file => "LICENSE" }
  s.author            = { "Koichi Yokota" => "sushifarm2012@gmail.com" }

  s.osx.deployment_target     = "10.15"
  s.ios.deployment_target     = "13.0"
  s.tvos.deployment_target    = "13.0"
  s.watchos.deployment_target = "6.0"

  s.source            = { :git => "https://github.com/sushichop/Puppy.git", :tag => "#{s.version}" }
  
  s.default_subspec   = "Core"

  s.subspec "Core" do |core|
    core.header_mappings_dir = "Sources/CPuppy/include"
    core.public_header_files = "Sources/CPuppy/include/**/*.h"
    core.source_files        = "Sources/CPuppy/**/*.{h,c}", "Sources/Puppy/**/*.{swift}"
  end

  s.cocoapods_version = ">= 1.7.0"
  s.swift_versions    = ["5.0"]
end

Pod::Spec.new do |s|
  s.name         = "PixelClear"
  s.version      = "0.0.1"
  s.summary      = "Framework to make pixel perfect apps"
  s.description  = <<-DESC
    Framework to make pixel perfect apps useful mostly for developing.
  DESC
  s.homepage     = "https://github.com/savana10/PixelClear"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Savana Kranth" => "savanakranth@gmail.com" }
  s.ios.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/savana10/PixelClear.git", :tag => "master" }
  s.ios.source_files  = "PixelClear/"
  s.ios.resources     = "PixelClear/*.{xib,storyboard}"
  s.ios.frameworks  = ["Foundation", "UIKit", "Photos"]
  s.swift_version = "5.0"
end


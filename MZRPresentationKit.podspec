#
# Be sure to run `pod lib lint MZRPresentationKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MZRPresentationKit"
  s.version          = "1.0.1"
  s.summary          = "When you give a presentation, your finger points are visible on screen."
  s.description      = <<-DESC
                       # Give a presentation more impressive with finter points.

                       When you give a presentation, your finger points are visible on screen.

                       - Multiple fingers supported.
                       - Multiple UIWindows supported.
                       - You can change colors and images of finger points.
                       DESC
  s.homepage         = "https://github.com/morizotter/MZRPresentationKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Naoki Morita" => "namorit@gmail.com" }
  s.source           = { :git => "https://github.com/morizotter/MZRPresentationKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/morizotter'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.swift'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

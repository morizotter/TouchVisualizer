#
# Be sure to run `pod lib lint MZRPresentationKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TouchVisualizer"
  s.version          = "1.1.2"
  s.summary          = "Effective presentation with TouchVisualizer!"
  s.description      = <<-DESC
                       # Give a presentation more impressive with finter points.
                       When you give a presentation, your finger points are visible on screen.
                       TouchVisualizer is a new version of MZRPresentationKit

                       - Multiple fingers supported.
                       - Multiple UIWindows supported.
                       - Shows touch radius.
                       - Shows touch duration.
                       - You can change colors and images of finger points.
                       DESC
  s.homepage         = "https://github.com/morizotter/TouchVisualizer"
  s.license          = 'MIT'
  s.author           = { "Naoki Morita" => "namorit@gmail.com" }
  s.source           = { :git => "https://github.com/morizotter/TouchVisualizer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/morizotter'

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.swift'
end

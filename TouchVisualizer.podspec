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
  s.version          = "4.0.0"
  s.summary          = "Effective presentation with TouchVisualizer!"
  s.description      = <<-DESC
                       TouchVisualizer is a lightweight and pure Swift implemented library for visualizing touches on the screen. Let's give an effective presentation with TouchVisualizer!

                       - Works with just a single line of code!
                       - Multiple fingers supported.
                       - Multiple UIWindows supported.
                       - Shows touch radius.
                       - Shows touch duration.
                       - You can change colors and images of finger points.
                       - iPhone and iPad with portlait and landscape supported.
                       DESC
  s.homepage         = "https://github.com/morizotter/TouchVisualizer"
  s.license          = 'MIT'
  s.author           = { "Naoki Morita" => "namorit@gmail.com" }
  s.source           = { :git => "https://github.com/morizotter/TouchVisualizer.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/morizotter'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.swift_version = '5.2'

  s.source_files = 'TouchVisualizer/**/*.swift'
end

#
# Be sure to run `pod lib lint JTAppleCalendar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JTAppleCalendar"
  s.version          = "0.1.0"
  s.summary          = "The Apple Calendar control Apple wished they made."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
This should be the first and last calendar control you ever try.
This calendar is different from others in that it is highly configurable with minimal code.
The problem with other calendars is they try to cram every feature into it hoping it will be enough for the programmer.
This is an incorrect way to build controls. Take a look at UITableView; do you see Apple building what they think you want
the UITableView to look like? No. So neither should we. Interested? Try a pod install today. Let's make this the only calendar
pod any will ever want to try.
                       DESC

  s.homepage         = "https://github.com/patchthecode/JTAppleCalendar"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "JayT" => "patchthecode@gmail.com" }
  s.source           = { :git => "https://github.com/patchthecode/JTAppleCalendar.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'JTAppleCalendar' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

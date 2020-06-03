#
# Be sure to run `pod lib lint ClusteringMarkers.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ClusteringMarkers'
  s.version          = '0.3.1'
  s.summary          = 'Clustering markers using YandexMapKit.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/Smalex911/ClusteringMarkers'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aleksandr' => 'alex11sm@mail.ru' }
  s.source           = { :git => 'https://github.com/Smalex911/ClusteringMarkers.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ClusteringMarkers/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ClusteringMarkers' => ['ClusteringMarkers/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.static_framework = true
  
  s.dependency 'YandexMapKit'
  s.dependency 'AlamofireImage', '< 4'
end

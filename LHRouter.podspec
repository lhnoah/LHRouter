#
#  Be sure to run `pod spec lint LHRouter.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                  = "LHRouter"
  s.version               = "0.0.1"
  s.summary                = "LHRouter."
  s.description           = "A smart iOS URL Router"
  s.homepage              = "https://github.com/lhnoah/LHRouter"
  s.license               = "MIT"
  s.author                = { "Noah" => "lh_1989@126.com" }
  s.source                = { :git => "https://github.com/lhnoah/LHRouter.git", :tag => s.version.to_s }
  s.source_files          = "LHRouter/Classes/**/*.{h,m}"
  s.ios.deployment_target = '9.0'

end

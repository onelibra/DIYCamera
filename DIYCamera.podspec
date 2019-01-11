
Pod::Spec.new do |s|

  s.name         = "DIYCamera"
  s.version      = "1.0.0"
  s.summary      = "custom camera"


  s.description  = <<-DESC
                    A custom Camera Demo,
                   DESC

  s.homepage     = "https://github.com/onelibra/DIYCamera"
  s.license      = "MIT"
  s.author             = { "yangbo" => "yangbo@zgyjyx.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/onelibra/DIYCamera.git", :tag => "1.0.0" }
  s.source_files  = "CamerDemo", "CamerDemo/Camera/*.{h,m}"
  s.resources = "CamerDemo/Camera/*.{png,xib,nib,storyboard}"

  s.frameworks = "AVFoundation", "CoreMotion", "UIKit"
  s.dependency "NYXImagesKit"
  s.dependency "Masonry"
#s.resource_bundles = {
#'CamerDemo' => ['CamerDemo/Camera/*.xcassets']
#}
end

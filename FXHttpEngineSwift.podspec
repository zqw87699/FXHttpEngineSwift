Pod::Spec.new do |s|
  s.name         = "FXHttpEngineSwift"
  s.version      = "1.0.0"
  s.summary      = "http访问框架"

  s.homepage     = "https://github.com/zqw87699/FXHttpEngineSwift"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = {"zhangdazong" => "929013100@qq.com"}

  s.source       = { :git => "https://github.com/zqw87699/FXHttpEngineSwift.git", :tag => "#{s.version}"}

  s.platform     = :ios, "8.0"

  s.frameworks = "Foundation", "UIKit"

  s.module_name = 'FXHttpEngineSwift'

  s.requires_arc = true

s.subspec 'API' do |api|
    api.source_files = 'Classes/API/*.{swift}'

end

s.subspec 'Core' do |core|
    core.source_files = 'Classes/Core/*.{swift}'

end

  s.dependency 'Alamofire', '4.4.0'

  s.dependency 'FXLogSwift'

  s.dependency 'ReactiveSwift','1.1.1'

end

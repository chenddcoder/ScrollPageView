Pod::Spec.new do |s|
  s.name         = "DDScrollPageView"
  s.version      = "1.0.2"
  s.summary      = "it is use to create a CitySelectViewController,easy to use"
  s.homepage     = "https://github.com/chenddcoder/ScrollPageView"
  s.license      = "MIT"
  s.author             = { "chenddcoder" => "chenddcoder@foxmail.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/chenddcoder/ScrollPageView.git", :tag => "1.0.2" }
  s.source_files  = "ScrollPageController/ScrollPageController/Classes/*.{h,m}"
  s.requires_arc = true
  s.dependency "SMPageControl","~> 1.2"
end

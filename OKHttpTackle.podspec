Pod::Spec.new do |s|
s.name         = "OKHttpTackle"
s.version      = "0.0.1"
s.ios.deployment_target = '7.0'
s.summary      = "Multifunctional third party Library Based on AFNetworking package"
s.homepage     = "https://github.com/luocheng2013/SendHttpDemo"
s.license      = "MIT"
s.author             = { "luocheng" => "maowangxin_2013@163.com" }
s.social_media_url   = "http://www.jianshu.com/u/c4ac9f9adf58"
s.source       = { :git => "https://github.com/luocheng2013/SendHttpDemo.git", :tag => s.version }
s.source_files  = "OKHttpTackle/*/*"
s.resource = "OKHttpTackle/OKHttpTackle.bundle"
s.requires_arc = true
s.dependency 'AFNetworking'
s.dependency 'MBProgressHUD'
s.dependency 'FMDB', '~> 2.6.2'
s.dependency 'MJRefresh', '~> 3.1.12'
end
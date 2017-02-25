Pod::Spec.new do |s|
s.name         = "OKHttpTackle"
s.version      = "0.0.1"
s.ios.deployment_target = '7.0'
s.summary      = "一个在AFNetworking库上的二次封装，一个请求即自动处理请求转圈、请求提示、数据缓存、表格分页处理、无数据或失败等页面提示、失败尝试重复请求等操作"
s.homepage     = "https://github.com/luocheng2013/SendHttpDemo"
s.license      = "MIT"
s.author             = { "luocheng" => "maowangxin_2013@163.com" }
s.social_media_url   = "http://www.jianshu.com/u/c4ac9f9adf58"
s.source       = { :git => "https://github.com/luocheng2013/SendHttpDemo.git", :tag => s.version }
s.source_files  = "OKHttpTackle/*"
s.requires_arc = true
s.resources = "OKHttpTackle/OKHttpTackle.bundle"
s.dependency 'AFNetworking'
s.dependency 'MBProgressHUD'
s.dependency 'FMDB', '~> 2.6.2'
s.dependency 'MJRefresh', '~> 3.1.12'
end
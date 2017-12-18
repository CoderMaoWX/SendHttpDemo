Pod::Spec.new do |s|
s.name         			= "OKHttpTackle"
s.version      			= "0.0.2"
s.ios.deployment_target = '7.0'
s.summary      			= "Multifunctional third party Library Based on AFNetworking package"
s.homepage     			= "https://github.com/luocheng2013/SendHttpDemo"
s.license      			= "MIT"
s.author             	= { "luocheng" => "maowangxin_2013@163.com" }
s.social_media_url  	= "http://www.jianshu.com/u/c4ac9f9adf58"
s.source       			= { :git => "https://github.com/luocheng2013/SendHttpDemo.git", :tag => s.version }
s.resource 	  		 	= "OKHttpTackle/OKHttpTackle.bundle"
s.public_header_files 	= "OKHttpTackle/OKBaseHttpTackle/*.h","OKHttpTackle/OKExtensionHttpTackle/.*h"
s.source_files  		= "OKHttpTackle/OKBaseHttpTackle/*.h","OKHttpTackle/OKExtensionHttpTackle/.*h"

# 分模块存放
s.default_subspec 		= 'OKBaseHttpTackle','OKExtensionHttpTackle'

# 存放Base类
    Base_files = 'OKHttpTackle/OKBaseHttpTackle/*.{h,m}'
    s.subspec 'OKBaseHttpTackle' do |ss|
        ss.source_files = Base_files
        ss.dependency "AFNetworking"
    end

# 存放扩展类
    extension_files = 'OKHttpTackle/OKExtensionHttpTackle/*.{h,m}','OKHttpTackle/OKBaseHttpTackle/*.{h,m}'
    s.subspec 'OKExtensionHttpTackle' do |ss|
        ss.source_files = extension_files
        ss.dependency "AFNetworking"
        ss.dependency "FMDB"
        ss.dependency "MJRefresh"
        ss.dependency "MBProgressHUD"
        ss.dependency "OKAlertContrActionSheet"
    end

s.requires_arc = true
s.dependency 'AFNetworking'
s.dependency 'MBProgressHUD'
s.dependency 'FMDB'
s.dependency 'MJRefresh'
s.dependency 'OKAlertContrActionSheet'
end
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

# Pods for targets

def project_pods
    
    # -- Reactive
    pod 'RxSwift'
    pod 'RxCocoa'
    
    # -- Networking
    pod 'ReachabilitySwift'
    pod 'Alamofire' , '4.9.1'
    pod 'Kingfisher'
    
    
end

def test_pods
    
    # -- Reactive
    pod 'RxTest'
    
end

# Targets

target 'rxmarvel' do
  #inherit! :search_paths
  project_pods
end

target 'UnitTest' do
  project_pods
  test_pods
end




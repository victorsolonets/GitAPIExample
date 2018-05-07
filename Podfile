# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
    pod 'Alamofire'
    pod 'SDWebImage', '~> 4.0'
end

target 'GitTest' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for GitTest
    shared_pods
    
    target 'GitTestTests' do
        inherit! :search_paths
        shared_pods
    end
    
    target 'GitTestUITests' do
        inherit! :search_paths
    end
    
end

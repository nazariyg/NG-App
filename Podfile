source 'https://github.com/CocoaPods/Specs.git'

# If changed, the value may need to be repeated for `config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']` in the `post_install` hook.
platform :ios, '12.0'

inhibit_all_warnings!
use_frameworks!


def global_pods

    pod 'SwiftLint'
    pod 'R.swift'

    pod 'RxSwift', '~> 5.0'
    pod 'RxCocoa', '~> 5.0'
    pod 'RxOptional'
    pod 'RxBiBinding'
    pod 'RxSwiftExt', '~> 5.0'
    pod 'RxGesture'
    pod 'RxKeyboard'

    pod 'RealmSwift', '~> 3.0'
    pod 'Cartography', '~> 3.0'

end


target 'NGApp' do
    global_pods
end


target 'Cornerstones' do
    pod 'KeychainAccess'
end


target 'Core' do
    global_pods
    pod 'Alamofire', '~> 5.0'
end


target 'UICore' do
    global_pods
end


post_install do |installer|
    installer.pods_project.targets.each do |target|

        # Set the iOS version.
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end

        # Disable bitcode.
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end

        # Realm.
        if target.name.include?('Realm')
            target.build_configurations.each do |config|
                config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
            end
        end

    end

end

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FoundSounds' do
  use_frameworks!
  platform :ios, '12.1'
  inhibit_all_warnings!
  pod 'KeychainSwift', '~> 13.0'
  pod 'Alamofire', '~> 4.7.3'
  pod 'ReachabilitySwift', '~> 4.3.0'
  pod 'KMPlaceholderTextView', '~> 1.4.0'
  pod 'SwiftLint', '~> 0.27.0'
  pod 'DeviceGuru', '~> 5.0.0'
  pod 'Mockingjay', '~> 2.0.1'

  # Pods for FoundSounds

  target 'FoundSoundsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FoundSoundsUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
      end
    end
  end
end

target 'FoundSounds Today View' do
  use_frameworks!
  platform :ios, '12.1'

  # Pods for FoundSounds Today View
end

target 'FoundSounds TV' do
  use_frameworks!

  platform :tvos, '12.1'
  pod 'Alamofire', '~> 4.7.3'
  pod 'SwiftLint', '~> 0.27.0'
  pod 'DeviceGuru', '~> 5.0.0'
  pod 'ReachabilitySwift', '~> 4.3.0'

  target 'FoundSounds TVTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FoundSounds TVUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'FoundSounds Watch' do
  use_frameworks!

  # Pods for FoundSounds Watch
  platform :watchos, '5.1'
  pod 'KeychainSwift', '~> 13.0'
  pod 'Alamofire', '~> 4.7.3'
  pod 'SwiftLint', '~> 0.27.0'
  pod 'DeviceGuru', '~> 5.0.0'
end

target 'FoundSounds Watch Extension' do
  use_frameworks!

  # Pods for FoundSounds Watch Extension
  platform :watchos, '5.1'
  pod 'KeychainSwift', '~> 13.0'
  pod 'Alamofire', '~> 4.7.3'
  pod 'SwiftLint', '~> 0.27.0'
  pod 'DeviceGuru', '~> 5.0.0'
end

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'app' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for app
  #Rx관련
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxAlamofire'
  
  #UI관련
  pod 'SnapKit'
  pod 'Hex'
  pod 'iProgressHUD'
  pod 'Kingfisher'
  pod 'Floaty'
  pod 'ImageSlideshow'
  pod 'Cosmos'
  pod 'YPImagePicker'
  pod 'FloatingPanel'
  pod 'FSPagerView'
  pod 'TextFieldEffects'
  
  #DI관련
  pod 'Swinject'
  pod 'Then'

  #AdMob관련
  pod 'Google-Mobile-Ads-SDK'
  
  #Google Maps
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end

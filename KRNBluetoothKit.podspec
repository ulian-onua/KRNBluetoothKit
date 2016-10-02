Pod::Spec.new do |s|

  s.name         = "KRNBluetoothKit"
  s.version      = "0.0.1"
  s.summary      = "The lib to simplify usage of CoreBluetooth framework"

  s.homepage     = "https://github.com/ulian-onua/KRNBluetoothKit"

  s.license      = { :type => "MIT", :file => "LICENSE" }



  s.author             = { "Julian Drapaylo" => "ulian.onua@gmail.com" }
  s.social_media_url   = "https://www.linkedin.com/in/julian-drapaylo"



  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/ulian-onua/KRNBluetoothKit.git", :tag => "s.version.t" }


  s.source_files  = "KRNBluetoothKit/*.{h,m}"
  s.public_header_files = "KRNBluetoothKit/*.h"

  s.frameworks = "Foundation", "CoreBluetooth"


  s.requires_arc = true


end

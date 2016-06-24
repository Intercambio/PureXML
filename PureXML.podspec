# coding: utf-8
Pod::Spec.new do |s|
  s.name                = "PureXML"
  s.version             = "1.1"
  s.summary             = "Lightweight wrapper around libxml."
  
  s.authors             = { "Tobias Kräntzer" => "info@tobias-kraentzer.de" }
  s.license             = { :type => 'BSD', :file => 'LICENSE.md' }
  
  s.homepage            = "https://garage.tobias-kraentzer.de/diffusion/PX/"
  s.social_media_url 	= 'https://twitter.com/anagrom_ataf'

  s.source              = { :git => "https://garage.tobias-kraentzer.de/diffusion/PX/purexml.git", :tag => "#{s.version}" }
                            
  s.requires_arc        = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files        = 'PureXML/PureXML/**/*.{h,m,c}'
  
  s.libraries   = 'xml2'
  s.xcconfig    = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end

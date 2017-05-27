project 'Example/JZToolkit'
workspace 'JZToolKit'
use_frameworks!

platform :ios, '10.0'

target 'JZToolKit_Example' do
  pod 'JZToolKit', :path => '.'
  pod 'JZToolKit/Experimental', :path => '.'

  target 'JZToolKit_Tests' do
    inherit! :search_paths
    pod 'JZToolKit', :path => '.'
    pod 'JZToolKit/Experimental', :path => '.'
    
  end
end

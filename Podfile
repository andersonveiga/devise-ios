#
#  Podfile
#
#  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
#

# Pod sources
source 'https://github.com/CocoaPods/Specs.git'

# Initial configuration
platform :ios, '8.0'
inhibit_all_warnings!

# Framework dependencies
pod 'UICKeyChainStore', '~> 1.1'
pod 'ngrvalidator', '~> 1.3.0'
pod 'Google/SignIn', '~> 4.0.1'


# Exclusive demo dependencies
target 'Demo' do
  link_with 'Devise Demo'
end

# Unit tests exclusive dependencies
target 'Tests' do
  link_with 'Devise Tests', 'Devise Demo Tests'

  pod 'Kiwi', '~> 2.3'
  pod 'OHHTTPStubs', '~> 3.1'
  pod 'KIF-Kiwi', '~> 0.2.4'
  pod 'OCMockito', '~> 1.4.0'
end

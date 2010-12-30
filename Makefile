##
#  UAFaker + Settings Bundle
##

# Note: The SBSettings toggle is seperated from the main package and is built sepearately

# This package uses Ryan Petrich's AppList to choose and enable applications (https://github.com/rpetrich/AppList)

TWEAK_NAME = UAFaker
UAFaker_FILES = CFNetworkHooks.xm
UAFaker_FRAMEWORKS = CFNetwork CoreFoundation

BUNDLE_NAME = UserAgentFaker
UserAgentFaker_FILES = UAFakerSettingsController.m
UserAgentFaker_INSTALL_PATH = /System/Library/PreferenceBundles/
UserAgentFaker_FRAMEWORKS = UIKit
UserAgentFaker_PRIVATE_FRAMEWORKS = Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp UAFakerPrefEntry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/UAFaker.plist$(ECHO_END)

run : package install
ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = UserAgentFaker7Prefs
UserAgentFaker7Prefs_FILES = UserAgentFaker7Prefs.mm UAFApplicationViewController.mm
UserAgentFaker7Prefs_INSTALL_PATH = /Library/PreferenceBundles
UserAgentFaker7Prefs_FRAMEWORKS = UIKit
UserAgentFaker7Prefs_PRIVATE_FRAMEWORKS = Preferences
UserAgentFaker7Prefs_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/UserAgentFaker7Prefs.plist$(ECHO_END)

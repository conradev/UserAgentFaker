include theos/makefiles/common.mk

TWEAK_NAME = UAFaker
UAFaker_FILES = WebKitHooks.xm
UAFaker_FRAMEWORKS = CoreFoundation
UAFaker_PRIVATE_FRAMEWORKS = WebKit

BUNDLE_NAME = UAFakerSettings
UAFakerSettings_FILES = UARootListController.m
UAFakerSettings_INSTALL_PATH = /Library/PreferenceBundles/
UAFakerSettings_FRAMEWORKS = UIKit
UAFakerSettings_PRIVATE_FRAMEWORKS = Preferences

LIBRARY_NAME = Toggle
Toggle_FILES = Toggle.mm
Toggle_INSTALL_PATH = /var/mobile/Library/SBSettings/Toggles/UAFaker/

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/library.mk

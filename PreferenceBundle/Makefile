ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = UserAgentFakerSettings
UserAgentFakerSettings_FILES = UASettingsController.m
UserAgentFakerSettings_CFLAGS = -fobjc-arc
UserAgentFakerSettings_INSTALL_PATH = /Library/PreferenceBundles/
UserAgentFakerSettings_FRAMEWORKS = UIKit
UserAgentFakerSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

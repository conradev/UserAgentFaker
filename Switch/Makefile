ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = UserAgentFakerSwitch
UserAgentFakerSwitch_FILES = UASwitch.m
UserAgentFakerSwitch_CFLAGS = -fobjc-arc
UserAgentFakerSwitch_FRAMEWORKS = UIKit
UserAgentFakerSwitch_LIBRARIES = flipswitch
UserAgentFakerSwitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

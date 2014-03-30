ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = UserAgentFaker7
UserAgentFaker7_FILES = Tweak.xm
UserAgentFaker7_PRIVATE_FRAMEWORKS = WebKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += useragentfaker7prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

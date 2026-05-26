# Platform & architecture detection
ARCH := $(shell uname -m)

PLATFORM_CXXFLAGS :=

ifeq ($(OS),Windows_NT)
  DYNAMIC_LIBRARY_EXTENSION := dll
else
  UNAME_S := $(shell uname -s)

  ifeq ($(UNAME_S),Linux)
    DYNAMIC_LIBRARY_EXTENSION := so

    CMD_INSTALL := install
    CMD_LD := ldconfig -n $(DESTDIR)$(LIBDIR)

    EXTERNALS +=  alsa
    PLATFORM_CXXFLAGS += -fext-numeric-literals
  else ifeq ($(UNAME_S),Darwin)
    DYNAMIC_LIBRARY_EXTENSION := dylib

    CMD_INSTALL := ginstall
    CMD_LD :=
  endif
endif

ifeq "$(ARCH)" "x86_64"
  PLATFORM_CXXFLAGS += -msse -msse2 -mfpmath=sse
  ifneq "$(UNAME_S)" "Darwin"
    PLATFORM_CXXFLAGS += -ffast-math
  endif
endif

# Project settings
VERSION := 0.237.1

# Build options
PREFIX := /usr/local
DESTDIR :=
BUILD_DIR := build
SOURCE_DIR := src

# Derived paths
LIBDIR=$(PREFIX)/lib
BINDIR=$(PREFIX)/bin
INCDIR=$(PREFIX)/include/tascar

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
    CMD_lD :=
  endif
endif

ifeq "$(ARCH)" "x86_64"
  PLATFORM_CXXFLAGS += -msse -msse2 -mfpmath=sse
  ifneq "$(UNAME_S)" "Darwin"
    PLATFORM_CXXFLAGS += -ffast-math
  endif
endif

# Compiler options
CXXFLAGS = -Wall -Wextra -Wdeprecated-declarations -Wno-psabi -std=c++17 -pthread	\
-ggdb -fno-finite-math-only -Wno-psabi $(PLATFORM_CXXFLAGS)
# -Wconversion
# -Werror
CPPFLAGS = -std=c++17

# Git revision info
GITMODIFIED:=$(shell test -z "`git status --porcelain -uno`" || echo "-modified")
COMMITHASH:=$(shell git log -1 --abbrev=7 --pretty='format:%h')
LATEST_RELEASETAG:=$(shell git tag -l "release*" |tail -1)
COMMIT_SINCE_RELEASE:=$(shell git rev-list --count $(LATEST_RELEASETAG)..)

FULLVERSION=$(VERSION).$(COMMIT_SINCE_RELEASE)-$(COMMITHASH)$(GITMODIFIED)

# Paths to project locations
mkfile_name := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_path := $(subst $(notdir $(mkfile_name)),,$(mkfile_name))

# Library features
HAS_LSL=yes
HAS_OPENMHA:=$(shell $(mkfile_path)/check_for_openmha)
HAS_OPENCV2:=$(shell $(mkfile_path)/check_for_opencv2)
HAS_OPENCV4:=$(shell $(mkfile_path)/check_for_opencv4)
HAS_WEBKIT:=$(shell $(mkfile_path)/check_for_webkit)

# Exports
export VERSION
export SOURCE_DIR
export BUILD_DIR
export CXXFLAGS
export HAS_LSL
export HAS_OPENMHA
export HAS_OPENCV2
export HAS_WEBKIT

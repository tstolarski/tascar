all: build modules

include ../config.mk
include ../rules.mk

#
# main targets:
#
RECEIVERS = omni nsp amb3h0v amb3h3v amb1h0v amb1h1v cardioid hann	\
  vbap vbap3d hoa2d ortf intensityvector vmic chmap hoa2d_fuma		\
  cardioidmod debugpos hoa2d_fuma_hos fakebf wfs hoa3d hoa3d_enc	\
  simplefdn itu51 foaconv hrtf micarray stereo

SOURCES = omni cardioidmod door generic1storder farsrc head

TASCARMODS = system pos2osc sampler pendulum epicycles motionpath	\
  foa2hoadiff route oscevents oscjacktime nearsensor dirgain dummy	\
  matrix hoafdnrot mpu6050track touchosc savegains hrirconv		\
  hossustain rotator orientationmodulator locationmodulator		\
  linearmovement granularsynth fail waitforjackport sleep jackrec	\
  oscserver oscrelay echoc snapangle oscactor oscheadtracker osceog	\
  tonalenhancement systime skyfall accmovement accrotator tuner

TASCARMODSGUI = tracegui simplecontroller timedisplay geopresets	\
  transportgui lightcolorpicker datalogging sendsvg

AUDIOPLUGINS = delay dummy gate hannenv identity lipsync		\
  lipsync_paper lookatme metronome onsetdetector sine sndfile spksim	\
  gainramp pulse pink dumplevels feedbackdelay bandpass filter		\
  level2osc const noise loopmachine pos2osc gain sndfileasync		\
  addchannel tubesim spkcalib sessiontime flanger timestamp		\
  burglatticelpc fence transportramp allpass bandlevel2osc level2hsv	\
  ringmodulator reclevelanalyzer pareq4band sawtooth

MASKPLUGINS = fig8 multibeam sampledgain

ifneq ($(OS),Windows_NT)
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  TASCARMODS += midicc2osc midictl mcuctl mididispatch joystick	\
    qualisystracker ltcgen lightctl ovheadtracker serialheadtracker
  AUDIOPLUGINS += simplesynth
endif
ifeq ($(UNAME_S),Darwin)
  TASCARMODS += ltcgen	 serialheadtracker mididispatch midicc2osc midictl mcuctl
#  ovheadtracker
endif
endif

ifeq "$(HAS_OPENCV2)" "yes"
GLABSENSORS += trackir
CXXFLAGS += -DHAS_OPENCV2
endif
ifeq "$(HAS_OPENCV4)" "yes"
GLABSENSORS += trackir
CXXFLAGS += -DHAS_OPENCV4
endif
# trackir requires opencv2, which is not available on Ubuntu 20.04


ifeq "$(HAS_LSL)" "yes"
CXXFLAGS += -DHAS_LSL
TASCARMODS += lsljacktime lslactor levels2osc pos2lsl osc2lsl
AUDIOPLUGINS += speechactivity periodogram
TASCARMODSGUI += waitforlslstream lsl2osc

ifneq ($(OS),Windows_NT)
# on Windows do not compile glabsensors:
TASCARMODSGUI += glabsensors
GLABSENSORS += smiley emergency espheadtracker	\
  qualisys jackstatus
endif

ifeq ($(UNAME_S),Linux)
GLABSENSORS += midicc serial oscthreshold eog
endif

endif

ifeq "$(HAS_OPENMHA)" "yes"
#AUDIOPLUGINS +=  openmha
endif

#
RECEIVERMODS = $(patsubst %,build/$(PLUGINPREFIX)tascarreceiver_%.$(DYNAMIC_LIBRARY_EXTENSION),$(RECEIVERS))

SOURCEMODS = $(patsubst %,build/$(PLUGINPREFIX)tascarsource_%.$(DYNAMIC_LIBRARY_EXTENSION),$(SOURCES))

TASCARMODDLLS = $(patsubst %,build/$(PLUGINPREFIX)tascar_%.$(DYNAMIC_LIBRARY_EXTENSION),$(TASCARMODS))
TASCARMODDLLSGUI = $(patsubst %,build/$(PLUGINPREFIX)tascar_%.$(DYNAMIC_LIBRARY_EXTENSION),$(TASCARMODSGUI))

AUDIOPLUGINDLLS = $(patsubst %,build/$(PLUGINPREFIX)tascar_ap_%.$(DYNAMIC_LIBRARY_EXTENSION),$(AUDIOPLUGINS))

MASKPLUGINDLLS = $(patsubst %,build/$(PLUGINPREFIX)tascar_mask_%.$(DYNAMIC_LIBRARY_EXTENSION),$(MASKPLUGINS))

GLABSENSORDLLS = $(patsubst %,build/$(PLUGINPREFIX)glabsensor_%.$(DYNAMIC_LIBRARY_EXTENSION),$(GLABSENSORS))


ifeq "ok" "$(shell pkg-config gtkmm-3.0 && echo ok)"
GTKDEF = "-DGTKMM30"
GTKEXT = gtkmm-3.0
else
GTKDEF = "-DGTKMM24"
GTKEXT = gtkmm-2.4
endif

ifeq "$(DEBUG)" "yes"
CXXFLAGS += -ggdb -DTSCDEBUG
else
CXXFLAGS += -O3
endif

TASCARVERSION=$(FULLVERSION)

TASCARLIB = -ltascar
TASCARDMXLIB = -ltascardmx
TASCARGUILIB = -ltascargui

CXXFLAGS += $(GTKDEF) $(LTRDEF)
# add libtascar/src for main headers, and libtascar/build for version number:
CXXFLAGS += -I../libtascar/include -I../libtascar/build
LDFLAGS += -L../libtascar/build
CXXFLAGS += -DTASCARVERSION="\"$(TASCARVERSION)\""

CXXFLAGS += -fpic
EXTERNALS = jack xerces-c liblo sndfile fftw3f samplerate

LDLIBS += `pkg-config --libs $(EXTERNALS)`
CXXFLAGS += `pkg-config --cflags $(EXTERNALS)`

LDLIBS += -ldl $(TASCARLIB)

modules: $(RECEIVERMODS) $(SOURCEMODS) $(TASCARMODDLLS) $(TASCARMODDLLSGUI) $(AUDIOPLUGINDLLS) $(MASKPLUGINDLLS) $(GLABSENSORDLLS)

clean:
	rm -Rf *~ src/*~ build doc/html

.PHONY : doc

$(TASCARMODDLLSGUI) $(GLABSENSORDLLS): EXTERNALS += gtkmm-3.0
$(TASCARMODDLLSGUI) $(GLABSENSORDLLS): CXXFLAGS += -I./build
$(TASCARMODDLLSGUI) $(GLABSENSORDLLS): LDLIBS += $(TASCARGUILIB)

ifeq ($(OS),Windows_NT)
$(TASCARMODDLLSGUI) $(GLABSENSORDLLS): LDLIBS += -lsigc-2.0
endif


build/$(PLUGINPREFIX)glabsensor_%.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS += gtkmm-3.0


ifeq "$(HAS_LSL)" "yes"
build/$(PLUGINPREFIX)glabsensor_%.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(LSLLIBS)
build/$(PLUGINPREFIX)tascar_ap_periodogram.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(LSLLIBS)
build/$(PLUGINPREFIX)tascar_ap_speechactivity.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(LSLLIBS)
build/$(PLUGINPREFIX)tascar_lsl2osc.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(LSLLIBS)
build/$(PLUGINPREFIX)tascar_datalogging.$(DYNAMIC_LIBRARY_EXTENSION):  LDLIBS += $(LSLLIBS)
build/$(PLUGINPREFIX)tascar_lsljacktime.$(DYNAMIC_LIBRARY_EXTENSION) build/$(PLUGINPREFIX)tascar_pos2lsl.$(DYNAMIC_LIBRARY_EXTENSION) build/$(PLUGINPREFIX)tascar_levels2osc.$(DYNAMIC_LIBRARY_EXTENSION) build/$(PLUGINPREFIX)tascar_lslactor.$(DYNAMIC_LIBRARY_EXTENSION) build/$(PLUGINPREFIX)tascar_osc2lsl.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(LSLLIBS)
endif

build/$(PLUGINPREFIX)tascar_ap_lipsync.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=-lfftw3f
build/$(PLUGINPREFIX)tascar_ap_lipsync_paper.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=-lfftw3f
build/$(PLUGINPREFIX)tascar_ap_openmha.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=-lopenmha
build/$(PLUGINPREFIX)tascar_datalogging.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS += -lmatio
build/$(PLUGINPREFIX)tascar_datalogging.$(DYNAMIC_LIBRARY_EXTENSION): build/datalogging_glade.h
build/$(PLUGINPREFIX)tascar_hossustain.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS += fftw3f
build/$(PLUGINPREFIX)tascar_lightctl.$(DYNAMIC_LIBRARY_EXTENSION) build/$(PLUGINPREFIX)tascar_ovheadtracker.$(DYNAMIC_LIBRARY_EXTENSION) build/$(PLUGINPREFIX)tascar_serialheadtracker.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(TASCARDMXLIB)
build/$(PLUGINPREFIX)tascar_ltcgen.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS+=ltc
build/$(PLUGINPREFIX)tascar_simplecontroller.$(DYNAMIC_LIBRARY_EXTENSION): build/simplecontroller_glade.h
build/$(PLUGINPREFIX)tascar_timedisplay.$(DYNAMIC_LIBRARY_EXTENSION): build/timedisplay_glade.h
build/$(PLUGINPREFIX)tascar_waitforlslstream.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=$(LSLLIBS)
build/$(PLUGINPREFIX)tascarreceiver_hoa2d.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS+=-lfftw3f
build/$(PLUGINPREFIX)tascarreceiver_hoa3d.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS+=gsl eigen3
build/$(PLUGINPREFIX)tascarreceiver_hoa3d_enc.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS+=gsl

ifeq "$(HAS_OPENCV2)" "yes"
build/$(PLUGINPREFIX)glabsensor_trackir.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS += opencv
endif
ifeq "$(HAS_OPENCV4)" "yes"
build/$(PLUGINPREFIX)glabsensor_trackir.$(DYNAMIC_LIBRARY_EXTENSION): EXTERNALS += opencv4
endif

build/$(PLUGINPREFIX)tascar_transportgui.$(DYNAMIC_LIBRARY_EXTENSION): build/transportgui_glade.h

build/glabsensors.o: EXTERNALS += gtkmm-3.0
build/glabsensors.o: build/glabsensors_glade.h
build/$(PLUGINPREFIX)tascar_glabsensors.$(DYNAMIC_LIBRARY_EXTENSION): build/glabsensors_glade.h
build/$(PLUGINPREFIX)tascar_glabsensors.$(DYNAMIC_LIBRARY_EXTENSION): build/glabsensorplugin.o build/glabsensors_glade.h src/glabsensorplugin.h
build/$(PLUGINPREFIX)tascar_glabsensors.$(DYNAMIC_LIBRARY_EXTENSION): LDLIBS += $(LSLLIBS) build/glabsensorplugin.o

build/$(PLUGINPREFIX)tascarreceiver_%.$(DYNAMIC_LIBRARY_EXTENSION): src/receivermod_%.cc
	$(CXX) -shared -o $@ $< $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

build/$(PLUGINPREFIX)tascarsource_%.$(DYNAMIC_LIBRARY_EXTENSION): src/tascarsource_%.cc
	$(CXX) -shared -o $@ $< $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

build/$(PLUGINPREFIX)tascar_%.$(DYNAMIC_LIBRARY_EXTENSION): src/tascarmod_%.cc
	$(CXX) -shared -o $@ $< $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

build/$(PLUGINPREFIX)tascar_ap_%.$(DYNAMIC_LIBRARY_EXTENSION): src/tascar_ap_%.cc
	$(CXX) -shared -o $@ $< $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

build/$(PLUGINPREFIX)tascar_mask_%.$(DYNAMIC_LIBRARY_EXTENSION): src/tascar_mask_%.cc
	$(CXX) -shared -o $@ $< $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

build/$(PLUGINPREFIX)glabsensor_%.$(DYNAMIC_LIBRARY_EXTENSION): src/glabsensor_%.cc build/glabsensorplugin.o
	$(CXX) -shared -o $@ $^ $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

build/%_glade.h: src/%.glade
	cat $< | sed 's/tascarversion/$(TASCARVERSION)/g' > $*_glade
	echo "#include <string>" > $@
	xxd -i $*_glade >> $@
	echo "std::string ui_"$*"((const char*)"$*"_glade,(size_t)"$*"_glade_len);" >> $@
	rm -f $*_glade

build/%.o: src/%.cc
	$(CXX) $(CXXFLAGS) -o $@ -c $^


# Local Variables:
# compile-command: "make"
# End:

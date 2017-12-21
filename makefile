define COMPILE
$(CXX) -o $1 -c $(filter %.cpp,$2) $(CXXFLAGS)
endef

define LINK
$(CXX) -o $1 $(filter %.o %.a,$2) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)
endef

define CREATE_TREE
$(shell python -c "import os; os.path.exists('$1') or os.makedirs('$1')")
endef

define DELETE_TREE
$(shell python -c "import shutil; shutil.rmtree('$1', True)")
endef

define DELETE_FILE
$(shell python -c "import os; os.path.exists('$1') and os.unlink('$1')")
endef

define DELETE_FILES
$(shell python -c "import os, glob; map(os.unlink, (n for n in glob.iglob('$1')))")
endef

BISON := bison
FLEX := flex
CXX := g++
CXXFLAGS := -std=c++11 -pedantic -Wall -Wextra
CXXFLAGS += -I"src"
CXXFLAGS += -Wno-unused-function
CXXFLAGS += -Wno-write-strings
LDFLAGS := -Wl,--subsystem=console
LDLIBS :=

deploy/c_cat.exe : build/c_cat.tab.o build/c_cat.yy.o build/buffer.o build/escapes.o | deploy ; $(call LINK,$@,$^)

build : ; $(call CREATE_TREE,$@)
deploy : ; $(call CREATE_TREE,$@)

build/c_cat.tab.o : build/c_cat.tab.cpp build/c_cat.tab.hpp | build
build/c_cat.yy.o : build/c_cat.yy.cpp | build/buffer.o build/escapes.o
build/c_cat.tab.hpp : src/c_cat.y | build/c_cat.tab.cpp ;
build/c_cat.tab.cpp : src/c_cat.y | build ; $(BISON) -o $@ -d $<
build/c_cat.yy.cpp : src/c_cat.l | build ; $(FLEX) -o $@ $<

build/buffer.o : src/buffer.cpp src/buffer.hpp | build ; $(call COMPILE,$@,$^)
build/escapes.o : src/escapes.cpp src/escapes.hpp | build ; $(call COMPILE,$@,$^)

.PHONY : clean reset run

clean : ; $(call DELETE_TREE,build)
reset : | clean ; $(call DELETE_TREE,deploy)

run : deploy/c_cat.exe ; $< src/test.cpp

.DELETE_ON_ERROR :

OBJECTS := $(shell find src -name '*.s' -and -not -name '*.inc.s' | sed -e 's/^src/out/' -e 's/s$$/o/')
OUT_DIRS := $(shell find src -type d | sed 's/^src/out/')
RESOURCES := $(shell find res -type f | sed -e '/\.png$$/s/^res/out/' -e 's/\.png$$/.bin/')
ROM := snestris.smc

all: dirs $(ROM)

$(ROM): $(OBJECTS)
	ld65 -C link.cfg -o $@ -m map.txt $^

out/res.o: src/res.s dirs $(RESOURCES)
	ca65 -g -o $@ $<

out/%.o: src/%.s dirs src/*.inc.s
	ca65 -g -o $@ $<

out/%.bin: res/%.png
	./tobin.py $@ $<

.PHONY: dirs
dirs:
	mkdir -p $(OUT_DIRS)

.PHONY: clean
clean:
	rm -rf out $(ROM) map.txt

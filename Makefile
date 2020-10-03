OBJECTS := $(shell find src -name '*.s' -and -not -name '*.inc.s' | sed -e 's/^src/out/' -e 's/s$$/o/')
RESOURCES := $(shell find res -type f | sed -e '/\.png$$/s/^res/out/' -e 's/\.png$$/.bin/')
ROM := snestris.smc

$(ROM): $(OBJECTS)
	ld65 -C link.cfg -o $@ -m map.txt $^

out/res.o: src/res.s out $(RESOURCES)
	ca65 -g -o $@ $<

out/%.o: src/%.s out src/*.inc.s
	ca65 -g -o $@ $<

out/%.bin: res/%.png
	./tobin.py $@ $<

out:
	mkdir out

.PHONY: clean
clean:
	rm -rf out $(ROM) map.txt

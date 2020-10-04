OBJECTS := $(shell find src -name '*.s' -and -not -name '*.inc.s' | sed -e 's/^src/out/' -e 's/s$$/o/')
RESOURCES := $(shell find res -type f | sed -e '/\.png$$/s/^res/out/' -e 's/\.png$$/.bin/')
ROM := snestris.smc

$(ROM): $(OBJECTS)
	ld65 -C link.cfg -o $@ -m map.txt $^

out/res.o: src/res.s $(RESOURCES)
	@mkdir -p $(@D)
	ca65 -g -o $@ $<

out/%.o: src/%.s src/*.inc.s
	@mkdir -p $(@D)
	ca65 -g -o $@ $<

out/%.bin: res/%.png
	@mkdir -p $(@D)
	./tobin.py $@ $<

.PHONY: clean
clean:
	rm -rf out $(ROM) map.txt

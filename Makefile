PREFIX ?= $(HOME)/.local
BIN := menu-items

build:
	swift build -c release

test:
	swift test

install: build
	install -d $(PREFIX)/bin
	install .build/release/$(BIN) $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)

release:
	swift build -c release --arch arm64 --arch x86_64
	mkdir -p dist
	cp "$$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/$(BIN)" dist/$(BIN)
	tar -czf dist/$(BIN)-macos-universal.tar.gz -C dist $(BIN)

clean:
	rm -rf .build dist

.PHONY: build test install uninstall release clean

VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
LDFLAGS := -s -w -X main.version=$(VERSION)

.PHONY: build clean test readme-screenshot check-readme-screenshot

build:
	go build -ldflags "$(LDFLAGS)" -o node-monitor .

test:
	go test ./... -v

readme-screenshot:
	@scripts/render-readme-tui.sh

check-readme-screenshot:
	@scripts/render-readme-tui.sh --check

clean:
	rm -f node-monitor

install: build
	cp node-monitor ~/.local/bin/node-monitor

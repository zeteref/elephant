PREFIX ?= $(HOME)/.local
DESTDIR ?=
BINDIR = $(DESTDIR)$(PREFIX)/bin
LICENSEDIR = $(DESTDIR)$(PREFIX)/share/licenses/elephant
CONFIGDIR = $(DESTDIR)$(HOME)/.config/elephant/providers

# Build configuration
GO_BUILD_FLAGS = -buildvcs=false -trimpath
BUILD_DIR = cmd/elephant

# Providers
PROVIDERS_MAKEFILES = $(wildcard internal/providers/*/makefile)
PROVIDER_DIRS = $(patsubst %/makefile,%,$(PROVIDERS_MAKEFILES))

.PHONY: all build build-providers install uninstall clean

all: build build-providers

build:
	cd $(BUILD_DIR) && go build $(GO_BUILD_FLAGS) -o elephant

build-providers:
	@for dir in $(PROVIDER_DIRS); do \
		echo "Building provider in $$dir..."; \
		$(MAKE) -C $$dir; \
	done

install: all
	install -Dm 755 $(BUILD_DIR)/elephant $(BINDIR)/elephant
	@mkdir -p $(CONFIGDIR)
	@for dir in $(PROVIDER_DIRS); do \
		echo "Installing provider from $$dir..."; \
		install -Dm 755 $$dir/*.so $(CONFIGDIR)/; \
	done

uninstall:
	rm -f $(BINDIR)/elephant
	rm -rf $(CONFIGDIR)

clean:
	cd $(BUILD_DIR) && go clean
	rm -f $(BUILD_DIR)/elephant
	@for dir in $(PROVIDER_DIRS); do \
		$(MAKE) -C $$dir clean; \
	done

dev-install: install

help:
	@echo "Available targets:"
	@echo "  all             - Build the application and all providers (default)"
	@echo "  build           - Build the application"
	@echo "  build-providers - Build all providers"
	@echo "  install         - Install the application and all providers"
	@echo "  uninstall       - Remove installed files"
	@echo "  clean           - Clean build artifacts"
	@echo "  help            - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX    - Installation prefix (default: ~/.local)"
	@echo "  DESTDIR   - Destination directory for staged installs"
	@echo "  CONFIGDIR - Directory for provider .so files (default: ~/.config/elephant/providers)"

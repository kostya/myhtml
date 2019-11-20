CRYSTAL ?= crystal
CRYSTALFLAGS ?=

.PHONY: all package spec
all: bin_usage bin_print_tree bin_links bin_texts bin_encoding bin_print_html bin_css_selectors1 bin_css_selectors2
package: src/ext/lexbor-c/liblexbor_static.a

bin_usage: src/*.cr src/**/*.cr examples/usage.cr package
	$(CRYSTAL) build examples/usage.cr $(CRYSTALFLAGS) -o $@

bin_css_selectors1: src/*.cr src/**/*.cr examples/css_selectors1.cr package
	$(CRYSTAL) build examples/css_selectors1.cr $(CRYSTALFLAGS) -o $@

bin_css_selectors2: src/*.cr src/**/*.cr examples/css_selectors2.cr package
	$(CRYSTAL) build examples/css_selectors2.cr $(CRYSTALFLAGS) -o $@

bin_print_tree: src/*.cr src/**/*.cr examples/print_tree.cr package
	$(CRYSTAL) build examples/print_tree.cr $(CRYSTALFLAGS) -o $@

bin_links: src/*.cr src/**/*.cr examples/links.cr package
	$(CRYSTAL) build examples/links.cr $(CRYSTALFLAGS) -o $@

bin_texts: src/*.cr src/**/*.cr examples/texts.cr package
	$(CRYSTAL) build examples/texts.cr $(CRYSTALFLAGS) -o $@

bin_encoding: src/*.cr src/**/*.cr examples/encoding.cr package
	  $(CRYSTAL) build examples/encoding.cr $(CRYSTALFLAGS) -o $@

bin_print_html: src/*.cr src/**/*.cr examples/print_html.cr package
		$(CRYSTAL) build examples/print_html.cr $(CRYSTALFLAGS) -o $@

src/ext/lexbor-c/liblexbor_static.a:
	cd src/ext && make package

spec:
	crystal spec

.PHONY: clean
clean:
	rm -f bin_* src/ext/lexbor-c/liblexbor_static.a
	rm -rf ./src/ext/lexbor-c

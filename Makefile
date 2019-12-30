CRYSTAL ?= crystal
CRYSTALFLAGS ?=

.PHONY: package spec
ackage: src/ext/lexbor-c/build/liblexbor_static.a

src/ext/lexbor-c/build/liblexbor_static.a:
	cd src/ext && make package

spec:
	crystal spec

.PHONY: clean
clean:
	rm -f bin_* src/ext/lexbor-c/build/liblexbor_static.a
	rm -rf ./src/ext/lexbor-c

REV := 79ddf7b683157fdb019d544581fe94aa235d3cc7

.PHONY: package
package: ./modest-c/lib/libmodest_static.a

./modest-c:
	git clone https://github.com/kostya/Modest-1.git ./modest-c
	cd modest-c && git reset --hard $(REV)

./modest-c/lib/libmodest_static.a: ./modest-c
	cd modest-c && make static MyHTML_BUILD_SHARED=OFF MyCORE_BUILD_WITHOUT_THREADS=YES PROJECT_OPTIMIZATION_LEVEL=-O3 -j 4

.PHONY: clean
clean:
	rm -rf modest-c

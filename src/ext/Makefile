REV := 4c03bfc2a04763d803e6a23eb10605e864ad1f59

.PHONY: package
package: ./lexbor-c/build/liblexbor_static.a

./lexbor-c:
	# git clone https://github.com/lexbor/lexbor.git --depth 1 ./lexbor-c
	git clone https://github.com/lexbor/lexbor.git ./lexbor-c
	# cd lexbor-c && git reset --hard $(REV)

./lexbor-c/build/liblexbor_static.a: ./lexbor-c
	cd ./lexbor-c && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make lexbor_static -j2

.PHONY: clean
clean:
	rm -rf ./lexbor-c

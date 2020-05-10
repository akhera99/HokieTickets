all: clean hokipoki.wasm deploy

clean:
	-rm *.wasm *.abi

hokipoki.wasm: hokipoki.cpp
	eosio-cpp -abigen -o hokipoki.wasm hokipoki.cpp

deploy:
	cleos set contract hokipoki . -p hokipoki@active

.PHONY: clean deploy all

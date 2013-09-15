all: test example doc

example:
	cd example && openfl test mac -debug -Ddebug
test:
	haxelib run munit gen
	openfl test cpp -DrunTest

doc:
	openfl build cpp -xml -DrunDoc
	cd doc && haxedoc ../buildDoc/mac/cpp/types.xml
clean:
	rm -rf buildTest
	rm -rf buildDoc
	rm -rf example/Export
	-rm doc/index.html
	rm -rf doc/content

help:
	@echo '[all]     run all'
	@echo 'test      run munit tests'
	@echo 'doc       generate api docs under doc/index.html'
	@echo 'example   build example app and start it'
	@echo 'clean     clean build files'

.PHONY: all test example doc clean help

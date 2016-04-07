all:	clean
	@mkdir -p ./bin
	@cd	./src && javac -cp \
		./Compiler/Library/antlr-4.5-complete.jar \
		./Compiler/*/*/*/*.java \
		./Compiler/*/*/*.java \
		./Compiler/*/*.java \
		./Compiler/*.java \
	-d ../bin
	@cp	./src/Compiler/Library/antlr-4.5-complete.jar ./bin
	@cd	./bin	&& jar xf ./antlr-4.5-complete.jar \
			&& jar cef Compiler/Main Compiler.jar ./

clean:
	rm -rf ./bin

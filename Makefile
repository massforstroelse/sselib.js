REPORTER = spec
TESTS = test/*.js

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--require should \
		--reporter $(REPORTER) \
		$(TESTS)

test-w:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		--require should \
		--growl \
		--watch \
		$(TESTS)

compile:
	./node_modules/.bin/coffee \
		--compile \
		--bare \
		--output ./ \
		./src/

prepare: | compile test

.PHONY: compile test test-w
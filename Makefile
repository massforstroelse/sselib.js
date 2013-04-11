REPORTER = dot

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
	--reporter $(REPORTER) \

test-w:
	@NODE_ENV=test ./node_modules/.bin/mocha \
	--reporter $(REPORTER) \
	--growl \
	--watch

compile:
	./node_modules/.bin/coffee \
	--compile \
	--bare \
	--output ./ \
	./src/

.PHONY: compile test test-w
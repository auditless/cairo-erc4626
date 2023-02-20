build: FORCE
	scarb build

fmt: FORCE
	scarb fmt

deps: FORCE
	cargo +nightly install cairo-lang-test-runner

test: FORCE
	cairo-test -p .

FORCE:

build: FORCE
	scarb build

fmt: FORCE
	scarb fmt

test: FORCE
	cairo-test -p .

FORCE:

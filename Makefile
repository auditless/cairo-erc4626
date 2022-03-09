compile: FORCE
	poetry run nile compile dependencies/erc4626/**/*.cairo

test: FORCE
	poetry run pytest

format: FORCE
	poetry run black tests

lint: FORCE
	poetry run mypy tests

FORCE:

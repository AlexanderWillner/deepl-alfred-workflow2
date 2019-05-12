SHELL=bash

help:
	@echo "Some available commands:"
	@echo " * workflow : create workflow"
	@echo " * bats     : run dynamic tests"
	@echo " * test     : test shell scripts"
	@echo " * style    : style shell scripts"
	@echo " * harden   : harden shell scripts"
	@echo " * feedback : create a GitHub issue"

workflow:
	@rm -f Deepl-Translate.alfredworkflow
	@zip Deepl-Translate.alfredworkflow icon.png info.plist deepl.sh jq-dist jq-LICENSE
	
feedback:
	@open https://github.com/alexanderwillner/deepl-alfred-workflow2/issues
		
bats:
	@echo "Running dynamic tests..."
	@type bats >/dev/null 2>&1 || (echo "Run 'brew install bats-core' first." >&2 ; exit 1)
	@bats deepl.bats

test:
	@echo "Running first round of shell checks..."
	@type shellcheck >/dev/null 2>&1 || (echo "Run 'brew install shellcheck' first." >&2 ; exit 1)
	@shellcheck -x *.sh
	@echo "Running second round of shell checks..."
	@type shellharden >/dev/null 2>&1 || (echo "Run 'brew install shellharden' first." >&2 ; exit 1)
	@shellharden --check deepl.sh

harden:
	@shellharden --replace deepl.sh
	
style:
	@type shfmt >/dev/null 2>&1 || (echo "Run 'brew install shfmt' first." >&2 ; exit 1)
	@shfmt -i 2 -w -s *.sh

.PHONY: workflow feedback bats test harden style

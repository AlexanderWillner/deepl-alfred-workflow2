SCRIPT=./runMojaveVirtualbox.sh
SHELL=bash

help:
	@echo "Some available commands:"
	@echo " * workflow : create workflow"
	@echo " * test     : test shell scripts"
	@echo " * style    : style shell scripts"
	@echo " * harden   : harden shell scripts"
	@echo " * feedback : create a GitHub issue"

workflow:
	@rm -f Deepl-Translate.alfredworkflow
	@zip Deepl-Translate.alfredworkflow icon.png info.plist deepl.sh
	
feedback:
	@open https://github.com/alexanderwillner/runMacOSinVirtualBox/issues
		
test: dependencies
	@echo "Running first round of shell checks..."
	@shellcheck -x *.sh
	@echo "Running second round of shell checks..."
	@shellharden --check deepl.sh

harden: dependencies
	@shellharden --replace deepl.sh
	
style: dependencies
	@shfmt -i 2 -w -s *.sh

dependencies:
	@type shellcheck >/dev/null 2>&1 || (echo "Run 'brew install shellcheck' first." >&2 ; exit 1)
	@type shellharden >/dev/null 2>&1 || (echo "Run 'brew install shellharden' first." >&2 ; exit 1)
	@type shfmt >/dev/null 2>&1 || (echo "Run 'brew install shfmt' first." >&2 ; exit 1)

.PHONY: workflow feedback test harden style check dependencies

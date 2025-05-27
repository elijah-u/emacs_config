EMACS ?= emacs
CONFIG ?= config.org
CURDIR := $(shell pwd)

.PHONY: all bootstrap clean-packages clean-all clean help 

all: bootstrap

bootstrap:
	@echo "Tangling org configuration..."
	$(EMACS) --batch -l org --eval '(org-babel-tangle-file "$(CONFIG)")'
	@echo "Bootstrap complete."

clean-packages:
	rm -rf ./elpaca
	@echo "All packages in ./elpaca/ cleared."

clean-all:
	@echo "Removing all files/dirs except .git, .gitignore, config.org, Makefile..."
	@find . -mindepth 1 -maxdepth 1 \
	  ! -name '.git' \
	  ! -name '.gitignore' \
	  ! -name 'config.org' \
	  ! -name 'Makefile' \
	  -exec rm -rf {} +
	@echo "Clean-all complete."

clean: clean-packages
	rm -f ./init.el ./early-init.el ./lisp/*.el
	@echo "Configuration cleaned. Only config.org and Makefile remain."

help:
	@echo "Emacs Configuration Management:"
	@echo ""
	@echo "  make bootstrap        Tangle and set up the Emacs configuration from config.org."
	@echo "  make clean-packages   Remove all installed packages (forces reinstallation on next bootstrap)."
	@echo "  make clean            Remove all generated configuration files, leaving only config.org and Makefile."
	@echo "  make help             Show this help message."

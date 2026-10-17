# Makefile to run Emacs script for tangling Org mode files

# Define a variable to hold the name of the Org file
ORG_FILE = config.org

# default target
all: tangle

# Target to tangle the Org file
tangle:
	emacs --batch -l org --eval '(org-babel-tangle-file "$(ORG_FILE)")'

# Clean target (optional)
clean:
	rm -f *.elc *.o # add any specific files you want to clean

.PHONY: all tangle clean

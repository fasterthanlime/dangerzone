
all:
	@echo "Muffin to see here."

osx:
	rock -v +-Os -g --cc=clang +-headerpad_max_install_names

.PHONY: all osx

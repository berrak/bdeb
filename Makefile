NAME=bdeb
VERSION=0.1

DIRS=etc lib bin sbin share
INSTALL_DIRS=`find $(DIRS) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f 2>/dev/null`
DOC_FILES=*.txt

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
SIG=$(PKG_DIR)/$(PKG_NAME).asc

DESTDIR?=/usr/local
DOC_DIR=$(DESTDIR)/share/doc/$(PKG_NAME)

pkg:
	rm -fr $(PKG_DIR)
	mkdir -p $(PKG_DIR)

$(PKG): pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

build: $(PKG)

$(SIG): $(PKG)
	gpg --sign --detach-sign --armor $(PKG)

sign: $(SIG)

clean:
	rm -f $(PKG) $(SIG)
	rm -fr $(PKG_DIR)

all: $(PKG) $(SIG)

test:

tag:
	git tag -a -m "New release" v$(VERSION)
	git push --tags

release: $(PKG) $(SIG) tag

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(DESTDIR)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(DESTDIR)/$$file; done
	mkdir -p $(DOC_DIR)
	cp -r $(DOC_FILES) $(DOC_DIR)/

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(DESTDIR)/$$file; done
	rm -rf $(DOC_DIR)


.PHONY: build sign clean test tag release install uninstall all
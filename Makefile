prefix ?= $(HOME)
bindir ?= $(prefix)/bin
docdir ?= $(prefix)/share/doc/vx

INSTALL ?= install

install::
	$(INSTALL) -d -m 755 '$(DESTDIR)$(bindir)'
	$(INSTALL) -d -m 755 '$(DESTDIR)$(docdir)'
	$(INSTALL) vx '$(DESTDIR)$(bindir)'
	$(INSTALL) -m 644 README.md LICENSE '$(DESTDIR)$(docdir)'

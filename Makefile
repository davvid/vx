prefix ?= $(HOME)
bindir ?= $(prefix)/bin
docdir ?= $(prefix)/share/doc/vx

INSTALL ?= install

# make test V=1 enables verbose output.
# make test V=2 enables trace mode.
ifdef V
    VERBOSE=$(V)
endif
ifdef VERBOSE
    TEST_OPTS += --verbose
    ifeq ($(VERBOSE),2)
        TEST_OPTS += -x
    endif
endif

install::
	$(INSTALL) -d -m 755 '$(DESTDIR)$(bindir)'
	$(INSTALL) -d -m 755 '$(DESTDIR)$(docdir)'
	$(INSTALL) vx '$(DESTDIR)$(bindir)'
	$(INSTALL) -m 644 README.md LICENSE '$(DESTDIR)$(docdir)'

test::
	./test.sh $(TEST_OPTS) $(flags)

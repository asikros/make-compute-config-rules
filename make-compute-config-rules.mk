# Config
export

# Constants
NAME ?= $(error ERROR: Undefined variable NAME)
VERSION ?= $(error ERROR: Undefined variable VERSION)

DESTDIR ?= $(error ERROR: Undefined variable DESTDIR)
HOMEDIR ?= $(error ERROR: Undefined variable HOMEDIR)
PREFIX ?= $(error ERROR: Undefined variable PREFIX)
BINDIR ?= $(error ERROR: Undefined variable BINDIR)
DATADIR ?= $(error ERROR: Undefined variable DATADIR)
LIBDIR ?= $(error ERROR: Undefined variable LIBDIR)

SRCDIR_ROOT ?= $(error ERROR: Undefined variable SRCDIR_ROOT)
WORKDIR_ROOT ?= $(error ERROR: Undefined variable WORKDIR_ROOT)
WORKDIR_DEPS ?= $(error ERROR: Undefined variable WORKDIR_DEPS)

override PKGSUBDIR = $(NAME)/$(SRCDIR_ROOT)
override BINDIR_FILES := $(shell (cd $(SRCDIR_ROOT)/bin  && find . -type f) 2>/dev/null)
override DATADIR_FILES := $(shell (cd $(SRCDIR_ROOT)/data  && find . -type f) 2>/dev/null)
override HOMEDIR_FILES := $(shell (cd $(SRCDIR_ROOT)/home  && find . -type f) 2>>/dev/null)

# Error checking
ifneq ($(DESTDIR), $(abspath $(DESTDIR)))
$(error ERROR: Please specify DESTDIR as an absolute path)
endif


# Targets
.PHONY: private_install
private_install: \
			$(foreach f, $(BINDIR_FILES), $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/bin/$(f) $(DESTDIR)/$(BINDIR)/$(f)) \
			$(foreach f, $(DATADIR_FILES), $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/data/$(f) $(DESTDIR)/$(DATADIR)/$(f)) \
			$(foreach f, $(HOMEDIR_FILES), $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/home/$(f) $(DESTDIR)/$(HOMEDIR)/$(f))
	@$(if $(wildcard $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/bin), diff -r $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/bin $(SRCDIR_ROOT)/bin)
	@$(if $(wildcard $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/data), diff -r $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/data $(SRCDIR_ROOT)/data)
	@$(if $(wildcard $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/home), diff -r $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/home $(SRCDIR_ROOT)/home)
	@echo "INFO: Installation complete"
	@echo

$(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/%: $(SRCDIR_ROOT)/%
	$(bowerbird::install-as-copy)

$(DESTDIR)/$(BINDIR)/%: $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/bin/%
	$(bowerbird::install-as-link)

$(DESTDIR)/$(DATADIR)/%: $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/data/%
	$(bowerbird::install-as-link)

$(DESTDIR)/$(HOMEDIR)/%: $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)/home/%
	$(bowerbird::install-as-link)


.PHONY: private_uninstall
private_uninstall:
	@echo "INFO: Uninstalling $(NAME)"
	@$(foreach s, $(BINDIR_FILES), \
		rm -v $(DESTDIR)/$(BINDIR)/$(s); \
		test ! -e $(DESTDIR)/$(BINDIR)/$(s); \
		rm -dv $(dir $(DESTDIR)/$(BINDIR)/$(s)) 2> /dev/null || true; \
	)
	@$(foreach s, $(DATADIR_FILES), \
		rm -v $(DESTDIR)/$(DATADIR)/$(s); \
		test ! -e $(DESTDIR)/$(DATADIR)/$(s); \
		rm -dv $(dir $(DESTDIR)/$(DATADIR)/$(s)) 2> /dev/null || true; \
	)
	@$(foreach s, $(HOMEDIR_FILES), \
		rm -v $(DESTDIR)/$(HOMEDIR)/$(s); \
		test ! -e $(DESTDIR)/$(HOMEDIR)/$(s); \
		rm -dv $(dir $(DESTDIR)/$(HOMEDIR)/$(s)) 2> /dev/null || true; \
	)
	@\rm -rdfv $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR) 2> /dev/null || true
	@\rm -dv $(dir $(DESTDIR)/$(LIBDIR)/$(PKGSUBDIR)) 2> /dev/null || true
	@\rm -dv $(DESTDIR)/$(LIBDIR) 2> /dev/null || true
	@echo "INFO: Uninstallation complete"
	@echo

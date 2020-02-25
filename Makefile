include /usr/share/dpkg/pkg-info.mk

PACKAGE=haproxy-defender

SRCDIR=haproxy
BUILDDIR=haproxy-defender

GITVERSION:=$(shell git rev-parse HEAD)

DEB=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}_all.deb

all: ${DEB}
	@echo ${DEB}

.PHONY: submodule
submodule:
	test -f "${SRCDIR}/debian/changelog" || git submodule update --init

buildir: ${BUILDDIR}
${BUILDDIR}: submodule
	rm -rf $(BUILDDIR)
	mkdir $(BUILDDIR)
	cp -a $(SRCDIR)/* $(BUILDDIR)/
	cp -R debian $(BUILDDIR)/
	mkdir $(BUILDDIR)/contrib/mod_defender/mod_defender_src
	cp -R mod_defender/* $(BUILDDIR)/contrib/mod_defender/mod_defender_src

.PHONY: deb
deb: ${DEB}
${DEB}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -rfakeroot -b -uc -us

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB} | ssh -X repoman@repo.proxmox.com -- upload --product pve --dist stretch

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf ${PACKAGE}/ *.deb *.changes *.dsc *.buildinfo

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

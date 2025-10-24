FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://first-boot.sh \
    file://usb-gadget.sh \
    file://gem-finish.sh \
    file://disk-links.sh \
    file://swu-partconf.sh \
    "

do_install:append() {
    install -m 0755 ${WORKDIR}/usb-gadget.sh ${D}/init.d/86-usbgadget
    install -m 0755 ${WORKDIR}/first-boot.sh ${D}/init.d/87-firstboot
    install -m 0755 ${WORKDIR}/disk-links.sh ${D}/init.d/88-disklinks
    install -m 0755 ${WORKDIR}/swu-partconf.sh ${D}/init.d/89-swupartconf
    install -m 0755 ${WORKDIR}/gem-finish.sh ${D}/init.d/98-gemfinish
}

PACKAGES += "initramfs-module-usbgadget initramfs-module-firstboot initramfs-module-disklinks initramfs-module-swupartconf initramfs-module-gemfinish"

RDEPENDS:initramfs-module-usbgadget = "${PN}-base"
RDEPENDS:initramfs-module-firstboot = "${PN}-base initramfs-module-rootfs"
RDEPENDS:initramfs-module-disklinks = "${PN}-base"
RDEPENDS:initramfs-module-swupartconf = "${PN}-base initramfs-module-disklinks"
RDEPENDS:initramfs-module-gemfinish = "${PN}-base"

FILES:initramfs-module-usbgadget = "/init.d/86-usbgadget"
FILES:initramfs-module-firstboot = "/init.d/87-firstboot"
FILES:initramfs-module-disklinks = "/init.d/88-disklinks"
FILES:initramfs-module-swupartconf = "/init.d/89-swupartconf"
FILES:initramfs-module-gemfinish = "/init.d/98-gemfinish"

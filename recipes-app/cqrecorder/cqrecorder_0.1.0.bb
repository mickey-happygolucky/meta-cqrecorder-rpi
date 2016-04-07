SUMMARY = "CQ Recorder application scritps"
DESCRIPTION = "CQ Recorder provides scripts for control the recorder board on RaspberryPi2. These scripts include recoding, playing,file selecting controls, and startup scripts."
SECTION = "applications"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
PR = "1"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "file://recorder.sh \
	   file://player.sh \
	   file://selector.sh \
	   file://recorder \
"

S = "${WORKDIR}"

DEPENDS_append = " update-rc.d-native"


do_install() {
#
# Install recorder control scripts.
#
	install -d ${D}/${bindir}
	install -m 0755    ${WORKDIR}/recorder.sh	${D}${bindir}
	install -m 0755    ${WORKDIR}/player.sh		${D}${bindir}
	install -m 0755    ${WORKDIR}/selector.sh	${D}${bindir}

#
# Install a startup script.
#
	install -d ${D}${sysconfdir}/init.d
	install -d ${D}${sysconfdir}/rcS.d
	install -d ${D}${sysconfdir}/rc0.d
	install -d ${D}${sysconfdir}/rc1.d
	install -d ${D}${sysconfdir}/rc2.d
	install -d ${D}${sysconfdir}/rc3.d
	install -d ${D}${sysconfdir}/rc4.d
	install -d ${D}${sysconfdir}/rc5.d
	install -d ${D}${sysconfdir}/rc6.d

	install -m 0755    ${WORKDIR}/recorder	${D}${sysconfdir}/init.d
	update-rc.d -r ${D} recorder start 80 2 3 4 5 .
}
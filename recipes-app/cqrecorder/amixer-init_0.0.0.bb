LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

S = "${WORKDIR}"

FILES_${PN} = "${sysconfdir}/profile.d"

S = "${WORKDIR}"

# NOTE: no Makefile found, unable to determine what needs to be done
do_install () {
	# Specify install commands here
	install -d ${D}${sysconfdir}
	install -d ${D}${sysconfdir}/profile.d
	echo "#!/bin/sh" > ${D}${sysconfdir}/profile.d/amixier-setting.sh
	echo "" >> ${D}${sysconfdir}/profile.d/amixier-setting.sh
	echo "amixer cset numid=7 45 > /dev/null" >> ${D}${sysconfdir}/profile.d/amixier-setting.sh
	echo "amixer cset numid=1 127 > /dev/null" >> ${D}${sysconfdir}/profile.d/amixier-setting.sh
}

inherit xsctbase

EMBEDDEDSW_REPO ??= "git://github.com/Xilinx/embeddedsw.git;protocol=https"
EMBEDDEDSW_BRANCH ??= "release-2019.1"
EMBEDDEDSW_SRCREV ??= "26c14d9861010a0e3a55c73fb79efdb816eb42ca"


EMBEDDEDSW_BRANCHARG ?= "${@['nobranch=1', 'branch=${EMBEDDEDSW_BRANCH}'][d.getVar('EMBEDDEDSW_BRANCH', True) != '']}"
EMBEDDEDSW_SRCURI ?= "${EMBEDDEDSW_REPO};${EMBEDDEDSW_BRANCHARG}"

PACKAGE_ARCH ?= "${MACHINE_ARCH}"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://license.txt;md5=e9b6d01d45faccfbf05d8caea53f0a35"

SRC_URI = "${EMBEDDEDSW_SRCURI}"
SRCREV = "${EMBEDDEDSW_SRCREV}"
PV = "${XILINX_VER_MAIN}+git${SRCPV}"
S = "${WORKDIR}/git"

XSCTH_BASE_NAME ?= "${PN}${PKGE}-${PKGV}-${PKGR}-${MACHINE}-${DATETIME}"
XSCTH_BASE_NAME[vardepsexclude] = "DATETIME"

FILESEXTRAPATHS_append := ":${XLNX_SCRIPTS_DIR}"
SRC_URI_append = " file://app.tcl"
XSCTH_SCRIPT ?= "${WORKDIR}/app.tcl"

XSCTH_BUILD_DEBUG ?= "0"
XSCTH_BUILD_CONFIG ?= "${@['Debug', 'Release'][d.getVar('XSCTH_BUILD_DEBUG', True) == "0"]}"
XSCTH_APP_COMPILER_FLAGS ?= ""

SYSROOT_DIRS += "/boot"

do_compile[lockfiles] = "${TMPDIR}/xsct-invoke.lock"
do_compile() {

    cd ${B}/${XSCTH_PROJ}
    make
    if [ ! -e ${B}/${XSCTH_PROJ}/${XSCTH_EXECUTABLE} ]; then
        bbfatal_log "${XSCTH_PROJ} compile failed."
    fi
}

do_install() {
    install -Dm 0644 ${B}/${XSCTH_PROJ}/${XSCTH_EXECUTABLE} ${D}/boot/${PN}.elf
}

do_deploy() {
    install -Dm 0644 ${B}/${XSCTH_PROJ}/${XSCTH_EXECUTABLE} ${DEPLOYDIR}/${XSCTH_BASE_NAME}.elf
    ln -sf ${XSCTH_BASE_NAME}.elf ${DEPLOYDIR}/${PN}-${MACHINE}.elf
}
addtask do_deploy after do_compile

FILES_${PN} = "/boot/${PN}.elf"

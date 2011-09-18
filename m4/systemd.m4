# SYSTEMD_SYSTEM_UNITS_AC
# -----------------------
#
# A macro grabbing all information necessary to install systemd system
# units. It adds --with-systemdsystemunitdir (with defaults from
# pkg-config) and either gets the correct location for systemd system
# units or the request not to install them.
#
# If installing system units was requested, systemdsystemunitdir will be
# substituted with a correct location; otherwise,
# $with_systemdsystemunitdir will be set to 'no'.
#
# This macro is intended for use only in specific projects not using
# automake. Projects using automake should use the non-AC variant instead.

AC_DEFUN([SYSTEMD_SYSTEM_UNITS_AC], [
	AC_REQUIRE([PKG_PROG_PKG_CONFIG])

	AC_ARG_WITH([systemdsystemunitdir],
		AS_HELP_STRING([--with-systemdsystemunitdir=DIR],
			[Directory for systemd service files (default: auto-detect through pkg-config)]))

	AC_MSG_CHECKING([where to install systemd system units])

	AS_IF([test x"$with_systemdsystemunitdir" = x"yes" -o x"$with_systemdsystemunitdir" = x""], [
		ac_systemd_def_systemunitdir=`$PKG_CONFIG --variable=systemdsystemunitdir systemd`

		AS_IF([test x"$ac_systemd_def_systemunitdir" = x""], [
			AS_IF([test x"$with_systemdsystemunitdir" = x"yes"], [
				AC_MSG_ERROR([systemd support requested but pkg-config unable to query systemd package])
			])
			with_systemdsystemunitdir=no
		], [
			with_systemdsystemunitdir=$ac_systemd_def_systemunitdir
		])
	])

	AC_MSG_RESULT([$with_systemdsystemunitdir])

	AS_IF([test x"$with_systemdsystemunitdir" != x"no"], [
		AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
	])
])

# SYSTEMD_SYSTEM_UNITS
# --------------------
#
# An extended version of SYSTEMD_SYSTEM_UNITS_AC with automake support.
#
# In addition to substituting systemdsystemunitdir, it creates
# an automake conditional called WITH_SYSTEMD_SYSTEM_UNITS.
#
# Example use:
# - configure.ac:
#	SYSTEMD_SYSTEM_UNITS
# - Makefile.am:
#	if WITH_SYSTEMD_SYSTEM_UNITS
#	dist_systemdsystemunit_DATA = foo.service
#	endif

AC_DEFUN([SYSTEMD_SYSTEM_UNITS], [
	AC_REQUIRE([SYSTEMD_SYSTEM_UNITS_AC])

	AM_CONDITIONAL([WITH_SYSTEMD_SYSTEM_UNITS],
		[test x"$with_systemdsystemunitdir" != x"no"])
])

# SYSTEMD_MISC
# ------------
#
# Declare miscellaneous (unconditional) directories used by systemd,
# and possibly other init systems.
#
# Declared directories:
# - binfmtdir (binfmt.d for binfmt_misc decl files),
# - modulesloaddir (modules-load.d for module loader).
# - sysctldir (sysctl.d for /proc/sys settings),
# - tmpfilesdir (tmpfiles.d for temporary file setup).
#
# Example use:
# - configure.ac:
#	AC_SYSTEMD_MISC
# - Makefile.am:
#	dist_binfmt_DATA = binfmt/foo.conf

AC_DEFUN([SYSTEMD_MISC], [
	AS_IF([test x"$prefix" = x"/"], [
		AC_SUBST([binfmtdir], [/usr/lib/binfmt.d])
		AC_SUBST([modulesloaddir], [/usr/lib/modules-load.d])
		AC_SUBST([sysctldir], [/usr/lib/sysctl.d])
		AC_SUBST([tmpfilesdir], [/usr/lib/tmpfiles.d])
	], [
		AC_SUBST([binfmtdir], ['${prefix}/lib/binfmt.d'])
		AC_SUBST([modulesloaddir], ['${prefix}/modules-load.d'])
		AC_SUBST([sysctldir], ['${prefix}/sysctl.d'])
		AC_SUBST([tmpfilesdir], ['${prefix}/tmpfiles.d'])
	])
])

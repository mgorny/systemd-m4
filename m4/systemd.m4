# AC_SYSTEMD_SYSTEM_UNITS
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
# automake. Projects using automake should use the AM_* variant instead.

AC_DEFUN([AC_SYSTEMD_SYSTEM_UNITS], [
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

# AM_SYSTEMD_SYSTEM_UNITS
# -----------------------
#
# An extended version of AC_SYSTEMD_SYSTEM_UNITS with automake support.
#
# In addition to substituting systemdsystemunitdir, it creates
# an automake conditional called WITH_SYSTEMD_SYSTEM_UNITS.
#
# Example use:
# - configure.ac:
#	AM_SYSTEMD_SYSTEM_UNITS
# - Makefile.am:
#	if WITH_SYSTEMD_SYSTEM_UNITS
#	dist_systemdsystemunit_DATA = foo.service
#	endif

AC_DEFUN([AM_SYSTEMD_SYSTEM_UNITS], [
	AC_REQUIRE([AC_SYSTEMD_SYSTEM_UNITS])

	AM_CONDITIONAL([WITH_SYSTEMD_SYSTEM_UNITS],
		[test x"$with_systemdsystemunitdir" != x"no"])
])

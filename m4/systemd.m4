# AM_SYSTEMD_SYSTEM_UNITS
# -----------------------
#
# A macro grabbing all information necessary to install systemd system
# units. It adds --with-systemdsystemunitdir (with defaults from
# pkg-config) and either gets the correct location for systemd system
# units or the request not to install them.
#
# The result of these checks is stored in WITH_SYSTEMD_SYSTEM_UNITS
# automake conditional. If installing system units was requested,
# systemdsystemunitdir is set to a correct location as well.
#
# Example use:
# - configure.ac:
#	AM_SYSTEMD_SYSTEM_UNITS
# - Makefile.am:
#	if WITH_SYSTEMD_SYSTEM_UNITS
#	dist_systemdsystemunit_DATA = foo.service
#	endif

AC_DEFUN([AM_SYSTEMD_SYSTEM_UNITS], [
	AC_REQUIRE([PKG_PROG_PKG_CONFIG])

	AC_ARG_WITH([systemdsystemunitdir],
		AS_HELP_STRING([--with-systemdsystemunitdir=DIR],
			[Directory for systemd service files (default: auto-detect through pkg-config)]))

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

	AS_IF([test x"$with_systemdsystemunitdir" != x"no"], [
		AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
	])
	AM_CONDITIONAL([WITH_SYSTEMD_SYSTEM_UNITS],
		[test x"$with_systemdsystemunitdir" != x"no"])
])

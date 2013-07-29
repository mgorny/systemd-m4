# SYSTEMD_DIRECTORY_AC(directory-variable, directory-description)
# ---------------------------------------------------------------
#
# A generic macro that obtains one of the systemd directories defined
# in systemd.pc. It adds --with-$1 configure option and tries to
# obtain the default from pkg-config.
#
# If any location was found or given, the name given as $1 will be
# substituted with it. Otherwise, $with_[$1] will be set to 'no'.

AC_DEFUN([SYSTEMD_DIRECTORY_AC], [
	AC_REQUIRE([PKG_PROG_PKG_CONFIG])

	AC_ARG_WITH([$1],
		AS_HELP_STRING([--with-$1=DIR],
			[Directory for $2 (default: auto-detect through pkg-config)]))

	AC_MSG_CHECKING([where to install $2])

	AS_IF([test x"$with_$1" = x"yes" -o x"$with_$1" = x""], [
		ac_systemd_pkgconfig_dir=`$PKG_CONFIG --variable=$1 systemd`

		AS_IF([test x"$ac_systemd_pkgconfig_dir" = x""], [
			AS_IF([test x"$with_$1" = x"yes"], [
				AC_MSG_ERROR([systemd support requested but pkg-config unable to query systemd package])
			])
			with_$1=no
		], [
			with_$1=$ac_systemd_pkgconfig_dir
		])
	])

	AC_MSG_RESULT([$with_$1])

	AS_IF([test x"$with_$1" != x"no"], [
		AC_SUBST([$1], [$with_$1])
	])
])

# SYSTEMD_DIRECTORY_AM(directory-variable)
# ---------------------------------------------------------------
#
# Defines WITH_$1 automake macro if directory was set through
# --with-$1 or obtained from pkg-config.

AC_DEFUN([SYSTEMD_DIRECTORY_AM], [
	m4_pushdef([AM_MACRO], WITH_[]m4_toupper([$1]))
	AM_CONDITIONAL(AM_MACRO,
		[test x"$with_$1" != x"no"])
	m4_popdef([AM_MACRO])
])

# SYSTEMD_SYSTEMUNITDIR_AC
# ------------------------
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

AC_DEFUN([SYSTEMD_SYSTEMUNITDIR_AC], [
	SYSTEMD_DIRECTORY_AC([systemdsystemunitdir], [systemd system units])
])

# SYSTEMD_SYSTEMUNITDIR
# ---------------------
#
# An extended version of SYSTEMD_SYSTEMUNITDIR_AC with automake support.
#
# In addition to substituting systemdsystemunitdir, it creates
# an automake conditional called WITH_SYSTEMDSYSTEMUNITDIR.
#
# Example use:
# - configure.ac:
#	SYSTEMD_SYSTEMUNITDIR
# - Makefile.am:
#	if WITH_SYSTEMDSYSTEMUNITDIR
#	dist_systemdsystemunit_DATA = foo.service
#	endif

AC_DEFUN([SYSTEMD_SYSTEMUNITDIR], [
	AC_REQUIRE([SYSTEMD_SYSTEMUNITDIR_AC])
	SYSTEMD_DIRECTORY_AM([systemdsystemunitdir])
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
#	SYSTEMD_MISC
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


# Obsolete macros.
AU_ALIAS([SYSTEMD_SYSTEM_UNITS_AC], [SYSTEMD_SYSTEMUNITDIR_AC])
AU_DEFUN([SYSTEMD_SYSTEM_UNITS], [
	SYSTEMD_SYSTEMUNITDIR

	AM_CONDITIONAL([WITH_SYSTEMD_SYSTEM_UNITS],
		[test x"$with_systemdsystemunitdir" != x"no"])
], [Please replace WITH_SYSTEMD_SYSTEM_UNITS automake conditionals with WITH_SYSTEMDSYSTEMUNITDIR and drop the definition of the former.])

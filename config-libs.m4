AC_CHECK_HEADERS([glk.h],
  [],
  [AC_MSG_ERROR([Could not find glk.h header. Try setting the include path location using: 'CPPFLAGS="-I<includedir>" configure'])
  ])

AC_CHECK_HEADERS([glkstart.h],
  [],
  [AC_MSG_ERROR([Could not find glkstart.h header. Try setting the include path location using: 'configure CPPFLAGS="-I<includedir>"'])
  ],
  [#ifdef HAVE_GLK_H
  #  include <glk.h>
  #endif
  ])

# Ideally, we could use AC_CHECK_LIB([remglk], [glkunix_stream_open_pathname]),
# but remglk (a) defines its own main(), and (b) requires us to define a small
# number of specific functions that AC_CHECK_LIB() has no way to inject.  So,
# we have to use lower-level autoconf functionality to provide a complete test
# source file.
#
# The implementation of AC_CHECK_LIB() temporarily adds the library to LIBS,
# does the link, re-sets LIBS, and then re-adds the library back to LIBS if
# the link was successful.  Rather than remove/re-add, we leave it in place,
# and only do the reset on failure (even though we'll also then fail out).

AC_MSG_CHECKING([for glkunix_stream_open_pathname in -lremglk])

remglk_save_LIBS=$LIBS
LIBS="-lremglk $LIBS"

AC_LINK_IFELSE([AC_LANG_SOURCE(
  [[#ifdef __cplusplus
    extern "C"
    #endif
    #ifdef HAVE_GLK_H
    #  include <glk.h>
    #endif
    #ifdef HAVE_GLKSTART_H
    #  include <glkstart.h>
    #endif

    glkunix_argumentlist_t glkunix_arguments[] = {
      { NULL, glkunix_arg_End, NULL }
    };

    void glk_main()
    {
      glkunix_stream_open_pathname((char *)0, (glui32)0, (glui32)0);
    }

    int glkunix_startup_code(glkunix_startup_t *data)
    {
      return 0;
    }
  ]])],
  [AC_MSG_RESULT(yes)
   cat >>confdefs.h <<_ACEOF
#define HAVE_LIBREMGLK 1
_ACEOF
  ],
  [AC_MSG_RESULT(no)
   LIBS=$remglk_save_LIBS
   AC_MSG_ERROR([Could not link with -lremglk. Try setting the location using: 'configure LDFLAGS="-L<libdir>"'.])
  ])

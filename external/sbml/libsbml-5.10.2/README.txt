
                            l i b S B M L

	    Sarah Keating, Frank Bergmann, Ben Bornstein,
            Akiya Jouraku, Lucian Smith and Michael Hucka
	   with contributions from (in alphabetical order):
     Gordon Ball, Bill Denney, Christoph Flamm, Akira Funahashi,
     Ralph Gauges, Martin Ginkel, Alex Gutteridge, Stefan Hoops,
    Totte Karlsson, Moriyoshi Koizumi, Ben Kovitz, Rainer Machne,
                 Nicolas Rodriguez, and many others.

  Please see the file NEWS.txt for a log of recent changes in libSBML

        More information about libSBML is available online at
                   http://sbml.org/Software/libSBML

       Please report problems with libSBML using the tracker at
            http://sbml.org/Software/libSBML/issue-tracker

  Mailing lists and online web forums for discussing libSBML are at
                        http://sbml.org/Forums

    To contact the core libSBML developers directly, send email to
		       libsbml-team@caltech.edu

   ,---------------------------------------------------------------.
  | Table of contents                                               |
  | 0. Foreword                                                     |
  | 1. What's new in this release?                                  |
  | 2. Quick start                                                  |
  | 3. Detailed instructions for configuring and installing LibSBML |
  | 4. Reporting bugs and other problems                            |
  | 5. Mailing lists                                                |
  | 6. Licensing and distribution                                   |
  | 7. Acknowledgments                                              |
   `---------------------------------------------------------------'



0. FOREWORD
======================================================================

Article citations are crucial to our academic careers.  If you use
libSBML and you publish papers about your software, we ask that you
please cite the libSBML paper:

  Bornstein, B. J., Keating, S. M., Jouraku, A., and Hucka M. (2008)
  LibSBML: An API Library for SBML. Bioinformatics, 24(6):880-881.


1. WHAT'S NEW IN THIS RELEASE?
======================================================================

Please see the file NEWS.txt for highlights about recent changes in
libSBML.  For a complete list of changes, please see the SVN revision
logs in the source code repository at

  https://sourceforge.net/p/sbml/code/HEAD/tree/trunk/libsbml/

(Click on the "History" button in the right-hand side of the dark
gray bar above the list of files.)


2. QUICK START
======================================================================

LibSBML is a library for reading, writing and manipulating files and
data streams containing the Systems Biology Markup Language (SBML).
The library supports all Levels and Versions of SBML, up to Level 3
Version 1 Core.  LibSBML is written in ISO standard C++ and C and
provides APIs for the languages C, C++, C#, Java, MATLAB, Octave,
Perl, Python, R and Ruby.  It works on Linux, Windows, and MacOS X,
and has been known to work on FreeBSD and Solaris in the past.


2.1 Precompiled binaries
-------------------------

Check the download site for libSBML on SourceForge.net for possible 
installation packages for your operating system. We supply 
ready-to-install precompiled binaries for many systems.

  http://sourceforge.net/projects/sbml/files/libsbml/


2.2 Configuring and building libSBML using CMake
------------------------------------------------

CMake is the preferred configuration and build system for libSBML.
CMake can be used on all platforms.  Using CMake is the only way to
configure and build libSBML with SBML Level 3 package extensions from
sources. (LibSBML without packages can still be built using the old
GNU configure and makefile system, discussed below.  The documentation
currently can only be built using the GNU scheme.)  Your system
probably already has CMake installed; if not, you can download a copy
from http://www.cmake.org/.

The simplest way to use CMake is to run the CMake GUI.  Start it as
you would any other application on your computer; once it is running,
click the "Browse Source" button in the upper right-hand corner, and
navigate to the libSBML source directory on your computer.
Alternatively, you can run "cmake-gui" in a terminal/shell window, in
which case, the easiest approach is to create a "build" directory in
your libSBML source tree, then run "cmake-gui" from there, as follows:

  mkdir build
  cd build/
  cmake-gui ..              # Note the ".." argument!

This will let it automatically find the source code and know where to
put the binaries it builds.  If you run cmake-gui in some other way,
you'll need to tell it the location of the source code (e.g.,
/your/path/to/libsbml-5.10.0-Source) and where to build the binaries
(e.g., /your/path/to/libsbml-5.10.0-Source/build/).

Next, click the "Configure" button.  The first time you do this for
libSBML, CMake will bring forth a dialog box asking you what scheme to
use to build libSBML.  On Unix, selecting "Unix Makefiles" and "Use
default native compilers" is probably a good option; on Windows,
Visual Studios or Cygwin/MSys will work.  Make sure to use the same
system as you are using for the software with which you will use
libSBML.  Click "Done" in the configuration panel to go back to the
original window and cause CMake do a first pass at configuration.

You will see many new options presented in the middle panel of the
CMake GUI.  These options will at first be highlighted in red.  The
options you most likely need to change are shown by default, including
the installation prefix (CMAKE_INSTALL_PREFIX), the XML parsing
library to use (one of WITH_LIBXML, WITH_EXPAT, or WITH_XERCES must be
checked), what language bindings to create (WITH_JAVA, WITH_MATLAB,
etc.), and which SBML Level 3 package extensions to include.  Some
additional options are available by clicking the "Advanced" checkbox.

Click "Configure" again.  Some new options may now become available,
and these will be highlighted in red; in addition, if there are any
unmet dependencies (such as the locations of libraries), they will
also be highlighted in red.  You may need to give CMake the location
of some dependent libraries.  If they are all installed in the same
place on your system, you need only fill in the
"LIBSBML_DEPENDENCY_DIR" option; if they are installed in different
places, you will need to fill out the individual *_INCLUDE_DIR and
*_LIBRARY options by hand. (CMake will search in obvious places first
to try to find them itself.)

Each time you give CMake more information, click the "Configure"
button, and CMake will use that information to continue configuring
your build.  Each time it adds a new option it has not shown before,
it will highlight that option in red.  If CMake lacks the information
it needs to complete the configuration, it will say "Error in
configuration process, project files may be invalid".

Once "Configure" makes it through with no errors, the "Generate"
button in the GUI will become enabled.  Clicking the "Generate" button
will create the necessary files for whatever build system you
selected; for example, makefiles will be generated if you chose Unix
makefiles, or a "libsbml.sln" file will be created for Visual Studio.

Once configured, you can build libSBML using the scheme you selected.
If you chose Unix makefiles, you can start a "make" process in a
terminal/shell window like this (in the "build" directory):

  make                   # Note: use 'gmake' on FreeBSD
  make install           # Note: use 'gmake install' on FreeBSD

Finally, it is not necessary to use the CMake GUI to create your build
system.  Once you know what options you want to set, it is possible to
set them with command line options to the "cmake" command-line
program.  In all cases, the format is

  cmake -DOPTION=setting

In other words, use the flag "-D", then write the name of the option
you want to set, an equal sign, and then the value to which you want
to set the option.  For example, if the various dependency libraries
could be found automatically, and you wished to build libSBML with
Java bindings and the SBML Level 3 Layout package, you would change to
your newly-created "build" directory, and type:

  cmake -DENABLE_LAYOUT=ON -DWITH_JAVA=ON


2.3 Configuring and building libSBML using GNU "configure" and makefiles
------------------------------------------------------------------------

For builds of libSBML that do not include any packages (with the
exception of layout), the old GNU make system is available.  To use
it, start a terminal/shell window, cd to your copy of the libSBML
source code directory, and run the following command:

  ./configure

LibSBML's "configure" program will try to find and use libxml2 as its
XML parser library.  If you do not have libxml2 version 2.6.16 or
later on your system, configure will print an error message to that
effect.  In that case, you can try using the Expat or Xerces libraries
instead.  For Expat, use

  ./configure --with-expat

and for Xerces, use

  ./configure --with-xerces

By default, libSBML only builds the C and C++ API library.  If you
want to configure libSBML to build the Java, C#, Python, Perl, MATLAB,
Ruby and/or Octave API libraries as well, add the flags --with-java,
--with-csharp, --with-python, --with-perl, --with-matlab, --with-ruby,
and/or --with-octave to the "configure" command.  You can combine
options as you need.  (To see what other options are available, run
"configure" with the --help option.)

Depending on your system, you may need to tell "configure" where to
find some of these extra components by adding a directory path after
the option.  For example, if you wish to use a copy of Java whose
components are in /usr/local (with files in /usr/local/bin and
/usr/local/lib), use

  ./configure --with-java=/usr/local

There are many more options to "configure".  To find out more about
them, please see the relevant section in the libSBML documentation.
Here is a link to the online copy:

  http://sbml.org/Software/libSBML/latest-stable/docs/formatted/cpp-api/libsbml-installation.html

Once you've successfully configured libSBML, run the following two
commands to build and install it:

  make                   # Note: use 'gmake' on FreeBSD
  make install           # Note: use 'gmake install' on FreeBSD


2.4 Linking your program with the libSBML library
-------------------------------------------------

The basics of this process are the following.  To use GCC to compile C
or C++ programs that use libSBML, use a command such as the following,
where -lsbml tells the compiler to link with the installed libSBML
library:

  gcc -o myapp.c myapp.c -lsbml

If your compiler cannot find the library, you probably need to adjust
the settings of your environment variable LD_LIBRARY_PATH (called
DYLD_LIBRARY_PATH on MacOS) or use "ldconfig" to adjust the library
search paths on your computer.

Linking applications can become complicated, especially when different
language interfaces such as Java or Python are involved.  Please
consult the section on "Making libSBML accessible to software" in the
libSBML documentation.  Here is a link to the online copy:

  http://sbml.org/Software/libSBML/latest-stable/docs/formatted/cpp-api/libsbml-accessing.html


3. DETAILED INSTRUCTIONS FOR CONFIGURING AND INSTALLING LIBSBML
======================================================================

Documentation for libSBML is available as a separate download from the
same locations as the libSBML distribution (namely, the SBML project
SourceForge and the http://sbml.org/Software/libSBML web page).  The
documentation includes detailed instructions for configuring,
building, installing and using libSBML.  It also includes different
API manuals for different programming languages.  To read any of this
documentation online, please visit the libSBML home page,

  http://sbml.org/Software/libSBML

and look for the links to the manuals.  The following URL is a direct
link to the detailed build and installation instructions:

  http://sbml.org/Software/libSBML/latest-stable/docs/formatted/cpp-api/libsbml-installation.html


4. REPORTING BUGS AND OTHER PROBLEMS
======================================================================

We invite you to report bugs and other problems using the issue
tracker for libSBML on SourceForge.  The following URL will take you
there directly:

  http://sbml.org/Software/libSBML/issue-tracker

You can also ask questions on the 'sbml-interoperability' mailing
list, either over email or using the web forum interface (see below).
This may even have advantages, such as that other people may also have
experienced the issue and offer a workaround more quickly than the
libSBML developers can respond.


5. MAILING LISTS
======================================================================

There are two kinds of mailing lists available: normal discussion
lists for humans, and a SVN change notification list.

Discussion lists
----------------

All discussion lists, their web interfaces and their RSS feeds are at

                       http://sbml.org/Forums/

If you use SBML, we urge you to sign up for sbml-announce, the SBML
announcements mailing list.  It is a low-volume, broadcast-only list.

If you use libSBML, we also encourage you to subscribe to or monitor
via RSS the 'sbml-interoperability' list, where people discuss the
development, use, and interoperability of software that supports SBML,
including libSBML.

If you are interested in helping to modify libSBML, or just want to
know about deeper issues and technical topics, you are welcome to
subscribe to the 'libsbml-development' mailing list.  Being a member
of libsbml-development will enable you to keep in touch with the
latest developments in libSBML as well as to ask questions and share
your experiences with fellow developers and users of libSBML.

SVN notification
----------------

If you are obtaining your libSBML files from SVN, you may wish to
subscribe to the mailing list sbml-svn, to be apprised of changes to
the SVN repository as soon as they are committed.  You can join the
list by visiting the following URL:

  https://lists.sourceforge.net/lists/listinfo/sbml-svn


6. LICENSING AND DISTRIBUTION
======================================================================

Please see the accompanying license file, LICENSE.txt, for detailed
copyright and license information, particularly for third-party
software included in and used by the libSBML distribution.

The majority of the libSBML source code is copyrighted as follows:

* Copyright (C) 2013-2014 jointly by the following organizations:
  1. California Institute of Technology, Pasadena, CA, USA
  2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
  3. University of Heidelberg, Heidelberg, Germany

* Copyright (C) 2009-2013 jointly by the following organizations: 
  1. California Institute of Technology, Pasadena, CA, USA
  2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 
* Copyright (C) 2006-2008 by the California Institute of Technology,
    Pasadena, CA, USA 
 
* Copyright (C) 2002-2005 jointly by the following organizations: 
  1. California Institute of Technology, Pasadena, CA, USA
  2. Japan Science and Technology Agency, Japan

Portions of the source code comprising libSBML were copyrighted
and contributed by third parties, and placed under the same LGPL
2.1 license as the rest of libSBML. The following are their
copyright statements:

* Copyright (C) 2004-2008 by European Media Laboratories Research
  gGmbH, Heidelberg, Germany.  (For the "SBML Layout" code.)

LibSBML is free software; you can redistribute it and/or modify 
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1 of
the License, or any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software
and documentation provided hereunder is on an "as is" basis, and
the copyright holders have no obligations to provide maintenance,
support, updates, enhancements or modifications.  In no event
shall the copyright holders be liable to any party for direct,
indirect, special, incidental or consequential damages, including
lost profits, arising out of the use of this software and its
documentation, even if the copyright holders have been advised of
the possibility of such damage.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library in the file named "COPYING.txt"
included with the software distribution.  A copy is also
available online at the Internet address
http://sbml.org/software/libsbml/COPYING.html for your
convenience.  You may also write to obtain a copy from the Free
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301,  USA.


7. ACKNOWLEDGMENTS
======================================================================

This and other projects of the SBML Team have been supported by the
following organizations: the National Institutes of Health (USA) under
grants R01 GM070923 and R01 GM077671; the International Joint Research
Program of NEDO (Japan); the JST ERATO-SORST Program (Japan); the
Japanese Ministry of Agriculture; the Japanese Ministry of Education,
Culture, Sports, Science and Technology; the BBSRC e-Science
Initiative (UK); the DARPA IPTO Bio-Computation Program (USA); the
Army Research Office's Institute for Collaborative Biotechnologies
(USA); the Air Force Office of Scientific Research (USA); the
California Institute of Technology (USA); the University of
Hertfordshire (UK); the Molecular Sciences Institute (USA); the
Systems Biology Institute (Japan); and Keio University (Japan).


-----------------------------------------------
File author: M. Hucka, B. Bornstein, S. Keating
-----------------------------------------------

# The following is for [X]Emacs users.  Please leave in place.
# Local Variables:
# fill-column: 70
# End:

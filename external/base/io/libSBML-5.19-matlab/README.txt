	 MATLAB application programming interface for libSBML

			    Sarah Keating

			    The SBML Team
			 http://www.sbml.org/
		     mailto:sbml-team@googlegroups.com



---------------
1.  Quick Start
---------------

The libSBML MATLAB binding provides MATLAB functions called
TranslateSBML and OutputSBML.  These function can be used to import
and export an SBML model into/out of the MATLAB environment as a
MATLAB data structure.

The Windows distribution of libSBML includes precompiled copies of
TranslateSBML and OutputSBML.  The source distribution of libSBML for
Linux, MacOS X and other Unix-like environments does not come with
precompiled executables and you will need to build TranslateSBML as
described below.


-------------------------------------------
2.  Configuration and Installation from src
-------------------------------------------

Windows
-------

Build libSBML as described in the libsbml instructions.

Start MATLAB.

Change to the directory holding the file you
are reading right now, i.e., 'libsbml\src\binding\matlab'.

Run the buildSBML.m script followed by the installSBML.m script as
appropriate for your MATLAB installation.


Linux and MacOS X
-----------------

The first step is to run the top-level libSBML 'configure' script with
the --with-matlab option.  (See the top-level README.txt file in the
libSBML source distribution.)  You will probably have to supply the
pathname of the directory tree where MATLAB is installed on your
system.  For example, on MacOS X with release R2010b of MATLAB, run
the following shell command in the top-level libsbml directory:

    ./configure --with-matlab=/Applications/MATLAB_R2010b.app

The libSBML 'configure' script will construct a Makefile in this
directory (i.e., the directory containing the file you are reading
right now), and executing 'make' from the top level will run the
MATLAB compiler to create an object file for use with MATLAB.  The
'make install' step will then copy this object file to the library
installation directory chosen by the user.  (This directory is
/usr/local/lib by default.)

The second step is to configure MATLAB to look for the TranslateSBML
and OutputSBML functions in the libSBML library installation
directory.  You can do this by using a MATLAB command such as

    addpath('/usr/local/lib');

at the MATLAB prompt.  You may wish to add this command to your MATLAB
startup script in ${HOME}/matlab/startup.m.


------------------------------------------
3.  Licensing, Copyrights and Distribution
------------------------------------------

The terms of redistribution for this software are stated in the files
LICENSE.txt and COPYING.txt at the top level of the libSBML
distribution.





-----------------------------------------------------------------------------
File author: B. Bornstein, S. Keating, M. Hucka
-----------------------------------------------------------------------------

# The following is for [X]Emacs users.  Please leave in place.
# Local Variables:
# fill-column: 70
# End:

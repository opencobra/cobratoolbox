This installation package will install libSBML for MacOS 10.5 or later, for both i386 and PPC architectures. By default, it will put the contents in /usr/local, but this location can be changed from the installer interface.

NOTE: Please uninstall any existing copy of libSBML located in the same destination before you install libSBML using this installer, or you may end up with mixed versions of different libSBML components on your system.

This package includes the C/C++ core libSBML library and the following language interfaces:
  
   + C# (Mono)
   + Java
   + MATLAB
   + Perl
   + Python
   + Ruby

The Octave interface is currently not included in the MacOSX installer. If you need the Octave interface, please compile it directly using the libSBML source code distribution.

To uninstall libSBML, please run the following command in your terminal:

  sudo /usr/local/bin/uninstall-libsbml-pkg.sh

(If you chose to install libSBML into a directory tree other than /usr/local, then please run the "uninstall-libsbml-pkg.sh" script that will have be placed in the "bin" directory of your alternate location.)

For additional information about this version of libSBML, please see the files in the "docs" subdirectory of this installer.

For detailed information about how to make libSBML accessible to your software, please visit the following URL:

  http://sbml.org/Software/libSBML/docs/cpp-api/libsbml-accessing.html

Detailed information about libSBML can be found at

  http://sbml.org/Software/libSBML

Please report problems with libSBML using the tracker at

  http://sbml.org/Software/libSBML/issue-tracker

========== libSBML C# API ==========

----------------------------------------------------------------------
1. Authors
----------------------------------------------------------------------

* Frank Bergmann (fbergman@u.washington.edu)
* Akiya Jouraku  (jouraku@bio.keio.ac.jp)

----------------------------------------------------------------------
2. Description
----------------------------------------------------------------------

This module provides C# application programming interface (API) for 
libSBML library. 
Most of the native C++ classes/functions (except for classes/functions
used for internal use) are wrapped by using SWIG (http://www.swig.org).

Currently, the reference documentation for libSBML C# API is not available
due to the lack of support for automatically generating the C# API
documentation from C++ header files.
However, since the libSBML C# API is very similar to the libSBML Java API, 
the Java API documentation (*) may be helpful as a guide for using the
libSBML C# API until the documentation of C# API has been written. 

 ---------------------------------------------------
 (*) http://sbml.org/Software/libSBML/docs/java-api/
 ---------------------------------------------------

----------------------------------------------------------------------
3. Building
----------------------------------------------------------------------

===========
(Windows)
===========

  ------------------------------------------------------------------
  (NOTE) Currently, libSBML C# API is not supported on Cygwin/MinGW.
  ------------------------------------------------------------------ 

  This directory contains the following solution files for Microsoft 
  Visual Studio which load all the relevant projects below.

    [for Visual Studio 2005 or later]

      CSharp_binding_win32-expat.sln
      CSharp_binding_win32-libxml.sln
      CSharp_binding_win32-xerces.sln

    [for Visual Studio 2003 or later]

      CSharp_binding_win32-expat-vs2003.sln
      CSharp_binding_win32-libxml-vs2003.sln
      CSharp_binding_win32-xerces-vs2003.sln

  By using each solution file, you can build two DLL files ("libsbmlcs.dll"
  and "libsbmlcsP.dll") required for building and running a program using 
  libSBML C# API.

  The following softwares are required to build the DLL files by using
  the above solution files:


   ----------------------------------------------------------------- 
   1) Microsoft Visual Studio 2003 or later
   2) One of the following XML parser libraries

      1. Xerces (http://xerces.apache.org/xerces-c/)
      2. Expat  (http://sourceforge.net/projects/expat/)
      3. LibXML (http://xmlsoft.org/)

   3) Zlib  (http://zlib.net/)  
            (http://www.winimage.com/zLibDll/)

   4) Bzip2 (http://www.bzip.org/)
            (http://gnuwin32.sourceforge.net/packages/bzip2.htm)
   ----------------------------------------------------------------- 


  Each of the following Visual C++ project files builds a native C++ DLL 
  file ("libsbmlcs.dll") which is required to run a program using libSBML
  C# API.
  Each project file builds the DLL file with a different underlying XML 
  parser (Xerces, Expat, or LibXML2)

    [for Visual C++ 2005 or later]

      CSharp_binding_win32-expat.vcproj   (uses Expat)
      CSharp_binding_win32-libxml.vcproj  (uses LibXML2)
      CSharp_binding_win32-xerces.vcproj  (uses Xerces)

    [for Visual C++ 2003 or later]

      CSharp_binding_win32-expat-vs2003.vcproj  (uses Expat)
      CSharp_binding_win32-libxml-vs2003.vcproj (uses LibXML2)
      CSharp_binding_win32-xerces-vs2003.vcproj (uses Xerces)


  Each of the following Visual C# project files builds a C# DLL file 
  ("libsbmlcsP.dll") which is required to build or run a program 
  using libSBML C# API.

      CSharp_binding_cspDLL.csproj        (for Visual C# 2005 or later)
      CSharp_binding_cspDLL-vs2003.csproj (for Visual C# 2003 or later)

  The C# DLL file provides libSBML C# API (the C# proxy classes internally
  invoke a corresponding native C++ wrapper function to use the corresponding 
  libSBML C++ API.)

  Each of the following Visual C# project files builds a simple test program
  ("TestRW.exe") which reads/writes SBML files by using libSBML C# API.

     CSharp_binding_TestRW.csproj        (for Visual C# 2005 or later)
     CSharp_binding_TestRW-vs2003.csproj (for Visual C# 2003 or later)

  This directory contains a batch file ("runTestRW.bat") which runs the 
  test program.
  ("runTestRW.bat" may need to be modified. See the file for the detail.)

  The following Visual C# 2005 project file builds a test runner program
  ("libSBMLCSTestRunner.exe") which internally compiles the libSBML C# test
  files located in "test" directory and runs each test program.

    libSBMLCSTestRunner-vs2005.csproj

  This directory contains a batch file ("runTestRunner.bat") which runs the 
  test runner program.
  ("runTestRunner.bat" may need to be modified. See the file for the detail.)


==================================================
(Linux,  MacOSX, and other UNIX-based platforms)
==================================================

libSBML C# API can also be used on non-Windows platforms. 

Currently, we recommend to use Mono C# (http://www.mono-project.com/Main_Page) 
to build libSBML C# libraries/programs and to run the programs using the
libSBML C# API on non-Windows platforms.

 (NOTE: Currently, libSBML C# API doesn't seem to work with Portable.NET.)

You can build and install libSBML C# library files as follows: 

  1) Run configure script (in the top directory of libSBML source tree) 
     with "--with-csharp" option.


       % ./configure --with-csharp ...


     You may need to set a base directory path to your installed Mono C#
     (e.g. --with-csharp=/usr/local/) if the Mono C# is not installed in 
     the system directory.

    "--with-swig" option is also required if you want to recreate SWIG
    generated wrapper files for libSBML C#.


  2) Run make.

       % make

     The following two shared library files will be generated in this
     directory if the build succeeds.
     
       1) libsbmlcs.so 
          - C++ shared library file which provides wrapper functions for
            libSBML C# API
          - required when running a program using libSBML C# API
 
       2) libsbmlcsP.dll
          - C# DLL file which provides libSBML C# API (The C# proxy classes
            internally invoke a corresponding native C++ wrapper function
            (provided by the "libsbmlcs.so") to use the corresponding
             libSBML C++ API.).
          - required when building or running a program using libSBML C# API

     If the configure script was invoked with "--with-check" option, you can
     build and run two test programs (TestRW.exe and TestRunner.exe) by
     running "make check".


  3) Run make install.

      % make install

     The two library files will be installed in ${prefix}/lib/mono/libsbmlcsP/
      directory.
     (By default (without --prefix option), the prefix is /usr/local/.)
      

----------------------------------------------------------------------
4. Introduction
----------------------------------------------------------------------

Here is a simple example that reads an SBML file and prints any errors
encountered.

======================================================
namespace LibSBMLExample
{
  using libsbml;
  using System;

  public class Example
  {
    public static void Main (string[] args)
    {
      // read an SBML file
      SBMLReader   reader  = new SBMLReader();
      SBMLDocument sbmlDoc = reader.readSBML(args[0]);

      // get the number of errors
      long errors = sbmlDoc.getNumErrors();

      Console.WriteLine(" filename: {0}", args[0]);
      Console.WriteLine(" error(s): {0}", errors );

      if ( errors > 0)
      {
        // print errors
        sbmlDoc.printErrors(libsbml.cerr); 
      }
      Environment.Exit(errors);        
    }
  }
}
========================================================

The code implements a "Example" class in a "LibSBMLExample" namespace.

First, "using libsbml" directive is used to permit the use of types in
the "libsbml" namespace (the namespace of libSBML C# module) without
qualification in the "LibSBMLExample" namespace.

Next, in the body of the Main function, the line


  SBMLReader   reader  = new SBMLReader();


creates an SBMLReader object which is used to read an SBML file.
The next line


  SBMLDocument sbmlDoc = reader.readSBML(args[0]);


reads the given SBML file and sets a returned SBMLDocument object.
libSBML uses the class SBMLDocument as a top-level container for
storing SBML content and data associated with it (such as warnings and
error messages).
A subsequent call to the SBMLDocument.getNumErrors() method returns
the number of errors encountered (if any), and the call to
SBMLDocument.printErrors() mehtod prints them to the standard error
output stream.


----------------------------------------------------------------------
5. Compiling/Running a C# program with libSBML C# API
----------------------------------------------------------------------

==============
(Windows)
==============

You can build a C# source file which uses libSBML C# API by using Microsoft
Visual C# on Windows.
The libSBML C# DLL ("libsbmlcsP.dll") is required to compile the C# source
file.

You need to put required DLLs in your DLL search path to run a
executable file which uses libSBML C# API. The required DLLs are the
libSBML C# DLL file ("libsbmlcsP.dll"), the native C++ DLL file
("libsbmlcs.dll") and other DLL files (zlib1.dll, bzip2.dll, and a
corresponding DLL file for the underlying XML parser.)

=================================================
(Linux, MacOSX, and other UNIX-based platforms)
=================================================

You can build a C# source file which uses libSBML C# API by using Mono C#
compiler on Linux, MacOSX and other UNIX-based platforms.

For example, you can build a C# source file ("Test.cs") and generate an 
executable file ("Test.exe") as follows:


  % gmcs -target:exe -out:Test.exe -r:libsbmlcsP.dll Test.cs

    (NOTE: the "mcs" compiler can also be used to compile against the C# 1.0 
     and 2.0 code with the exception of generics and nullable types.
     Please see the man page of "mcs" for the detail.)


You may need to use "-L" option to set the path to a directory in which 
"libsbmlcsP.dll" located if the file is not installed in the system directory.

You can run the executable file by using "mono" command.
For example, you can run the executable file ("Test.exe") as follows:


  % mono Test.exe 


You must make sure the following configurations to run the executable file:

  1) make sure that "libsbmlcsP.dll" is located in the same path to the
     executable file.

     Alternatively, you can use an environment variable "MONO_PATH" to set
     the path to "libsbmlcsP.dll". However, this solution is not recommended 
     by Mono development team because it breaks the assembly loader in subtle 
     ways. See the man page of "mono" for the detail.

  2) make sure that your dynamic library search path variable includes the
     directory in which the "libsbml.so" ("libsbml.dylib" on MacOSX) and 
     "libsbmlcs.so" are located.

     As an example, if you were running under Linux and you configured
     libSBML with a prefix of '/usr/local' and did a normal "make install",
     and you were using the typical sh or bash shell in your terminal, you
     would need to execute

        export LD_LIBRARY_PATH="/usr/local/lib/mono/libsbmlcsP:$LD_LIBRARY_PATH"

     ('DYLD_LIBRARY_PATH' is used instead of 'LD_LIBRARY_PATH' on MacOSX.)

     or put the above in your shell's initialization file (.bashrc or
     .profile in your home directory) and cause the shell to re-read the
     initialization file. 

----------------------------------------------------------------------
6. Example programs
----------------------------------------------------------------------

You can find example C# programs which use libSBML C# API in
"examples/csharp/" directory.

Also, you can find C# programs used for unit tests in the "test" 
directory in this directory.

----------------------------------------------------------------------
7.  Licensing, Copyrights and Distribution
----------------------------------------------------------------------

The terms of redistribution for this software are stated in the files
LICENSE.txt and  COPYING.txt at the top level of the libSBML distribution.


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


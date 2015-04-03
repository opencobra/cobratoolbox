	Information about the compression library used in libSBML.

The following files in this directory were borrowed from MiniZip version 1.01e
(http://www.winimage.com/zLibDll/minizip.html) implemented by Gilles Vollant.

   1. crypt.h
   2. ioapi.c
   3. ioapi.h
   4. iowin32.c
   5. iowin32.h
   6. unzip.c*
   7. unzip.h
   8. zip.c*
   9. zip.h

Files with * have been modified from their original versions of MiniZip
1.0.1e in order to address compilation warnings on some platforms.

Also, zip/unzip specific code in zipfstream.h and zipfstream.cpp in this 
directory are based on the following files in MiniZip version 1.0.1e.

   1. minizip.c
   2. miniunz.c

MiniZip 1.01e is distributed under the following term:
----------------------------------------------------------------------
Copyright (C) 1998-2005 Gilles Vollant

Condition of use and distribution are the same than zlib :

 This software is provided 'as-is', without any express or implied
 warranty.  In no event will the authors be held liable for any damages
 arising from the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.
 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------

The following files in this directory are also borrowed "as is" from the 
contributed sample files in zlib version 1.2.3 (http://www.zlib.net/).

  1. zfstream.h
  2. zfstream.cpp

These files were implemented by Ludwig Schwardt <schwardt@sun.ac.za>
(the original version were implemented by Kevin Ruland <kevin@rodin.wustl.edu>)

Also, the code (except for bzip2/zip/unzip specific code) in the following files
in this directory are based on the above two files.

  1. bzfstream.h
  2. bzfstream.cpp
  3. zipfstream.h
  4. zipfstream.cpp 

======================================================================
July 18, 2008 Written by Akiya Jouraku <jouraku@bio.keio.ac.jp>
Jan. 6, 2009  Additional comments by Michael Hucka <mhucka@caltech.edu>

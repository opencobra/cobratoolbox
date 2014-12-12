/**
 * @file    zipfstream.cpp
 * @brief   C++ I/O streams interface to the zip/unzip functions in Minizip
 * @author  Akiya Jouraku
 * 
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 *
 * Copyright 2005-2010 California Institute of Technology.
 * Copyright 2002-2005 California Institute of Technology and
 *                     Japan Science and Technology Corporation.
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->
 *
 * Most of the code (except for zip/unzip specific code) is based on 
 * zfstream.cc implemented by Ludwig Schwardt <schwardt@sun.ac.za> 
 * original version by Kevin Ruland <kevin@rodin.wustl.edu>
 * zfstream.cc is contained in the contributed samples in zlib version 1.2.3
 * (http://www.zlib.net).
 *
 * The following zip/unzip specific functions are implemented based on
 * the code in minizip.c and miniunz.c contained in Minizip version 1.01e
 * (http://www.winimage.com/zLibDll/minizip.html) implemented by Gilles Vollant.
 *
 *  zipFile  zipopen (const char* path, const char* filenameinzip, int append);
 *  int      zipclose(zipFile file);
 *  int      zipwrite(zipFile file, voidp buf, unsigned len);
 *  unzFile  unzipopen (const char* path);
 *  int      unzipclose(unzFile file);
 *  int      unzipread (unzFile file, voidp buf, unsigned len);
 *
 * Minizip is distributed under the following terms:
 * ---------------------------------------------------------------------------
 * Copyright (C) 1998-2005 Gilles Vollant
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *     claim that you wrote the original software. If you use this software
 *     in a product, an acknowledgment in the product documentation would be
 *     appreciated but is not required.
 *  2. Altered source versions must be plainly marked as such, and must not be
 *     misrepresented as being the original software.
 *  3. This notice may not be removed or altered from any source distribution.
 * --------------------------------------------------------------------------- -->*/


#include "zipfstream.h"
#include <cstring>          // for strcpy, strcat, strlen (mode strings)
#include <cstdio>           // for BUFSIZ

#if defined(WIN32) && !(defined(CYGWIN)) 
#define USEWIN32IOAPI
# include "iowin32.h"
# include <direct.h>
# include <io.h>
#else
# include <unistd.h>
# include <utime.h>
# include <sys/types.h>
# include <sys/stat.h>
#endif

#define WRITEBUFFERSIZE (16384)
#define MAXFILENAME (256)

// Internal buffer sizes (default and "unbuffered" versions)
#define BIGBUFSIZE BUFSIZ
#define SMALLBUFSIZE 1

uLong filetime(const char* f, tm_zip* tmzip, uLong* dt);

/*****************************************************************************/

// Default constructor
zipfilebuf::zipfilebuf()
: rfile(NULL), wfile(NULL), io_mode(std::ios_base::openmode(0)), 
  own_fd(false), buffer(NULL), buffer_size(BIGBUFSIZE), own_buffer(true)
{
  // No buffers to start with
  this->disable_buffer();
}

// Destructor
zipfilebuf::~zipfilebuf()
{
  // Sync output buffer and close only if responsible for file
  // (i.e. attached streams should be left open at this stage)
  this->sync();
  if (own_fd)
    this->close();
  // Make sure internal buffer is deallocated
  this->disable_buffer();
}

// Open zip file
zipfilebuf*
zipfilebuf::open(const char *name, const char* nameinzip,
                std::ios_base::openmode mode)
{
  // Fail if file already open
  if (this->is_open())
    return NULL;
  // Don't support simultaneous read/write access (yet)
  if ((mode & std::ios_base::in) && (mode & std::ios_base::out))
    return NULL;

  // Build mode string for zipopen and check it [27.8.1.3.2]
  char char_mode[6] = "\0\0\0\0\0";
  if (!this->open_mode(mode, char_mode))
    return NULL;

  // Attempt to open a zip archive file

  if ( nameinzip != NULL )
  {
    int append = (mode & std::ios_base::app) ? 2 : 0;
    if ((wfile = zipopen(name, nameinzip, append)) == NULL)
      return NULL;
  }
  else
  {
    if ( (rfile = unzipopen(name)) == NULL)
      return NULL;
  }

  // On success, allocate internal buffer and set flags
  this->enable_buffer();
  io_mode = mode;
  own_fd = true;
  return this;
}

// Close zip file
zipfilebuf*
zipfilebuf::close()
{
  // Fail immediately if no file is open
  if (!this->is_open())
    return NULL;
  // Assume success
  zipfilebuf* retval = this;
  // Attempt to sync and close zip file
  if (this->sync() == -1)
    retval = NULL;

  if (wfile != NULL)
  {
    if (zipclose(wfile) != ZIP_OK)
      retval = NULL;
  }
  else if (rfile != NULL)
  {
    if (unzipclose(rfile) != UNZ_OK)
      retval = NULL;
  }
  else
  {
    retval = NULL;
  }

  // File is now gone anyway (postcondition [27.8.1.3.8])
  rfile = NULL;
  wfile = NULL;
  own_fd = false;
  // Destroy internal buffer if it exists
  this->disable_buffer();
  return retval;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Convert int open mode to mode string
bool
zipfilebuf::open_mode(std::ios_base::openmode mode,
                     char* c_mode) const
{
  bool testb = (mode & std::ios_base::binary) == std::ios_base::binary;
  bool testi = (mode & std::ios_base::in) == std::ios_base::in;
  bool testo = (mode & std::ios_base::out) == std::ios_base::out;
  bool testt = (mode & std::ios_base::trunc) == std::ios_base::trunc;
  bool testa = (mode & std::ios_base::app) == std::ios_base::app;

  // Check for valid flag combinations - see [27.8.1.3.2] (Table 92)
  // Original zfstream hardcoded the compression level to maximum here...
  // Double the time for less than 1% size improvement seems
  // excessive though - keeping it at the default level
  // To change back, just append "9" to the next three mode strings
  if (!testi && testo && !testt && !testa)
    strcpy(c_mode, "w");
  if (!testi && testo && !testt && testa)
    strcpy(c_mode, "a");
  if (!testi && testo && testt && !testa)
    strcpy(c_mode, "w");
  if (testi && !testo && !testt && !testa)
    strcpy(c_mode, "r");
  // No read/write mode yet
//  if (testi && testo && !testt && !testa)
//    strcpy(c_mode, "r+");
//  if (testi && testo && testt && !testa)
//    strcpy(c_mode, "w+");

  // Mode string should be empty for invalid combination of flags
  if (strlen(c_mode) == 0)
    return false;
  if (testb)
    strcat(c_mode, "b");
  return true;
}

// Determine number of characters in internal get buffer
std::streamsize
zipfilebuf::showmanyc()
{
  // Calls to underflow will fail if file not opened for reading
  if (!this->is_open() || !(io_mode & std::ios_base::in))
    return -1;
  // Make sure get area is in use
  if (this->gptr() && (this->gptr() < this->egptr()))
    return std::streamsize(this->egptr() - this->gptr());
  else
    return 0;
}

// Fill get area from zip file
zipfilebuf::int_type
zipfilebuf::underflow()
{
  // If something is left in the get area by chance, return it
  // (this shouldn't normally happen, as underflow is only supposed
  // to be called when gptr >= egptr, but it serves as error check)
  if (this->gptr() && (this->gptr() < this->egptr()))
    return traits_type::to_int_type(*(this->gptr()));

  // If the file hasn't been opened for reading, produce error
  if (!this->is_open() || !(io_mode & std::ios_base::in))
    return traits_type::eof();

  // Attempt to fill internal buffer from zip file
  // (buffer must be guaranteed to exist...)
// jouraku
  int bytes_read = unzipread(rfile, buffer, (unsigned int)buffer_size);
  // Indicates error or EOF
  if (bytes_read <= 0)
  {
    // Reset get area
    this->setg(buffer, buffer, buffer);
    return traits_type::eof();
  }
  // Make all bytes read from file available as get area
  this->setg(buffer, buffer, buffer + bytes_read);

  // Return next character in get area
  return traits_type::to_int_type(*(this->gptr()));
}

// Write put area to zip file
zipfilebuf::int_type
zipfilebuf::overflow(int_type c)
{
  // Determine whether put area is in use
  if (this->pbase())
  {
    // Double-check pointer range
    if (this->pptr() > this->epptr() || this->pptr() < this->pbase())
      return traits_type::eof();
    // Add extra character to buffer if not EOF
    if (!traits_type::eq_int_type(c, traits_type::eof()))
    {
      *(this->pptr()) = traits_type::to_char_type(c);
      this->pbump(1);
    }
    // Number of characters to write to file
    int bytes_to_write = int(this->pptr() - this->pbase());
    // Overflow doesn't fail if nothing is to be written
    if (bytes_to_write > 0)
    {
      // If the file hasn't been opened for writing, produce error
      if (!this->is_open() || !(io_mode & std::ios_base::out))
        return traits_type::eof();
// jouraku
      // If zip file won't accept all bytes written to it, fail
      if (zipwrite(wfile, this->pbase(), bytes_to_write) != ZIP_OK)
        return traits_type::eof();
//
      // Reset next pointer to point to pbase on success
      this->pbump(-bytes_to_write);
    }
  }
  // Write extra character to file if not EOF
  else if (!traits_type::eq_int_type(c, traits_type::eof()))
  {
    // If the file hasn't been opened for writing, produce error
    if (!this->is_open() || !(io_mode & std::ios_base::out))
      return traits_type::eof();
    // Impromptu char buffer (allows "unbuffered" output)
    char_type last_char = traits_type::to_char_type(c);
//jouraku
    // If zip file won't accept this character, fail
    if (zipwrite(wfile, &last_char, 1) != ZIP_OK)
      return traits_type::eof();
  }

  // If you got here, you have succeeded (even if c was EOF)
  // The return value should therefore be non-EOF
  if (traits_type::eq_int_type(c, traits_type::eof()))
    return traits_type::not_eof(c);
  else
    return c;
}

// Assign new buffer
std::streambuf*
zipfilebuf::setbuf(char_type* p,
                  std::streamsize n)
{
  // First make sure stuff is sync'ed, for safety
  if (this->sync() == -1)
    return NULL;
  // If buffering is turned off on purpose via setbuf(0,0), still allocate one...
  // "Unbuffered" only really refers to put [27.8.1.4.10], while get needs at
  // least a buffer of size 1 (very inefficient though, therefore make it bigger?)
  // This follows from [27.5.2.4.3]/12 (gptr needs to point at something, it seems)
  if (!p || !n)
  {
    // Replace existing buffer (if any) with small internal buffer
    this->disable_buffer();
    buffer = NULL;
    buffer_size = 0;
    own_buffer = true;
    this->enable_buffer();
  }
  else
  {
    // Replace existing buffer (if any) with external buffer
    this->disable_buffer();
    buffer = p;
    buffer_size = n;
    own_buffer = false;
    this->enable_buffer();
  }
  return this;
}

// Write put area to zip file (i.e. ensures that put area is empty)
int
zipfilebuf::sync()
{
  return traits_type::eq_int_type(this->overflow(), traits_type::eof()) ? -1 : 0;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Allocate internal buffer
void
zipfilebuf::enable_buffer()
{
  // If internal buffer required, allocate one
  if (own_buffer && !buffer)
  {
    // Check for buffered vs. "unbuffered"
    if (buffer_size > 0)
    {
      // Allocate internal buffer
      buffer = new char_type[(unsigned int)buffer_size];
      // Get area starts empty and will be expanded by underflow as need arises
      this->setg(buffer, buffer, buffer);
      // Setup entire internal buffer as put area.
      // The one-past-end pointer actually points to the last element of the buffer,
      // so that overflow(c) can safely add the extra character c to the sequence.
      // These pointers remain in place for the duration of the buffer
      this->setp(buffer, buffer + buffer_size - 1);
    }
    else
    {
      // Even in "unbuffered" case, (small?) get buffer is still required
      buffer_size = SMALLBUFSIZE;
      buffer = new char_type[(unsigned int)buffer_size];
      this->setg(buffer, buffer, buffer);
      // "Unbuffered" means no put buffer
      this->setp(0, 0);
    }
  }
  else
  {
    // If buffer already allocated, reset buffer pointers just to make sure no
    // stale chars are lying around
    this->setg(buffer, buffer, buffer);
    this->setp(buffer, buffer + buffer_size - 1);
  }
}

// Destroy internal buffer
void
zipfilebuf::disable_buffer()
{
  // If internal buffer exists, deallocate it
  if (own_buffer && buffer)
  {
    // Preserve unbuffered status by zeroing size
    if (!this->pbase())
      buffer_size = 0;
    delete[] buffer;
    buffer = NULL;
    this->setg(0, 0, 0);
    this->setp(0, 0);
  }
  else
  {
    // Reset buffer pointers to initial state if external buffer exists
    this->setg(buffer, buffer, buffer);
    if (buffer)
      this->setp(buffer, buffer + buffer_size - 1);
    else
      this->setp(0, 0);
  }
}

/*****************************************************************************/

// Default constructor initializes stream buffer
zipifstream::zipifstream()
: std::istream(NULL), sb()
{ this->init(&sb); }

// Initialize stream buffer and open file
zipifstream::zipifstream(const char* name,
                       std::ios_base::openmode mode)
: std::istream(NULL), sb()
{
  this->init(&sb);
  this->open(name, mode);
}

// Open file and go into fail() state if unsuccessful
void
zipifstream::open(const char* name,
                 std::ios_base::openmode mode)
{
  if (!sb.open(name, NULL, mode | std::ios_base::in))
    this->setstate(std::ios_base::failbit);
  else
    this->clear();
}

// Close file
void
zipifstream::close()
{
  if (!sb.close())
    this->setstate(std::ios_base::failbit);
}

/*****************************************************************************/

// Default constructor initializes stream buffer
zipofstream::zipofstream()
: std::ostream(NULL), sb()
{ this->init(&sb); }

// Initialize stream buffer and open file
zipofstream::zipofstream(const char* name, const char* nameinzip,
                       std::ios_base::openmode mode)
: std::ostream(NULL), sb()
{
  this->init(&sb);
  this->open(name, nameinzip, mode);
}

// Open file and go into fail() state if unsuccessful
void
zipofstream::open(const char* name, const char* nameinzip,
                 std::ios_base::openmode mode)
{
  if (!sb.open(name, nameinzip, mode | std::ios_base::out))
    this->setstate(std::ios_base::failbit);
  else
    this->clear();
}

// Close file
void
zipofstream::close()
{
  if (!sb.close())
    this->setstate(std::ios_base::failbit);
}

/* ---------------------------------------------------------------
 *
 * The following functions are used in zipfilebuf.
 * (implemented by Akiya Jouraku)
 *
 * ---------------------------------------------------------------
 */

zipFile zipopen (const char* path, const char* filenameinzip, int append)
{
  zipFile zf = NULL;
  int err=ZIP_OK;

#ifdef USEWIN32IOAPI
    zlib_filefunc_def ffunc;
    fill_win32_filefunc(&ffunc);
    zf = zipOpen2(path,append,NULL,&ffunc);
#else
    zf = zipOpen(path, append);
#endif

    if (zf == NULL) return NULL;

    zip_fileinfo zi;

    zi.tmz_date.tm_sec  = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
    zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = zi.tmz_date.tm_year = 0;
    zi.dosDate     = 0;
    zi.internal_fa = 0;
    zi.external_fa = 0;
    filetime(filenameinzip,&zi.tmz_date,&zi.dosDate);

    err = zipOpenNewFileInZip(zf,filenameinzip,&zi,
                     NULL,0,NULL,0,NULL,
                     Z_DEFLATED,
                     Z_DEFAULT_COMPRESSION);
  
    if (err != ZIP_OK)
    {
       zipClose(zf, NULL);
       return NULL;
    }

    return zf;
}

int zipclose(zipFile file)
{
  return zipClose(file,NULL);
}

int zipwrite(zipFile file, voidp buf, unsigned len)
{
  return zipWriteInFileInZip (file,buf,len);
}


unzFile unzipopen (const char* path)
{
  unzFile uf = NULL;
  int err=UNZ_OK;

#ifdef USEWIN32IOAPI
  zlib_filefunc_def ffunc;
#endif

#ifdef USEWIN32IOAPI
  fill_win32_filefunc(&ffunc);
  uf = unzOpen2(path,&ffunc);
#else
  uf = unzOpen(path);
#endif

  if (uf == NULL) return NULL;

  err = unzGoToFirstFile(uf);
  if (err != UNZ_OK)
  {
     unzClose(uf);
     return NULL;
  }

  err = unzOpenCurrentFile(uf);
  if (err != UNZ_OK)
  {
     unzClose(uf);
     return NULL;
  }

  return uf;
}

int  unzipclose(unzFile file)
{
  int err = unzCloseCurrentFile(file);
  if ( err != UNZ_OK )
  {
    return err;
  }

  return unzClose(file);
}

int  unzipread (unzFile file, voidp buf, unsigned len)
{
  return unzReadCurrentFile(file,buf,len);
}


#if defined(WIN32) && !defined(CYGWIN)
uLong filetime(const char* f, tm_zip* tmzip, uLong *dt)
{
  int ret = 0;
  {
      FILETIME ftLocal;
      HANDLE hFind;
      WIN32_FIND_DATA  ff32;

      hFind = FindFirstFile(f,&ff32);
      if (hFind != INVALID_HANDLE_VALUE)
      {
        FileTimeToLocalFileTime(&(ff32.ftLastWriteTime),&ftLocal);
        FileTimeToDosDateTime(&ftLocal,((LPWORD)dt)+1,((LPWORD)dt)+0);
        FindClose(hFind);
        ret = 1;
      }
  }
  return ret;
}
#else
#if defined(unix) || defined(MACOSX)
uLong filetime(const char* f, tm_zip* tmzip, uLong *dt)
{
  int ret=0;
  struct stat s;        /* results of stat() */
  struct tm* filedate;
  time_t tm_t=0;

  if (strcmp(f,"-")!=0)
  {
    char name[MAXFILENAME+1];
    int len = (int)strlen(f);
    if (len > MAXFILENAME)
      len = MAXFILENAME;

    strncpy(name, f,MAXFILENAME-1);
    /* strncpy doesnt append the trailing NULL, of the string is too long. */
    name[ MAXFILENAME ] = '\0';

    if (name[len - 1] == '/')
      name[len - 1] = '\0';
    /* not all systems allow stat'ing a file with / appended */
    if (stat(name,&s)==0)
    {
      tm_t = s.st_mtime;
      ret = 1;
    }
  }
  filedate = localtime(&tm_t);

  tmzip->tm_sec  = filedate->tm_sec;
  tmzip->tm_min  = filedate->tm_min;
  tmzip->tm_hour = filedate->tm_hour;
  tmzip->tm_mday = filedate->tm_mday;
  tmzip->tm_mon  = filedate->tm_mon ;
  tmzip->tm_year = filedate->tm_year;

  return ret;
}
#else
uLong filetime(const char* f, tm_zip* tmzip, uLong *dt)
{
    return 0;
}
#endif
#endif


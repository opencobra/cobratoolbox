/**
 * @file    zipfstream.h
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
 * zfstream.h implemented by Ludwig Schwardt <schwardt@sun.ac.za> 
 * original version by Kevin Ruland <kevin@rodin.wustl.edu>
 * zfstream.h is contained in the contributed samples in zlib version 1.2.3
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

#ifndef ZIPFSTREAM_H
#define ZIPFSTREAM_H

#include <istream>  // not iostream, since we don't need cin/cout
#include <ostream>
#include "zip.h"
#include "unzip.h"

/*****************************************************************************/

/**
 *  @brief  zip file stream buffer class.
 *
 *  This class implements basic_filebuf for zip files. It doesn't yet support
 *  seeking, putback and read/write access (tricky). 
 *  Otherwise, it attempts to be a drop-in replacement for the standard
 *  file streambuf.
*/
class zipfilebuf : public std::streambuf
{
public:
  //  Default constructor.
  zipfilebuf();

  //  Destructor.
  virtual
  ~zipfilebuf();

  /**
   *  @brief  Check if file is open.
   *  @return  True if file is open.
  */
  bool
  is_open() const { return ((rfile != NULL) || (wfile != NULL)) ; }


  /**
   *  @brief  Open zip file for writing.
   *  @param  name  Zip file name.
   *  @param  name  A file name in the zip file for writing 
   *                a zip file. (The zip fill will be opened 
   *                for reading if the value if NULL.) 
   *  @param  mode  Open mode flags.
   *  @return  @c this on success, NULL on failure.
  */
  zipfilebuf*
  open(const char* name, const char* filenameinzip,
       std::ios_base::openmode mode);


  /**
   *  @brief  Attach to already open zip file.
   *  @param  fd  File descriptor.
   *  @param  mode  Open mode flags.
   *  @return  @c this on success, NULL on failure.
  */
/*
  zipfilebuf*
  attach(int fd,
         std::ios_base::openmode mode);
*/

  /**
   *  @brief  Close zip file.
   *  @return  @c this on success, NULL on failure.
  */
  zipfilebuf*
  close();

protected:
  /**
   *  @brief  Convert ios open mode int to mode string used by zlib.
   *  @return  True if valid mode flag combination.
  */
  bool
  open_mode(std::ios_base::openmode mode,
            char* c_mode) const;

  /**
   *  @brief  Number of characters available in stream buffer.
   *  @return  Number of characters.
   *
   *  This indicates number of characters in get area of stream buffer.
   *  These characters can be read without accessing the zip file.
  */
  virtual std::streamsize
  showmanyc();

  /**
   *  @brief  Fill get area from zip file.
   *  @return  First character in get area on success, EOF on error.
   *
   *  This actually reads characters from zip file to stream
   *  buffer. Always buffered.
  */
  virtual int_type
  underflow();

  /**
   *  @brief  Write put area to zip file.
   *  @param  c  Extra character to add to buffer contents.
   *  @return  Non-EOF on success, EOF on error.
   *
   *  This actually writes characters in stream buffer to
   *  zip file. With unbuffered output this is done one
   *  character at a time.
  */
  virtual int_type
  overflow(int_type c = std::streambuf::traits_type::eof());

  /**
   *  @brief  Installs external stream buffer.
   *  @param  p  Pointer to char buffer.
   *  @param  n  Size of external buffer.
   *  @return  @c this on success, NULL on failure.
   *
   *  Call setbuf(0,0) to enable unbuffered output.
  */
  virtual std::streambuf*
  setbuf(char_type* p,
         std::streamsize n);

  /**
   *  @brief  Flush stream buffer to file.
   *  @return  0 on success, -1 on error.
   *
   *  This calls underflow(EOF) to do the job.
  */
  virtual int
  sync();

//
// Some future enhancements
//
//  virtual int_type uflow();
//  virtual int_type pbackfail(int_type c = traits_type::eof());
//  virtual pos_type
//  seekoff(off_type off,
//          std::ios_base::seekdir way,
//          std::ios_base::openmode mode = std::ios_base::in|std::ios_base::out);
//  virtual pos_type
//  seekpos(pos_type sp,
//          std::ios_base::openmode mode = std::ios_base::in|std::ios_base::out);

private:
  /**
   *  @brief  Allocate internal buffer.
   *
   *  This function is safe to call multiple times. It will ensure
   *  that a proper internal buffer exists if it is required. If the
   *  buffer already exists or is external, the buffer pointers will be
   *  reset to their original state.
  */
  void
  enable_buffer();

  /**
   *  @brief  Destroy internal buffer.
   *
   *  This function is safe to call multiple times. It will ensure
   *  that the internal buffer is deallocated if it exists. In any
   *  case, it will also reset the buffer pointers.
  */
  void
  disable_buffer();

  /**
   *  Underlying zip file pointer.
  */
  unzFile rfile;

  /**
   *  Underlying unzip file pointer.
  */
  zipFile wfile;

  /**
   *  Mode in which file was opened.
  */
  std::ios_base::openmode io_mode;

  /**
   *  @brief  True if this object owns file descriptor.
   *
   *  This makes the class responsible for closing the file
   *  upon destruction.
  */
  bool own_fd;

  /**
   *  @brief  Stream buffer.
   *
   *  For simplicity this remains allocated on the free store for the
   *  entire life span of the zipfilebuf object, unless replaced by setbuf.
  */
  char_type* buffer;

  /**
   *  @brief  Stream buffer size.
   *
   *  Defaults to system default buffer size (typically 8192 bytes).
   *  Modified by setbuf.
  */
  std::streamsize buffer_size;

  /**
   *  @brief  True if this object owns stream buffer.
   *
   *  This makes the class responsible for deleting the buffer
   *  upon destruction.
  */
  bool own_buffer;
};

/*****************************************************************************/

/**
 *  @brief  zip file input stream class.
 *
 *  This class implements ifstream for zip files. Seeking and putback
 *  is not supported yet.
*/
class zipifstream : public std::istream
{
public:
  //  Default constructor
  zipifstream();

  /**
   *  @brief  Construct stream on zip file to be opened.
   *  @param  name  File name.
   *  @param  mode  Open mode flags (forced to contain ios::in).
  */
  explicit
  zipifstream(const char* name,
             std::ios_base::openmode mode = std::ios_base::in);

  /**
   *  @brief  Construct stream on already open zip file.
   *  @param  fd    File descriptor.
   *  @param  mode  Open mode flags (forced to contain ios::in).
  */
/*
  explicit
  zipifstream(int fd,
             std::ios_base::openmode mode = std::ios_base::in);
*/

  /**
   *  Obtain underlying stream buffer.
  */
  zipfilebuf*
  rdbuf() const
  { return const_cast<zipfilebuf*>(&sb); }

  /**
   *  @brief  Check if file is open.
   *  @return  True if file is open.
  */
  bool
  is_open() { return sb.is_open(); }

  /**
   *  @brief  Open zip file.
   *  @param  name  File name.
   *  @param  mode  Open mode flags (forced to contain ios::in).
   *
   *  Stream will be in state good() if file opens successfully;
   *  otherwise in state fail(). This differs from the behavior of
   *  ifstream, which never sets the state to good() and therefore
   *  won't allow you to reuse the stream for a second file unless
   *  you manually clear() the state. The choice is a matter of
   *  convenience.
  */
  void
  open(const char* name,
       std::ios_base::openmode mode = std::ios_base::in);

  /**
   *  @brief  Close zip file.
   *
   *  Stream will be in state fail() if close failed.
  */
  void
  close();

private:
  /**
   *  Underlying stream buffer.
  */
  zipfilebuf sb;
};

/*****************************************************************************/

/**
 *  @brief  Gzipped file output stream class.
 *
 *  This class implements ofstream for zip files. Seeking and putback
 *  is not supported yet.
*/
class zipofstream : public std::ostream
{
public:
  //  Default constructor
  zipofstream();

  /**
   *  @brief  Construct stream on zip file to be opened.
   *  @param  name  File name.
   *  @param  mode  Open mode flags (forced to contain ios::out).
  */
  explicit
  zipofstream(const char* name, const char* filenameinzip,
             std::ios_base::openmode mode = std::ios_base::out);

  /**
   *  @brief  Construct stream on already open zip file.
   *  @param  fd    File descriptor.
   *  @param  mode  Open mode flags (forced to contain ios::out).
  */
/*
  explicit
  zipofstream(int fd,
             std::ios_base::openmode mode = std::ios_base::out);
*/

  /**
   *  Obtain underlying stream buffer.
  */
  zipfilebuf*
  rdbuf() const
  { return const_cast<zipfilebuf*>(&sb); }

  /**
   *  @brief  Check if file is open.
   *  @return  True if file is open.
  */
  bool
  is_open() { return sb.is_open(); }

  /**
   *  @brief  Open zip file.
   *  @param  name  File name.
   *  @param  mode  Open mode flags (forced to contain ios::out).
   *
   *  Stream will be in state good() if file opens successfully;
   *  otherwise in state fail(). This differs from the behavior of
   *  ofstream, which never sets the state to good() and therefore
   *  won't allow you to reuse the stream for a second file unless
   *  you manually clear() the state. The choice is a matter of
   *  convenience.
  */
  void
  open(const char* name, const char* filenameinzip,
       std::ios_base::openmode mode = std::ios_base::out);

  /**
   *  @brief  Close zip file.
   *
   *  Stream will be in state fail() if close failed.
  */
  void
  close();

private:
  /**
   *  Underlying stream buffer.
  */
  zipfilebuf sb;
};

/*****************************************************************************/

/**
 *  @brief  Gzipped file output stream manipulator class.
 *
 *  This class defines a two-argument manipulator for zipofstream. It is used
 *  as base for the setcompression(int,int) manipulator.
*/
template<typename T1, typename T2>
  class zipomanip2
  {
  public:
    // Allows insertor to peek at internals
    template <typename Ta, typename Tb>
      friend zipofstream&
      operator<<(zipofstream&,
                 const zipomanip2<Ta,Tb>&);

    // Constructor
    zipomanip2(zipofstream& (*f)(zipofstream&, T1, T2),
              T1 v1,
              T2 v2);
  private:
    // Underlying manipulator function
    zipofstream&
    (*func)(zipofstream&, T1, T2);

    // Arguments for manipulator function
    T1 val1;
    T2 val2;
  };

/*****************************************************************************/


// Manipulator constructor stores arguments
template<typename T1, typename T2>
  inline
  zipomanip2<T1,T2>::zipomanip2(zipofstream &(*f)(zipofstream &, T1, T2),
                              T1 v1,
                              T2 v2)
  : func(f), val1(v1), val2(v2)
  { }

// Insertor applies underlying manipulator function to stream
template<typename T1, typename T2>
  inline zipofstream&
  operator<<(zipofstream& s, const zipomanip2<T1,T2>& m)
  { return (*m.func)(s, m.val1, m.val2); }

/*****************************************************************************/

/* ---------------------------------------------------------------
 * 
 * The following functions are used in zipfilebuf.
 * (implemented by Akiya Jouraku)
 *
 * ---------------------------------------------------------------
 */

zipFile  zipopen (const char* path, const char* filenameinzip, int append);
int      zipclose(zipFile file);
int      zipwrite(zipFile file, voidp buf, unsigned len);

unzFile  unzipopen (const char* path);
int      unzipclose(unzFile file);
int      unzipread (unzFile file, voidp buf, unsigned len);



#endif // ZIPFSTREAM_H

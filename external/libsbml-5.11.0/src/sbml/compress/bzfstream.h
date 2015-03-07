/**
 * @file    bzfstream.h
 * @brief   C++ I/O streams interface to the bzlib bz* functions
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
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------- -->
 *
 * Most of the code (except for bzip2 specific code) is based on zfstream.h 
 * implemented by Ludwig Schwardt <schwardt@sun.ac.za> 
 * original version by Kevin Ruland <kevin@rodin.wustl.edu>
 * zfstream.h is contained in the contributed samples in zlib version 1.2.3
 * (http://www.zlib.net).
 *
 * ---------------------------------------------------------------------- -->*/


#ifndef BZFSTREAM_H
#define BZFSTREAM_H

#include <istream>  // not iostream, since we don't need cin/cout
#include <ostream>
#include "bzlib.h"

/*****************************************************************************/

/**
 *  @brief  bzip2 file stream buffer class.
 *
 *  This class implements basic_filebuf for bzip2 files. It doesn't yet support
 *  seeking (allowed by zlib but slow/limited), putback and read/write access
 *  (tricky). Otherwise, it attempts to be a drop-in replacement for the standard
 *  file streambuf.
*/
class bzfilebuf : public std::streambuf
{
public:
  //  Default constructor.
  bzfilebuf();

  //  Destructor.
  virtual
  ~bzfilebuf();

  /**
   *  @brief  Check if file is open.
   *  @return  True if file is open.
  */
  bool
  is_open() const { return (file != NULL); }

  /**
   *  @brief  Open bzip2 file.
   *  @param  name  File name.
   *  @param  mode  Open mode flags.
   *  @return  @c this on success, NULL on failure.
  */
  bzfilebuf*
  open(const char* name,
       std::ios_base::openmode mode);

  /**
   *  @brief  Attach to already open bzip2 file.
   *  @param  fd  File descriptor.
   *  @param  mode  Open mode flags.
   *  @return  @c this on success, NULL on failure.
  */
  bzfilebuf*
  attach(int fd,
         std::ios_base::openmode mode);

  /**
   *  @brief  Close bzip2 file.
   *  @return  @c this on success, NULL on failure.
  */
  bzfilebuf*
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
   *  These characters can be read without accessing the bzip2 file.
  */
  virtual std::streamsize
  showmanyc();

  /**
   *  @brief  Fill get area from bzip2 file.
   *  @return  First character in get area on success, EOF on error.
   *
   *  This actually reads characters from bzip2 file to stream
   *  buffer. Always buffered.
  */
  virtual int_type
  underflow();

  /**
   *  @brief  Write put area to bzip2 file.
   *  @param  c  Extra character to add to buffer contents.
   *  @return  Non-EOF on success, EOF on error.
   *
   *  This actually writes characters in stream buffer to
   *  bzip2 file. With unbuffered output this is done one
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
   *  Underlying file pointer.
  */
  BZFILE* file;

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
   *  entire life span of the bzfilebuf object, unless replaced by setbuf.
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
 *  @brief  bzip2 file input stream class.
 *
 *  This class implements ifstream for bzip2 files. Seeking and putback
 *  is not supported yet.
*/
class bzifstream : public std::istream
{
public:
  //  Default constructor
  bzifstream();

  /**
   *  @brief  Construct stream on bzip2 file to be opened.
   *  @param  name  File name.
   *  @param  mode  Open mode flags (forced to contain ios::in).
  */
  explicit
  bzifstream(const char* name,
             std::ios_base::openmode mode = std::ios_base::in);

  /**
   *  @brief  Construct stream on already open bzip2 file.
   *  @param  fd    File descriptor.
   *  @param  mode  Open mode flags (forced to contain ios::in).
  */
  explicit
  bzifstream(int fd,
             std::ios_base::openmode mode = std::ios_base::in);

  /**
   *  Obtain underlying stream buffer.
  */
  bzfilebuf*
  rdbuf() const
  { return const_cast<bzfilebuf*>(&sb); }

  /**
   *  @brief  Check if file is open.
   *  @return  True if file is open.
  */
  bool
  is_open() { return sb.is_open(); }

  /**
   *  @brief  Open bzip2 file.
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
   *  @brief  Attach to already open bzip2 file.
   *  @param  fd  File descriptor.
   *  @param  mode  Open mode flags (forced to contain ios::in).
   *
   *  Stream will be in state good() if attach succeeded; otherwise
   *  in state fail().
  */
  void
  attach(int fd,
         std::ios_base::openmode mode = std::ios_base::in);

  /**
   *  @brief  Close bzip2 file.
   *
   *  Stream will be in state fail() if close failed.
  */
  void
  close();

private:
  /**
   *  Underlying stream buffer.
  */
  bzfilebuf sb;
};

/*****************************************************************************/

/**
 *  @brief  Gzipped file output stream class.
 *
 *  This class implements ofstream for bzip2 files. Seeking and putback
 *  is not supported yet.
*/
class bzofstream : public std::ostream
{
public:
  //  Default constructor
  bzofstream();

  /**
   *  @brief  Construct stream on bzip2 file to be opened.
   *  @param  name  File name.
   *  @param  mode  Open mode flags (forced to contain ios::out).
  */
  explicit
  bzofstream(const char* name,
             std::ios_base::openmode mode = std::ios_base::out);

  /**
   *  @brief  Construct stream on already open bzip2 file.
   *  @param  fd    File descriptor.
   *  @param  mode  Open mode flags (forced to contain ios::out).
  */
  explicit
  bzofstream(int fd,
             std::ios_base::openmode mode = std::ios_base::out);

  /**
   *  Obtain underlying stream buffer.
  */
  bzfilebuf*
  rdbuf() const
  { return const_cast<bzfilebuf*>(&sb); }

  /**
   *  @brief  Check if file is open.
   *  @return  True if file is open.
  */
  bool
  is_open() { return sb.is_open(); }

  /**
   *  @brief  Open bzip2 file.
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
  open(const char* name,
       std::ios_base::openmode mode = std::ios_base::out);

  /**
   *  @brief  Attach to already open bzip2 file.
   *  @param  fd  File descriptor.
   *  @param  mode  Open mode flags (forced to contain ios::out).
   *
   *  Stream will be in state good() if attach succeeded; otherwise
   *  in state fail().
  */
  void
  attach(int fd,
         std::ios_base::openmode mode = std::ios_base::out);

  /**
   *  @brief  Close bzip2 file.
   *
   *  Stream will be in state fail() if close failed.
  */
  void
  close();

private:
  /**
   *  Underlying stream buffer.
  */
  bzfilebuf sb;
};

/*****************************************************************************/

/**
 *  @brief  Gzipped file output stream manipulator class.
 *
 *  This class defines a two-argument manipulator for bzofstream. It is used
 *  as base for the setcompression(int,int) manipulator.
*/
template<typename T1, typename T2>
  class bzomanip2
  {
  public:
    // Allows insertor to peek at internals
    template <typename Ta, typename Tb>
      friend bzofstream&
      operator<<(bzofstream&,
                 const bzomanip2<Ta,Tb>&);

    // Constructor
    bzomanip2(bzofstream& (*f)(bzofstream&, T1, T2),
              T1 v1,
              T2 v2);
  private:
    // Underlying manipulator function
    bzofstream&
    (*func)(bzofstream&, T1, T2);

    // Arguments for manipulator function
    T1 val1;
    T2 val2;
  };

/*****************************************************************************/


// Manipulator constructor stores arguments
template<typename T1, typename T2>
  inline
  bzomanip2<T1,T2>::bzomanip2(bzofstream &(*f)(bzofstream &, T1, T2),
                              T1 v1,
                              T2 v2)
  : func(f), val1(v1), val2(v2)
  { }

// Insertor applies underlying manipulator function to stream
template<typename T1, typename T2>
  inline bzofstream&
  operator<<(bzofstream& s, const bzomanip2<T1,T2>& m)
  { return (*m.func)(s, m.val1, m.val2); }


#endif // BZFSTREAM_H

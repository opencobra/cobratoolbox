/**
 * @file    bzfstream.cpp
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
 * ---------------------------------------------------------------------- -->
 *
 * Most of the code (except for bzip2 specific code) is based on zfstream.cc
 * implemented by Ludwig Schwardt <schwardt@sun.ac.za> 
 * original version by Kevin Ruland <kevin@rodin.wustl.edu>
 * zfstream.cc is contained in the contributed samples in zlib version 1.2.3
 * (http://www.zlib.net).
 *
 * ---------------------------------------------------------------------- -->*/

#include "bzfstream.h"
#include <cstring>          // for strcpy, strcat, strlen (mode strings)
#include <cstdio>           // for BUFSIZ

// Internal buffer sizes (default and "unbuffered" versions)
#define BIGBUFSIZE BUFSIZ
#define SMALLBUFSIZE 1

/*****************************************************************************/

// Default constructor
bzfilebuf::bzfilebuf()
: file(NULL), io_mode(std::ios_base::openmode(0)), own_fd(false),
  buffer(NULL), buffer_size(BIGBUFSIZE), own_buffer(true)
{
  // No buffers to start with
  this->disable_buffer();
}

// Destructor
bzfilebuf::~bzfilebuf()
{
  // Sync output buffer and close only if responsible for file
  // (i.e. attached streams should be left open at this stage)
  this->sync();
  if (own_fd)
    this->close();
  // Make sure internal buffer is deallocated
  this->disable_buffer();
}

// Open bzip2 file
bzfilebuf*
bzfilebuf::open(const char *name,
                std::ios_base::openmode mode)
{
  // Fail if file already open
  if (this->is_open())
    return NULL;
  // Don't support simultaneous read/write access (yet)
  if ((mode & std::ios_base::in) && (mode & std::ios_base::out))
    return NULL;

  // Build mode string for bzopen and check it [27.8.1.3.2]
  char char_mode[6] = "\0\0\0\0\0";
  if (!this->open_mode(mode, char_mode))
    return NULL;

  // Attempt to open file
  if ((file = BZ2_bzopen(name, char_mode)) == NULL)
    return NULL;

  // On success, allocate internal buffer and set flags
  this->enable_buffer();
  io_mode = mode;
  own_fd = true;
  return this;
}

// Attach to bzip2 file
bzfilebuf*
bzfilebuf::attach(int fd,
                  std::ios_base::openmode mode)
{
  // Fail if file already open
  if (this->is_open())
    return NULL;
  // Don't support simultaneous read/write access (yet)
  if ((mode & std::ios_base::in) && (mode & std::ios_base::out))
    return NULL;

  // Build mode string for bzdopen and check it [27.8.1.3.2]
  char char_mode[6] = "\0\0\0\0\0";
  if (!this->open_mode(mode, char_mode))
    return NULL;

  // Attempt to attach to file
  if ((file = BZ2_bzdopen(fd, char_mode)) == NULL)
    return NULL;

  // On success, allocate internal buffer and set flags
  this->enable_buffer();
  io_mode = mode;
  own_fd = false;
  return this;
}

// Close bzip2 file
bzfilebuf*
bzfilebuf::close()
{
  // Fail immediately if no file is open
  if (!this->is_open())
    return NULL;
  // Assume success
  bzfilebuf* retval = this;
  // Attempt to sync and close bzip2 file
  if (this->sync() == -1)
    retval = NULL;
  int errnum = 0;
  BZ2_bzerror(file, &errnum);
  if (errnum > 0)
    retval = NULL;
  BZ2_bzclose(file);
  // File is now gone anyway (postcondition [27.8.1.3.8])
  file = NULL;
  own_fd = false;
  // Destroy internal buffer if it exists
  this->disable_buffer();
  return retval;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Convert int open mode to mode string
bool
bzfilebuf::open_mode(std::ios_base::openmode mode,
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
    c_mode[1] = 'b';
    //strcat(c_mode, "b");
  return true;
}

// Determine number of characters in internal get buffer
std::streamsize
bzfilebuf::showmanyc()
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

// Fill get area from bzip2 file
bzfilebuf::int_type
bzfilebuf::underflow()
{
  // If something is left in the get area by chance, return it
  // (this shouldn't normally happen, as underflow is only supposed
  // to be called when gptr >= egptr, but it serves as error check)
  if (this->gptr() && (this->gptr() < this->egptr()))
    return traits_type::to_int_type(*(this->gptr()));

  // If the file hasn't been opened for reading, produce error
  if (!this->is_open() || !(io_mode & std::ios_base::in))
    return traits_type::eof();

  // Attempt to fill internal buffer from bzip2 file
  // (buffer must be guaranteed to exist...)
  int bytes_read = (int)BZ2_bzread(file, buffer, (int)buffer_size);
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

// Write put area to bzip2 file
bzfilebuf::int_type
bzfilebuf::overflow(int_type c)
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
      // If bzip2 file won't accept all bytes written to it, fail
      if (BZ2_bzwrite(file, this->pbase(), bytes_to_write) != bytes_to_write)
        return traits_type::eof();
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
    // If bzip2 file won't accept this character, fail
    if (BZ2_bzwrite(file, &last_char, 1) != 1)
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
bzfilebuf::setbuf(char_type* p,
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

// Write put area to bzip2 file (i.e. ensures that put area is empty)
int
bzfilebuf::sync()
{
  return traits_type::eq_int_type(this->overflow(), traits_type::eof()) ? -1 : 0;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Allocate internal buffer
void
bzfilebuf::enable_buffer()
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
bzfilebuf::disable_buffer()
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
bzifstream::bzifstream()
: std::istream(NULL), sb()
{ this->init(&sb); }

// Initialize stream buffer and open file
bzifstream::bzifstream(const char* name,
                       std::ios_base::openmode mode)
: std::istream(NULL), sb()
{
  this->init(&sb);
  this->open(name, mode);
}

// Initialize stream buffer and attach to file
bzifstream::bzifstream(int fd,
                       std::ios_base::openmode mode)
: std::istream(NULL), sb()
{
  this->init(&sb);
  this->attach(fd, mode);
}

// Open file and go into fail() state if unsuccessful
void
bzifstream::open(const char* name,
                 std::ios_base::openmode mode)
{
  if (!sb.open(name, mode | std::ios_base::in))
    this->setstate(std::ios_base::failbit);
  else
    this->clear();
}

// Attach to file and go into fail() state if unsuccessful
void
bzifstream::attach(int fd,
                   std::ios_base::openmode mode)
{
  if (!sb.attach(fd, mode | std::ios_base::in))
    this->setstate(std::ios_base::failbit);
  else
    this->clear();
}

// Close file
void
bzifstream::close()
{
  if (!sb.close())
    this->setstate(std::ios_base::failbit);
}

/*****************************************************************************/

// Default constructor initializes stream buffer
bzofstream::bzofstream()
: std::ostream(NULL), sb()
{ this->init(&sb); }

// Initialize stream buffer and open file
bzofstream::bzofstream(const char* name,
                       std::ios_base::openmode mode)
: std::ostream(NULL), sb()
{
  this->init(&sb);
  this->open(name, mode);
}

// Initialize stream buffer and attach to file
bzofstream::bzofstream(int fd,
                       std::ios_base::openmode mode)
: std::ostream(NULL), sb()
{
  this->init(&sb);
  this->attach(fd, mode);
}

// Open file and go into fail() state if unsuccessful
void
bzofstream::open(const char* name,
                 std::ios_base::openmode mode)
{
  if (!sb.open(name, mode | std::ios_base::out))
    this->setstate(std::ios_base::failbit);
  else
    this->clear();
}

// Attach to file and go into fail() state if unsuccessful
void
bzofstream::attach(int fd,
                   std::ios_base::openmode mode)
{
  if (!sb.attach(fd, mode | std::ios_base::out))
    this->setstate(std::ios_base::failbit);
  else
    this->clear();
}

// Close file
void
bzofstream::close()
{
  if (!sb.close())
    this->setstate(std::ios_base::failbit);
}


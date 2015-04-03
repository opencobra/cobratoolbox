========== Ruby API for LibSBML ==========

--------------------
1. Authors
--------------------

* Alex Gutteridge 
* Akiya Jouraku 

--------------------
2. Description
--------------------

This module provide Ruby API for LibSBML library. 
Most of API functions (except for the classes/functions used for internal use)
are wrapped by using SWIG (http://www.swig.org).

--------------------
3. Introduction
--------------------

Here is a simple example that reads a model and prints any errors encountered.

----------------------------------------------------------------
require 'libSBML'

if ARGV.size != 1
  puts "Usage: ruby readSBML filename"
  exit(1)
end

reader   = LibSBML::SBMLReader.new;
document = reader.readSBML(ARGV[0]); 

puts "   filename: #{ARGV[0]}\n"
puts "   error(s): #{document.getNumErrors}\n"

if document.getNumErrors > 0
  document.printErrors
end
----------------------------------------------------------------

The code begins by 'require libSBML'. This directive is required to use Ruby 
API of LibSBML library.
After checking that it has been supplied with an argument at run-time, an
'SBMLReader' object is created. In Ruby bindings, the prefix 'LibSBML::' is 
required to access wrapped LibSBML classes or constants (The prefix can be 
ommitted when 'include LibSBML' directive used.). 
Next, the program reads a file using the method 'readSBML', which returns an 
instance of an 'SBMLDocument' object. A subsequent call to the 'getNumErrors'
method on the returned object returns the number of errors encountered (if any), 
and the call to 'printErrors' prints them to the standard error output stream.

--------------------
4. Configuration
--------------------

To run the Ruby version of libSBML, you must make sure that your 'RUBYLIB' environment
variable includes the file 'libSBML.so' (Linux) or 'libSBML.bundle' (MacOSX), and that 
your dynamic library search path variable includes the directory in which the 'libsbml.so' 
(Linux) or libsbml.dylib (MacOSX) file is located.

As an example, if you were running under Linux and you configured libSBML with a prefix 
of '/usr/local' and did a normal "make install", and you were using Ruby 1.8.x and the 
typical sh or bash shell in your terminal, you would need to execute

  export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
  export RUBYLIB="/usr/local/lib/ruby/site_ruby/1.8/i386-linux:$RUBYLIB"

  (In MacOSX, 'DYLD_LIBRARY_PATH' is used instead of 'LD_LIBRARY_PATH'.)

or put the above in your shell's initialization file (.bashrc or .profile in your home 
directory) and cause the shell to re-read the initialization file. In addition, prior to 
running Ruby programs, you would need to either (1) set your 'RUBYLIB' environment variable 
to include the 'libSBML.so' file, or (2) include the file in the '-I' option passed to the 
Ruby interpreter when it is started.

-----------------------
5. Example programs
-----------------------

You can find example programs in the './test/' directory or in the 'examples/ruby/' directory.

------------------------------------------
6.  Licensing, Copyrights and Distribution
------------------------------------------

The terms of redistribution for this software are stated in the files LICENSE.txt and COPYING.txt 
at the top level of the libSBML distribution.


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


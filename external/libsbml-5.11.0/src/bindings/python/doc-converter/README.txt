			   rewrite_pydoc.py

			    Michael Hucka
		  Computing + Mathematical Sciences
		  California Institute of Technology

             Version 2 written in October-November, 2013

	More information about libSBML is available online at
		   http://sbml.org/Software/libSBML


Introduction
======================================================================

The comments in the libSBML source code use Doxygen mark-up; this
content is read by Doxygen and Javadoc, in combination with other
scripts, to produce the libSBML API documentation in the libSBML "docs"
directory.  When creating the Python language interface, SWIG takes the
comments and inserts them as documentation strings in the Python code,
which is good from the perspective of being an easy way to provide help
for the Python interface classes and methods, but bad from the
perspective that it is full of Doxygen markup and not suitable for
direct reading by humans.

This program converts the Doxygen-based documentation strings by
rewriting them to plain text.  This plain text can then be included in the
final Python bindings for libSBML, so that users can use the Python
interactive help system to view the documentation.

This program is not a general converter; it is designed specifically
to work with the way that we generate the libSBML python bindings.
However, it should not be too difficult to adapt to other similar
software projects.

The main hardwired assumptions are the following:

* The input file to rewrite_pydoc.py is the output produced by our
  ../../swig/swigdoc.py, which produces documentation definitions for
  swig.  These have the form shown in the following example:

     %feature("docstring") SBMLReader::SBMLReader "
     Creates a new SBMLReader and returns it. 

     The libSBML SBMLReader objects offer methods for reading SBML in
     XML form from files and text strings.
     ";

  The output of rewrite_pydoc.py is another .i file in which all
  Doxygen tags have been translated and the docstring contents have
  been reformatted for use in the python plain-text interactive help
  system.

* In our process for producing the libSBML Python bindings, we take
  the output of rewrite_pydoc.py and include it in the input to swig.
  This is done via an %include command in the ../local.i file.  The
  consequence is that swig reads these %feature commands, and uses
  them when it produces a file named "libsbml.py" containing the
  Python code for the libSBML interface.  The objects and methods in
  "libsbml.py" contain Python-style "docstrings" that are a
  combination of we defined in the .i file and what swig itself
  constructs.  (In particular, swig adds documentation about the
  method signatures, because the methods are interfaces to native code
  and Python introspection cannot reveal the data types of the
  parameters.)

* The Doxygen markup understood by rewrite_pydoc.py is not the
  complete set of all possible Doxygen tags.  We don't use all
  possible Doxygen tags in the libSBML documentation, and so this
  program only looks for the ones we have been using.

* We add our own Doxygen markup commands as aliases.  At the time
  of this writing, the main aliases are @sbmlpackage{...} and
  @sbmlbrief{...}.  This converter is designed to recognize and
  process these commands.


Procedure
======================================================================

The procedure is slightly complicated by the fact that we still use
Doxygen to produce the API documentation in HTML format.  Thus, we
still need a version of the swig-produced "libsbml.py" file that
contains the Doxygen tags, but we don't want to use that version of
the file in producing the final libSBML bindings.  (For the bindings,
we want to use the version of "libsbml.py" that contains the
plain-text version of the documentation strings.)  Therefore, we
produce two files of documentation strings, one called "pydoc-doxygen.i"
and another "pydoc-normal.i".  We use each of these in separate steps
to produce two versions of "libsbml.py".

1. Run swigdoc.py to produce pydoc-doxygen.i

2. Run rewrite_pydoc.py on pydoc-doxygen.i to produce pydoc-normal.i

3. Create a version of libsbml.py that will be fed only to Doxygen to
   produce the API documentation:

   a. Rename pydoc-doxygen.i to pydoc.i temporarily
   b. Run swig
   c. Rename the resulting libsbml.py to libsbml-doxygen.py

4. Create the version of libsbml.py that is actually used as the
   libSBML Python bindings:

   a. Rename pydoc-normal.i to pydoc.i temporarily
   b. Run swig
   c. Process the libsbml.py the rest of the way to produce the final
      Python bindings module

These procedure are captured in the Makefile in the parent (..) 
directory.


Special features
======================================================================

* This parser understands HTML tables to a limited degree, and
  converts them to text tables with the help of the PrettyTable
  library (included).  The parser is far from being a full-featured
  HTML or HTML table parser, but it handles basic tables reasonably
  well.  It does not recognize row spans, column spans, or CSS
  styling.

* When expanding @htmlinclude directives, it first checks to see if a
  version of the named file, but with a .txt extension, exists in the
  same location where it finds the .html file.  If the .txt eversion
  exists, it includes that instead of the .html file.  (This allows
  hand-formatted text files to be used, which is useful for providing
  tables to replace HTML tables that the built-in table parser does
  not handle nicely.)

* When expanding @image directives, it looks for a file with the
  extension .txt in the same directory where it finds the .jpg file.
  If the .txt version exists, it includes that; if it doesn't exist,
  it does not include anything.  (Since the docstrings are plain-text,
  no other action seems sensible in this context.)


Third-party software incorporated into rewrite_pydoc.py
======================================================================

The copy of "argparse.py" included in this directory is to provide
compatibility with Python versions before 2.7 and 3.2, where argparse is
not part of the standard set of modules.  The file argparse.py came from
http://pypi.python.org/pypi/argparse/.

The copy of "prettytable.py" came from the PrettyTable 0.7.2 distribution,
available from http://code.google.com/p/prettytable/ and redistributable
under modified BSD license terms.  Please see the subdirectory
"prettytable-0.7.2" for the original code and licensing terms.  We use
prettytable.py from rewrite_pydoc.py as part of the HTML table to text
conversion facility.




# The following is for [X]Emacs users.  Please leave in place.
# Local Variables:
# fill-column: 70
# End:

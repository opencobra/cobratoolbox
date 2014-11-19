
                            l i b S B M L

		     Example programs and models

      Sarah Keating, Akiya Jouraku, Ben Bornstein, Michael Hucka
	   with contributions from (in alphabetical order)
   Frank Bergmann, Christoph Flamm, Ralph Gauges, Alex Gutteridge,
		 Rainer Machne, and Nicolas Rodriguez

        More information about libSBML is available online at
                   http://sbml.org/Software/libSBML

			    The SBML Team
			 http://www.sbml.org/
		     mailto:sbml-team@caltech.edu

		  Date of last update to this file:
		  $Date: 2009-01-04 11:26:05 +0900#$


There are separate subdirectories for different programming languages:
"c" for example programs in the C language, "c++" for examples in C++,
"java" for examples in Java, etc.  You will first need to change your
working directory to one of these subdirectories.

The Makefile in each subdirectory is kept simple for illustrative
purposes.  For this reason, you may need to modify some of the values
assigned to variables in the Makefiles in order that they correspond
to your particular environment.

Once this is done, at the Unix command prompt, you should be able to
type the following command to compile the example programs in a given
language subdirectory:

  % make

Next, you may wish to try running the example programs on some SBML
files.  There are a number of sample models provided for this purpose
in the "sample-models" subdirectory here.  So, for example, you could
do try the following (if you were in the "c++" subdirectory):

  % printSBML     ../sample-models/from-spec/level-2/algebraicrules.xml
  % readSBML      ../sample-models/from-spec/level-2/dimerization.xml
  % convertSBML   ../sample-models/from-spec/level-2/enzymekinetics.xml
  % validateSBML  ../sample-models/from-spec/level-2/twodimensional.xml
  % validateSBML  ../sample-models/from-spec/level-2/overdetermined.xml

More models may be obtained from a number of other sources, including
the BioModels Database (http://www.ebi.ac.uk/biomodels/).







-------------------------------------------
File authors: M. Hucka, B. Bornstein
-------------------------------------------

# The following is for [X]Emacs users.  Please leave in place.
# Local Variables:
# fill-column: 70
# End:

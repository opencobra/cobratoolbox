slocstat

This Matlab function calculates the (effective) source lines of (Matlab) code.
It is possible to call it for any function name that is in Matlab's current 
search path, a filename, or a directory. If you call the function for a 
directory, then recursion is used to calculate the sloc count for all files
in the folder and its sub-folders.

A function to show a sorted list of files (sorty by SLOC, ascending) is also
provided.

Please have a look into 'example.m' to see how to use the code.

It is also possible to change the function that processes individual files.
This way you can, e.g., integrate/use a C++/C or .txt handler. Currently,
there are actually two places where you can do it: First, you can modify/
extend 'calcsloc' or you completely replace 'calcsloc' with an interface-
compatible version.

Of course similar packages exist such as, e.g., 
  sloc (http://www.mathworks.com/matlabcentral/fileexchange/3900-sloc)
  slocDir (http://www.mathworks.com/matlabcentral/fileexchange/23837-slocdir)
However, this code is a rewrite that features more functionality and directly
bundles the functionality of slocDir with sloc. Nevertheless, if you don't 
like this package, I would suggest that you check the packages referenced
above, maybe they are more like what you are searching for.
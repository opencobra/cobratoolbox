
SBML-FBCv2 update note
----------------------

`The COBRA toolbox` fully supports reading SBML level 3 version 1 using the `fbc` package version 2 and the `group` package. The output SBML files are also generated in this format.
Older SBML versions can be imported and COBRA Style `Notes` annotations will be interpreted.

The function to read a model in sbml format is the same as any other model: `readCbModel`. If the sbml file does not have an `.xml` ending, the format switch needs to be provided. If it is an `xml` file `readCbModel` will automatically detect the format.

To write a model in sbml use the `writeCbModel` function.

The SBML IO depends on the binaries provided by the [SBML project](http://sbml.org/). As such, new OS versions and new Matlab versions might not be immediately supported.

If an SBML-FBCv2 file is exported from a COBRA Matlab structure without an objective function defined (i.e. an all 0 `model.c` vector), validation of the SBML-FBCv2 file on [BiGG validator](http://bigg.ucsd.edu/validator/app) may give a warning.

Solutions to some potential issues with reading/writing FBC files.

1. Ensure there are NO multiple versions of COBRA toolbox on the Matlab path.
2. Ensure that `which('OutputSBML')` and `which('TranslateSBML')` point to the binaries in the binary folder.
3. Validate the problematic SBML file using the [online SBML validator](http://sbml.org/validator/) and [BiGG validator](http://bigg.ucsd.edu/validator/app).

If none of these troubleshooting steps can help identify the issues with your FBC file, please file your query on the [COBRA group](https://groups.google.com/forum/#!forum/cobra-toolbox). 

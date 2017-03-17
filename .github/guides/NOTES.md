
SBML-FBCv2 update note
----------------------

`The COBRA toolbox` supports reading SBML with FBC-v2 files and writing COBRA-Matlab structures to SBML-FBCv2 files. Two COBRA functions, `io/readCbModel.m` and `io/writeCbModel.m`, were updated in 04/2016 to support the input and output of COBRA models in the SBML-FBCv2 files.

The `io/readCbModel.m` function is dependent on another function `io/utilities/readSBML.m` to use [`libSBML` library](http://sbml.org/Software/libSBML), to parse a SBML-FBCv2 file into a COBRA-Matlab structure. The `io/readCbModel.m` function is backward compatible with older SBML versions. A list of fields of a COBRA structure is described in a Excel spreadsheet `io/COBRA_structure_fields.xlsx`. While some fields are necessary for a COBRA model, others are not.

The `io/writeCbModel`  function relies on another function `io/utilities/writeSBML.m` to convert a COBRA-Matlab structure into a libSBML-Matlab structure and then call `libSBML` to export a FBCv2 file. The current version of the `io/writeSBML.m` does **NOT** require the SBML [toolbox](http://sbml.org/Software/SBMLToolbox).

1. When reading some old COBRA SBML files, there could be some warning messages in the command window, which are probably caused by the lack of some reconstruction information (e.g., metabolite charges) in the SBML files. It is safe to ignore the messages.
2. When exporting a COBRA Matlab structure to an FBC file, it is usually required that the objective coefficient vector (the c field) of the COBRA model structure is not all zeros  (i.e., at least one objective function is specified), which is demanded by the FBC extension.

If an SBML-FBCv2 file is exported from a COBRA Matlab structure without an objective function defined, validation of the SBML-FBCv2 file on [BiGG validator](http://bigg.ucsd.edu/validator/app) may give a warning.

Solutions to some potential issues with reading/writing FBC files.

1. Ensure there are NO multiple versions of COBRA toolbox on the Matlab path.
2. Currently the latest libSBML 5.13.0 supports FBCv2 extension. Ensure the old versions of libSBML Matlab bindings are NOT on the Matlab path.
3. Validate the problematic FBC file using the [online SBML validator](http://sbml.org/validator/) and [BiGG validator](http://bigg.ucsd.edu/validator/app).

If none of these troubleshooting steps can help identify the issues with your FBC file, please contact Dr. Ronan Fleming (ronan.mt.fleming@gmail.com)

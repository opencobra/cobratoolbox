
The COBRA toolbox has supported the SBML with FBC-v2 extension format since 10/2015. Same as the earlier versions of the toolbox, the "readCbModel" function is provided to read a COBRA SBML-FBC file into a Matlab structure, and the "writeCbToSBML" function or a new function "writeCbToSBMLfbc" are provided to write a COBRA Matlab structure to an SBML-FBC file. "writeCbToSBMLfbc" is an improved version of the "writeCbToSBML" function that can be used to export the structure imported from an old SBML file (e.g., SBML level 2 version 1 , prior to FBC), to an FBC file.

The io functions mentioned before rely on the libSBML library to parse the SBML files, so any files compatible with the libSBML library should be able to work with the COBRA toolbox.

Notes: 

    1) When reading some old COBRA SBML files, there could be some warning messages in the command window, which are probably caused by the lack of some reconstruction information in the SBML files. It is safe to ignore the messages.

    2) When exporting a COBRA Matlab structure to an FBC file, it is needed to ensure an objective function is specified in the structure. This means that at least one value of the objective coefficient vector (i.e., the c field of the COBRA model structure) should be set to a number other than zero. For example, if a COBRA SBML file is in the SBML level 2 version 1 format, to convert the Matlab structure of the old SBML file to a FBC file, it is necessary to ensure the objective coefficient vector (the c field) is not all zeros  (at least one objective function is defined), which is required by the FBC extension.


Solutions to issues with reading/writing FBC files

   1) Ensure there are NO multiple versions of COBRA toolbox on the Matlab path. 

   2) Only libSBML 5.11.8 or higher versions support FBC models. Ensure the old versions of libSBML Matlab bindings are NOT on the Matlab path.

   3) Validate the problematic FBC file using the online SBML validator (http://sbml.org/validator/).

If none of these troubleshooting steps can help identify the issues with your FBC file, please contact the COBRA developer team (the Contact info is available on http://opencobra.github.io/cobratoolbox/



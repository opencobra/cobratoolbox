% OutputSBML(model, (filename), (extensionsAllowed), (applyUserValidation), (fbcGeneProductOptions))) 
% outputs an xml file
%
% The function OutputSBML is the converse of TranslateSBML: 
% it writes an MATLAB_SBML structure to an XML file. It accepts two arguments:
%
%   * model: This argument must be a MATLAB_SBML structure representing the 
%            model to be written out to a file. Note that the structure will 
%            not be validated to check if it is fully correct SBML; OutputSBML 
%            will only verify the basic integrity of the structure (i.e., to 
%            make sure it has the form expected of a MATLAB_SBML structure), 
%            but nothing more.
%
%   * filename: The name of the file where the SBML content should be written.
%
%        NOTE: This argument is optional where a graphical user interface is
%                      available, in which case a missing argument will open a browse window.
%                      relative to the current working directory). 
%
%   * extensionsAllowed: An optional argument indicating that when 
%             determining whether the MATLAB_SBML structure represents 
%             a valid structure any additional fields are ignored. The default value is 1.
%             If this argument is set to 0, a structure will be considered 
%             valid if it contains only the expected fields and no additional fields.
%
%   * applyUserValidation: An optional argument indicating that when 
%             determining whether the MATLAB_SBML structure represents 
%             a valid structure user defined validation is applied. The default
%             value is 0 which disables custom validation. A value of 1 
%             indicates that when using the function 'isSBML_Model' to assess 
%             whether the MATLAB_SBML structure is correct the 
%             'applyUserValidation' function should be invoked. This allows a 
%             user to add their own custom validation criteria to the export of SBML.
%
%   * fbcGeneProductOptions: This optional argument is an array of two values that
%               allows the user to change the behavior relating to
%               geneProduct elements in the fbc package.
%                  - The first value in the array impacts of the infix respresentation of a 
%                     GeneProductAssociation.
%                     A value of [0, n] (the default) indicates that OutputSBML 
%                     should interpret the geneProductAssociation using the label
%                     attribute to refer to the geneProduct.  A value of [1,n]
%                     indicates the id attribute should be used.
%
%                  - The second entry in the array indicates whether OutputSBML
%                     should add geneProduct elements if it encounters a
%                     label/id in an association element that does not
%                     correspond to an existing geneProduct.  
%                     A value of [n, 1] (the default) will add missing geneProducts. A value of
%                     [n, 0] turns off this behavior.
%

%  Filename    : OutputSBML.m
%  Description : MATLAB help file for OutputSBML
%  Author(s)   : SBML Development Group <sbml-team@googlegroups.com>
%
%<!---------------------------------------------------------------------------
% This file is part of libSBML.  Please visit http://sbml.org for more
% information about SBML, and the latest version of libSBML.
%
% Copyright (C) 2013-2017 jointly by the following organizations:
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
%     3. University of Heidelberg, Heidelberg, Germany
%
% Copyright (C) 2009-2013 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
%  
% Copyright (C) 2006-2008 by the California Institute of Technology,
%     Pasadena, CA, USA 
%  
% Copyright (C) 2002-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. Japan Science and Technology Agency, Japan
% 
% This library is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution
% and also available online as http://sbml.org/software/libsbml/license.html
%
% The original code contained here was initially developed by:
%
%      Sarah Keating
%      Science and Technology Research Centre
%      University of Hertfordshire
%      Hatfield, AL10 9AB
%      United Kingdom
%
%      http://www.sbml.org
%      mailto:sbml-team@googlegroups.com
%
% Contributor(s):
%

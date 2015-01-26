function y = compareFiles(file1, file2)

%  Filename    :   CompareFiles.m
%  Description :
%  $Source v $
%
%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2013-2014 jointly by the following organizations:
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
% in the file named "LICENSE.txt" included with this software distribution.
% and also available online as http://sbml.org/software/sbmltoolbox/license.html
%----------------------------------------------------------------------- -->

fid1 = fopen(file1);
fid2 = fopen(file2);
y = 0;
while (~feof(fid1) || ~feof(fid2))
  line1 = fgetl(fid1);
  line2 = fgetl(fid2);

  if (~strcmp(line1, line2))
    disp(sprintf('%s is Not equal to %s', line1, line2));
     y = 1;
     return;
  end;
end;

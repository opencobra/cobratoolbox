function enabled = isEnabled(package)
%  enabled = isEnabled(package)
% 
% Takes
%
% 1. package - a string representing an SBML L3 package
%
% Returns
%
% 1. enabled 
%   - 1, if the package can be used by this instance of libSBML
%   - 0, otherwise

%<!---------------------------------------------------------------------------
% This file is part of libSBML.  Please visit http://sbml.org for more
% information about SBML, and the latest version of libSBML.
%
% Copyright (C) 2013-2018 jointly by the following organizations:
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
% This library is free software; you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as
% published by the Free Software Foundation.  A copy of the license
% agreement is provided in the file named "LICENSE.txt" included with
% this software distribution and also available online as
% http://sbml.org/software/libsbml/license.html
%----------------------------------------------------------------------- -->

% assume not enabled
enabled = 0;

supported = {'fbc', 'qual', 'groups'};
if ~ischar(package)
    disp('argument must be a string representing an SBML L3 package');
elseif ~ismember(supported, package)
    return;
end;

if (isoctave() == '0')
  filename = fullfile(tempdir, 'pkg.xml');
else
  filename = fullfile(pwd, 'pkg.xml');
end;
writeTempFile(filename, package);

version_field = strcat(package, '_version');
try
  [m, e] = TranslateSBML(filename, 1, 0);

  if (isempty(e) && isfield(m, version_field) == 1 )
    enabled = 1;
  end;
  
  delete(filename);
  
catch err
  disp(err.identifier)
  delete(filename);
  
  return
end;




function writeTempFile(filename, package)

fout = fopen(filename, 'w');

fprintf(fout, '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n');
fprintf(fout, '<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" ');
fprintf(fout, strcat('xmlns:', package, '=\"http://www.sbml.org/sbml/level3/version1/', package, '/version1\"\n'));
fprintf(fout, 'level=\"3\" version=\"1\"\n');
fprintf(fout, strcat(package, ':required=\"false\">\n'));
fprintf(fout, '  <model/>\n</sbml>\n');

fclose(fout);

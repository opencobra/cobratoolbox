function fail = testOutput(outdir, in_installer, fbcEnabled)

%  Filename    :   TestOutput.m
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

if (~isdir(outdir))
mkdir (outdir);
end;

if exist('OCTAVE_VERSION')
  ff = dir('test-data');
  j = 1;
  for i=1:length(ff)
    if (ff(i).isdir == 0 && ~isempty(strfind(ff(i).name, '.xml')))
      files(j) = ff(i);
      j = j+1;
    end;
  end;
else
  files = dir(['test-data', filesep, '*.xml']);
end;

disp('Testing output model');

fail = 0;
test = 0;

for i=1:length(files)
  if isFileExpected(files(i).name) == 0
    %donothing
  %skip models that will cause read errors
  elseif (strcmp(files(i).name, 'readerror.xml'))
    % donothing
  elseif (strcmp(files(i).name, 'fatal.xml'))
    %do nothing
  elseif (fbcEnabled == 0 && strcmp(files(i).name, 'fbc.xml'))
    % do nothing
  else
    model = [];
    model = TranslateSBML(['test-data', filesep, files(i).name]);
    if (~isempty(model))
      if (in_installer == 1)
        OutputSBML(model, [outdir, filesep, files(i).name], in_installer);
      else
        OutputSBML(model, [outdir, filesep, files(i).name]);
      end;
      test = test + 1;
      if (compareFiles(['test-data', filesep, files(i).name], [outdir, filesep, files(i).name]))
        disp(sprintf('Output of %s failed', files(i).name));
        fail = fail + 1;
      end;
    end;
  end;
end;

disp ('************************************');
disp('Overall tests:');
disp(sprintf('Number tests: %d', test));
disp(sprintf('Number fails: %d', fail));
disp(sprintf('Pass rate: %d%%\n', ((test-fail)/test)*100));


disp('Testing invalid model structures');
test = 0;
invalidFail = 0;

test = test + 2;
m = [];
[v, mess] = isSBML_Model(m);

expected = sprintf('Invalid Model structure\n%s\n', '');
if v ~= 0 || ~strcmp(mess, expected)
  invalidFail = invalidFail + 1;
  disp('empty [] failed');
end;

try
  OutputSBML(m, [outdir, filesep, 'temp.xml']);
  invalidFail = invalidFail + 1;
  disp('empty [] write failed');
catch
end;

test = test + 2;
m = struct();
[v, mess] = isSBML_Model(m);

expected = sprintf('missing typecode field');
if v ~= 0 || ~strcmp(mess, expected)
  invalidFail = invalidFail + 1;
  disp('empty structure failed');
end;

try
  OutputSBML(m, [outdir, filesep, 'temp.xml']);
  invalidFail = invalidFail + 1;
  disp('empty structure write failed');
catch
end;

disp ('************************************');
disp('Overall tests:');
disp(sprintf('Number tests: %d', test));
disp(sprintf('Number fails: %d', invalidFail));
disp(sprintf('Pass rate: %d%%\n', ((test-invalidFail)/test)*100));

fail = fail + invalidFail;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unexpected files cause problems

function isExpected = isFileExpected(filename)

expected_files = { ...
'algebraicRules.xml', ...
'both.xml', ...
'convertedFormulas.xml', ...
'convertedFormulasL2.xml', ...
'csymbolAvogadro.xml', ...
'csymbolDelay.xml', ...
'csymbolTime-reaction-l2.xml', ...
'csymbolTime.xml', ...
'errors.xml', ...
'fatal.xml', ...
'fbc.xml', ...
'funcDefsWithInitialAssignments.xml', ...
'functionDefinition.xml', ...
'initialAssignments.xml', ...
'l1v1-branch.xml', ...
'l1v1-minimal.xml', ...
'l1v1-rules.xml', ...
'l1v1-units.xml', ...
'l1v1.xml', ...
'l1v2-all.xml', ...
'l2v1-all.xml', ...
'l2v1-allelements.xml', ...
'l2v1-assignment.xml', ...
'l2v2-all.xml', ...
'l2v2-newComponents.xml', ...
'l2v2-newelements.xml', ...
'l2v3-all.xml', ...
'l2v3-newelements.xml', ...
'l2v3-newMath.xml', ...
'l2v4-all.xml', ...
'l3v1core.xml', ...
'nestedPiecewise.xml', ...
'none.xml', ...
'notes_annotations.xml', ...
'piecewise.xml', ...
'rateRules.xml', ...
'readerror.xml' ...
};

if sum(ismember(expected_files, filename)) == 1
  isExpected = 1;
else
  isExpected = 0;
end;

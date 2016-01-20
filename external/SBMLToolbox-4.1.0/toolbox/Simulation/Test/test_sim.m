function y = test_sim()

%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2012 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EBML-EBI), Hinxton, UK
%
% Copyright (C) 2006-2008 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. University of Hertfordshire, Hatfield, UK
%
% Copyright (C) 2003-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA 
%     2. Japan Science and Technology Agency, Japan
%     3. University of Hertfordshire, Hatfield, UK
%
% SBMLToolbox is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution.
%----------------------------------------------------------------------- -->





test = 0;
Totalfail = 0;

if isBindingInstalled() == 1
  test = test + 6;
  fail = TestAnalyseSpecies;
  if (fail > 0)
      disp('AnalyseSpecies failed');
  end;
  Totalfail = Totalfail + fail;

  test = test + 4;
  fail = TestDealWithPiecewise;
  if (fail > 0)
      disp('DealWithPiecewise failed');
  end;
  Totalfail = Totalfail + fail;

  test = test + 3;
  fail = TestGetArgumentsFromLambdaFunction;
  if (fail > 0)
      disp('GetArgumentsFromLambdaFunction failed');
  end;
  Totalfail = Totalfail + fail;

  test = test + 1;
  fail = TestAnalyseVaryingParameters;
  if (fail > 0)
      disp('AnalyseSVaryingParameters failed');
  end;
  Totalfail = Totalfail + fail;

  test = test + 1;
  fail = test_fbc_sim;
  if (fail > 0)
      disp('test_fbc_sim failed');
  end;
  Totalfail = Totalfail + fail;

  disp(sprintf('Number tests: %d', test));
  disp(sprintf('Number fails: %d', Totalfail));
  disp(sprintf('Pass rate: %d%%', ((test-Totalfail)/test)*100));
else
  disp('LibSBML binding not installed - no tests could be run');
end;

y = Totalfail;

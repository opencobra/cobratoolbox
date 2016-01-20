function fail = TestGetAllParameters

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










m = TranslateSBML('../../Test/test-data/algebraicRules.xml');

names = {'k', 's1', 's2', 'k'};
values = [1, 3, 4, 0.1];

fail = TestFunction('GetAllParameters', 1, 2, m, names, values);

m = TranslateSBML('../../Test/test-data/initialAssignments.xml');

names = {'k', 'k1', 's1', 's2', 's3', 'c', 'c1', 'k'};
values = [6, 2, 3, 4, 1, 6, 2, 0.1];

fail = fail + TestFunction('GetAllParameters', 1, 2, m, names, values);

m = TranslateSBML('../../Test/test-data/l3v1core.xml');

names = {'p', 'p1', 'p2', 'p3', 'x', 'd', 'k'};
values = [2, 4, 4, 2, 2, NaN, 9];

fail = fail + TestFunction('GetAllParameters', 1, 2, m, names, values);


function fail = TestIsSBML_Event

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



pr_l3v1 = struct('typecode', {'SBML_PRIORITY'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},...
  'sboTerm', {''}, 'math', {''});

t_l2v3 = struct('typecode', {'SBML_TRIGGER'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},...
  'sboTerm', {''}, 'math', {''});

t_l3v1 = struct('typecode', {'SBML_TRIGGER'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},...
  'sboTerm', {''}, 'persistent', {''}, 'initialValue', {''}, 'math', {''});

del_l2v3 = struct('typecode', {'SBML_DELAY'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},...
  'sboTerm', {''}, 'math', {''});

ea_l2 = struct('typecode', {'SBML_EVENT_ASSIGNMENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'variable', {''}, ...
    'math', {''});

ea_l2v2 = struct('typecode', {'SBML_EVENT_ASSIGNMENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'variable', {''}, ...
    'sboTerm', {''}, 'math', {''});

e_l2 = struct('typecode', {'SBML_EVENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'name', {''}, 'id', {''}, ...
    'trigger', {''}, 'delay', {''}, 'timeUnits', {''}, 'eventAssignment', ea_l2);

e_l2v2 = struct('typecode', {'SBML_EVENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'name', {''}, 'id', {''}, ...
    'trigger', {''}, 'delay', {''}, 'timeUnits', {''}, 'sboTerm', {''}, 'eventAssignment', ea_l2v2);

e_l2v3 = struct('typecode', {'SBML_EVENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'name', {''}, 'id', {''}, ...
    'trigger',t_l2v3, 'delay', del_l2v3,  'sboTerm', {''}, 'eventAssignment', ea_l2v2);

e_l2v4 = struct('typecode', {'SBML_EVENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'name', {''}, 'id', {''}, ...
    'useValuesFromTriggerTime', {''}, 'trigger', t_l2v3, 'delay', del_l2v3,  'sboTerm', {''}, 'eventAssignment', ea_l2v2);

e_l3v1 = struct('typecode', {'SBML_EVENT'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'name', {''}, 'id', {''}, ...
    'useValuesFromTriggerTime', {''}, 'trigger', t_l3v1, 'delay', del_l2v3,  'priority',pr_l3v1, 'sboTerm', {''}, 'eventAssignment', ea_l2v2);

fail = TestFunction('isSBML_Event', 2, 1, e_l2, 1, 0);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2, 1, 1, 0);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2, 1, 2, 0);
fail = fail + TestFunction('isSBML_Event', 2, 1, e_l2, 2, 1);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2, 2, 1, 1);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2v3, 2, 3, 1);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2v4, 2, 3, 1);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2v4, 2, 2, 0);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2v4, 2, 4, 1);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l2v4, 3, 1, 0);
fail = fail + TestFunction('isSBML_Event', 3, 1, e_l3v1, 3, 1, 1);
fail = fail + TestFunction('isValid', 1, 1, e_l2, 1);
fail = fail + TestFunction('isValid', 1, 1, e_l2v3, 1);
fail = fail + TestFunction('isValid', 1, 1, e_l2v4, 1);
fail = fail + TestFunction('isValid', 1, 1, e_l3v1, 1);












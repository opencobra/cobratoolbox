function y = LoseWhiteSpace(charArray)
% newArray = LoseWhiteSpace(charArray)
% 
% Takes
% 
% 1. charArray, an array of characters 
% 
% Returns 
% 
% 1. the array with any white space removed
% 
% *EXAMPLE:*
%
%          newArray = LoseWhiteSpace('     exa  mp le')
%
%          newArray = 'example'
%


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


%------------------------------------------------------------
% check input is an array of characters
if (~ischar(charArray))
    error('LoseWhiteSpace(input)\n%s', 'input must be an array of characters');
end;

%-------------------------------------------------------------
% get the length of the array
NoChars = length(charArray);

%-------------------------------------------------------------
% create an array that indicates whether the elements of charArray are
% spaces
% e.g. WSpace = isspace('  v b') = [1, 1, 0, 1, 0]
% and determine how many

WSpace = isspace(charArray);
NoSpaces = sum(WSpace);

%-----------------------------------------------------------
% rewrite the array to leaving out any spaces
% remove any numbers from the array of symbols
if (NoSpaces > 0)
    NewArrayCount = 1;
    for i = 1:NoChars
        if (~isspace(charArray(i)))
            y(NewArrayCount) = charArray(i);
            NewArrayCount = NewArrayCount + 1;
        end;
    end;    
else
    y = charArray;
end;


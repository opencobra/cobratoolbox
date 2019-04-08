function p = printHyperlink(command, linkWord, wordLength, printFlag)
% Print a string hyperlinked to running a Matlab command when displayed in
% the Matlab command window. Called by `surfNet.m`
%
% USAGE:
%    p = printHyperlink(command, linkWord, wordLength, printFlag)
%
% INPUTS:
%    command:          A string containing a matlab command (e.g., fprintf('abc\n'))
%    linkWord:         the text that is being printed and hyperlinked
%
% OPTIONAL INPUTS:
%    wordLength:       the length of the formatted string (default 0, the length of `linkWord`) 
%    printFlag:        true to print and return the string, false to return the string only
%
% OUTPUT:
%    p:                the hyperlinked string

if nargin < 3 || isempty(wordLength)
    wordLength = 0;
end
if nargin < 4
    printFlag = true;
end
linkWord = sprintf(['%' num2str(wordLength) 's'], linkWord);
p = ['<a href="matlab: ' command '">' linkWord '</a>'];
%p = sprintf(sPrint, linkWord);
if printFlag
    fprintf(p);
end
end
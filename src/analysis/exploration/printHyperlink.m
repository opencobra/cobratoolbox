function p = printHyperlink(command, linkWord, wordLength, printFlag)
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
% Example script showcasing the functionality of slocstat
%
% @author B. Schauerte
% @date   2012

%%
% You can call it on a filename
call = 'slocstat.m';
[sloc,stat] = slocstat(call);
fprintf('Total number of lines %d for ''%s''\n',sloc,call);

%%
% You can call it on a function name
call = 'slocstat';
[sloc,stat] = slocstat(call);
fprintf('Total number of lines %d for ''%s''\n',sloc,call);

% ... and of course of any (non-builtin) function in Matlab's search path, 
% e.g., "dct"
call = 'dct';
[sloc,stat] = slocstat(call);
fprintf('Total number of lines %d for ''%s''\n',sloc,call);

%%
% You can call it on a folder name and then it also makes sense to use
% printslocstat
call = '.';
[sloc,stat] = slocstat(call);
fprintf('Total number of lines %d for ''%s''\n',sloc,call);
printslocstat(stat);

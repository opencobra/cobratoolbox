tmp=which('initCobraToolbox');
folder=strrep(tmp,'initCobraToolbox.m','src/');
[sloc,stat] = slocstat(folder);
fprintf('Total number of lines %d for ''%s''\n',sloc,folder);
printslocstat(stat);

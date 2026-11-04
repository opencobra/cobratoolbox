% D6: which returns empty for a file that is not on the path.
w = which('noSuchFileForRunMatD6.m');
fprintf('%d\n', isempty(w));

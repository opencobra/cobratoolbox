% D10: prefdir and exit exist; prefdir returns text.
p = prefdir();
fprintf('%d\n', ischar(p));
fprintf('%d\n', exist('exit') > 0);

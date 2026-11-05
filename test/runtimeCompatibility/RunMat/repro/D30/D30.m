% D30: a method call that expands a cell into its arguments, obj.m(c{:}). Under RunMat v0.6.2 one in any
% file of the script's folder stops the script before its first statement.
fprintf('start\n');
fprintf('%d\n', runmatReproMethodExpand({1}));

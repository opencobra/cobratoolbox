% Build the C/C++ files provided in the package
%
% @author: B. Schauerte
% @date:   2009
% @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/
 
cpp_files=dir('*.cpp');
for i=1:length(cpp_files)
  fprintf('Building %d of %d: %s\n',i,length(cpp_files),cpp_files(i).name);
  mex(cpp_files(i).name);
end
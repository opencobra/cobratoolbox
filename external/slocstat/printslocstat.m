function printslocstat(stat,fid)
  % PRINTSLOCSTAT print the result of slocstat.
  %
  % @author B. Schauerte
  % @date   2012
  % @www    http://cvhci.anthropomatik.kit.edu/~bschauer/
  
  % Copyright 2012 B. Schauerte. All rights reserved.
  % 
  % Redistribution and use in source and binary forms, with or without 
  % modification, are permitted provided that the following conditions are 
  % met:
  % 
  %    1. Redistributions of source code must retain the above copyright 
  %       notice, this list of conditions and the following disclaimer.
  % 
  %    2. Redistributions in binary form must reproduce the above copyright 
  %       notice, this list of conditions and the following disclaimer in 
  %       the documentation and/or other materials provided with the 
  %       distribution.
  % 
  % THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR 
  % IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
  % WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  % DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE 
  % FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
  % CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
  % SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
  % BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  % WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  % OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  % ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  % 
  % The views and conclusions contained in the software and documentation
  % are those of the authors and should not be interpreted as representing 
  % official policies, either expressed or implied, of B. Schauerte.

  %%
  % default: print to stdout
  if nargin < 2
    fid = 1;
  end
  
  %%
  % show a sorted view of the files
  slocs = [stat.sloc];
  [s_slocs,I] = sort(slocs);
  s_stat = stat(I);
  total_n_lines = 0;
  for i=1:numel(s_slocs)
    if s_slocs(i) == 0, continue; end % skip empty files
    total_n_lines = total_n_lines + s_stat(i).info.n_lines;
    %fprintf(fid,'%8d\t%s (%s, %d = %.2f%%)\n',s_slocs(i),s_stat(i).name,s_stat(i).info.ctype,s_stat(i).info.n_lines,s_slocs(i) / s_stat(i).info.n_lines * 100);
    fprintf(fid,'%8d\t%s (%d)\n',s_slocs(i),s_stat(i).name,s_stat(i).info.n_lines);
  end
  fprintf('--------\n%8d\tTotal (%d)\n',sum(slocs),total_n_lines);
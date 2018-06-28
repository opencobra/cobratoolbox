function [sloc,stat] = slocstat(what,slocfunc,sloc,stat)
  % SLOCSTAT calculates the source lines of code of the input Matlab
  %   program/function/file.
  %
  % what: Can be the name of a file, a function/skript, or a folder. If
  %       what identifies a folder, then recursion is used to calculate the
  %       sloc for all files in the folder and its sub-folders.
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
  
  % No input? Display help.
  if nargin < 1
    help(mfilename);
    return;
  end
  
  % Here, you can speficy/set different SLOC implementations
  if nargin < 2
    % You can use this to, e.g., use the SLOC implementation by Raymond S.
    % Norris in place of the provided calcsloc (be aware that this
    % implementation might not allow to use the full functionality of
    % slocstat)
    %
    % You can also allow other code types, if you set the right function 
    % here (e.g., SLOC for C/C++-code or whatever you like).
    %slocfunc = @oldsloc;%
    slocfunc = @calcsloc;
  end
  
  % this is for recursion
  if nargin < 3
    sloc = 0;
  end
  
  % this is for recursion
  if nargin < 4
    stat = [];
  end
  
  ftype = exist(what);
  switch(ftype)
    case 0 % does not exist
      error('Matlab file or function does not exist (%s)',what);
      
    case 2 % file
      % This is a bit more complicated, since we allow function paths as
      % well as function names. If we just get a function name, then
      % appending the .m does not hurt, otherwise if we get a filename,
      % then we won't be able to find the file.
      fname = which(sprintf('%s%s',what,'.m'));
      if isempty(fname)
        fname = what;
      end
      
      %fsloc = slocfunc(fname); % sloc statistics for the file
      [fsloc,finfo] = slocfunc(fname); % sloc statistics for the file
      
      % set the output
      sloc = sloc + fsloc;
      tstat.type = 'sloc';
      tstat.name = fname;
      tstat.sloc = fsloc;
      tstat.info = finfo;
      stat = [stat; tstat];
      
    case 7 % directory
      % let's calculate it recursively
      files = dir(what);
      for i=1:length(files)
        if strcmp(files(i).name,'..') || strcmp(files(i).name,'.')
          continue;
        end
        
        if files(i).isdir
          tname = fullfile(what,files(i).name,'');
        else
          tname = fullfile(what,files(i).name);
        end
        
        [sloc,stat] = slocstat(tname,slocfunc,sloc,stat);
      end
      
    otherwise
      error('Unsupported input file type (%s)',what);
  end
end
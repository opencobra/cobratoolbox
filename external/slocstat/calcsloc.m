function [sloc,info] = calcsloc(filename,verbose)
  % CALCSLOC calculates the source lines of code of a file.
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
  
  sloc = 0;
  info = [];
  
  if nargin < 1
    help(mfilename);
    return;
  end
  
  if nargin < 2, verbose = false; end
  
  [~,~,fext] = fileparts(filename);
  
  % check whether or not it is a file-type we support
  if ~strcmp(fext,'.m')
    if verbose
      warning('File extension .%s (%s) not supported by %s',fext,filename,mfilename);
    end
    return
  else
    ctype = 'Matlab';
  end
  
  % open the file
  fid = fopen(filename,'r');
  if fid < 0
    error('Could not open %s',filename)
  end
  
  % process the file, line by line
  n_comment = 0;
  n_empty = 0;
  n_function = 0;
  n_lines = 0;
  n_continued = 0;
  pline = ''; % previous line
  while true
    % get the next line
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    % trim the line, i.e. remove unnecessary white spaces
    tline = strtrim(tline);
    
    % basic, single-line identifiers
    is_function = strncmp('function',tline,8);
    is_empty = isempty(tline);
    is_comment = strncmp('%',tline,1);
    
    % require history
    is_continued = (length(pline) > 2 && strcmp(pline(end-2:end),'...') && ~strncmp(pline,'%',1));
    
    if ~is_empty && ~is_comment && ~is_continued % && ~is_function
      sloc = sloc + 1;
    end
    
    % calculate some statistics
    n_lines = n_lines + 1;
    n_comment = n_comment + is_comment;
    n_empty = n_empty + is_empty;
    n_function = n_function + is_function;
    n_continued = n_continued + is_continued;
  end
  
  fclose(fid); % close the file descriptor
  
  % set some output information
  info.ctype = ctype;              % code type
  info.n_comment = n_comment;      % number of comment lines
  info.n_empty = n_empty;          % number of empty lines
  info.n_function = n_function;    % number of function definition lines
  info.n_continued = n_continued;  % number of continued lines
  info.n_lines = n_lines;          % total number of lines
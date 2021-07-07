% GREP EXAMPLES
%
% - note only selected output is shown for the sake of brevity
% - note clicking on any underlined text
%	file name
%	line number
%   will open the file at the matching line


% create a line separator
	sep=@(x) disp(sprintf(repmat('-',1,75)));


% assume GREP.TXT is in your current working folder
	fnam='grep.txt';
% - show contents (note all spaces are TABs!)
	type(fnam);

% simple case insensitive [-i] string search in GREP.M for instances of
%		Version
% listing file name [def] and the line number [-n] of occurrences
%-------------------------------------------------------------------------------
	grep -i -n Version grep.m
	sep();

% regular expression search [-R] in GREP.M for instances of
%		=true or =false
% listing line number [-n] but not the file name [-Q]
%-------------------------------------------------------------------------------
	grep -Q -n -R =true|=false grep.m
	sep();

% simple string search in GREP.M for exactly matching [-x] instances of
%		\t\tmsg=true;
% listing the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	TAB=sprintf('\t');
	fl=grep('-x -n',[TAB,TAB,'msg=true;'],'grep.m');
	sep();

% simple string search in GREP.TXT for
%		every line of itself in turn
% using the pattern-file [-f] option and
% listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] for each occurrence
%-------------------------------------------------------------------------------
	fl=grep('-l -f',fnam,fnam);
	sep();

% simple string search in GREP.TXT for instances of
%		-n
% using the [-e] option since -n itself is an option flag (listing line number!)
% and listing the file name [def] for each non-matching line [-v] only
% - compare with previous example!
%-------------------------------------------------------------------------------
	fl=grep('-v -e',{'-n'},fnam);
	sep();

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
% listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	fpat=[matlabroot,'/toolbox/matlab/elfun'];
	fl=grep('-r -l -n',{'sign','cosine','atan'},fpat);
	sep();

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
% using the two versions of the [-e] option and
% listing the full file name and pattern for each file with matches [-l]
% as well as the count [-c] of all instances
%-------------------------------------------------------------------------------
	fl=grep('-r -l -c -e sign -e',{'cosine','atan'},fpat);
	sep();

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
%	only including files with a regular expression pattern [-If]
%		[Cc]ont
% using the two versions of the [-e] option and
% listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	fl=grep('-r -l -n -If [Cc]ont -e sign -e',{'cosine','atan'},fpat);
	sep();

% full depth search [-r] of the entire ELFUN TOOLBOX for instances of
%		sign or cosine or atan
%	only including files with a regular expression pattern [-If]
%		[Cc]ont
%	and excluding folders with a pattern [-Xd]
%		/ja
% - using the two versions of the [-e] option,
% and listing the full file name and pattern for each file with matches [-l]
% as well as the file name [def] and the line number [-n] for each occurrence
%-------------------------------------------------------------------------------
	fl=grep('-r -l -n -If [Cc]ont -e sign -e',{'cosine','atan'},'-Xd','/ja',fpat);
	sep();

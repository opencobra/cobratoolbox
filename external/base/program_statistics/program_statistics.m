function varargout = program_statistics(direct, varargin)
% PROGRAM_STATISTICS compiles some statistics about a program.
% A report is printed; statistics can be returned in structure.
%
%    program_statistics(direct)
%    stats = program_statistics(direct);
%    stats = program_statistics(direct, options);
%
%   direct: directory where the program resides
%   options: a structure with the following optional fields:
%       .recursive = 0|1    take also into account subfolders recursively
%       .complete = 0|1     compile extended set of statistics (see below)
%       .include            cell array of text files types (.xxx) to
%                           include in the statistics (e.g. {'.txt'; '.c'}
%
%   stats contains the following fields:
%       .files      number of m files
%       .lines      number of lines
%       .words      number of words
%       .chars      number of characters
%       .pages      number of pages to print the whole program based on:
%                       A4, landscape layout, default matlab impression
%                       fonts, margins, etc...
%   "complete statistics" option add the following fields:
%       .functions  number of functions
%       .space      number of space/tab/newline characters
%       .emptline   number of empty lines
%       .sigchar    number of non space/tab/newline characters
%       .comments   number of comments line (beginning with %)
%       .comchar    number of comment characters
%       .codelines  number of lines of code (comment lines are ignored)
%       .GUIDE      number of GUI files made with GUIDE
%       .GUIDEf     number of "GUIDE" functions
%       .GUIDEb     number of bytes of the GUIDE-related .fig files
%
% note: stats = program_statistics(direct, options, 0) does not print a
%       report.
%
% Programmed by CSE - L.Cavin, 2004, version 1.0
% Use freely for any non-comercial purposes.
%
% EXAMPLE OF REPORT:
% %  
% % Number of folders parsed: 44
% % Number of code folders:   8 (22.125 files per folder)
% %  
% % Number of files:          177
% %     - including 588 functions (3.322 functions per file),
% %     - including 25 GUI dialog callback files made with GUIDE,
% %          (linked with .fig files weighting 657.3438 Kb)
% %     - including 335 GUIDE-related functions,
% %     - including 253 other functions (1.6645 functions per file).
% %  
% % Number of lines:          40600
% %     - distributed in 172234 words,
% %     - including 2774 (6.8325%) separation lines,
% %     - including 8606 (21.197%) lines of comments,
% %     - including 29220 (71.9704%) lines of code.
% %  
% % Number of characters:     1549343
% %     - including 407452 (26.2984%) comment characters,
% %     - including 1141891 (73.7016%) code characters.
% %  
% % To print the whole program, 1014 A4-pages would be necessary.

cur_dr = pwd;
% setup options
if nargin > 1
    options = varargin{1};
else
    options = [];
end
if ~isfield(options, 'recursive')
    options.recursive = 0;
end
if ~isfield(options, 'complete')
    options.complete = 0;
end
if ~isfield(options, 'include')
    options.include = [];
end
% initialize stats
stats.files = 0;
stats.lines = 0;
stats.words = 0;
stats.chars = 0;
stats.pages = 0;
if options.recursive
	stats.folders = 0;
	stats.projfold = 0;
end
if options.complete
    stats.emptline = 0;
    stats.functions = 0;
    stats.GUIDE = 0;
    stats.GUIDEf = 0;
    stats.GUIDEb = 0;
    stats.sigchar = 0;
    stats.space = 0;
    stats.comments = 0;
    stats.comchar = 0;
    stats.codelines = 0;
end

cd(direct);

% begin with recursivity loop is required:
if options.recursive
    subdir = dir;
    for i = 1:length(subdir)
        if subdir(i).isdir & ~prod(double('.' == subdir(i).name))
            stats.folders = stats.folders + 1;
            stats.projfold = stats.projfold + 1;
            stt = program_statistics([direct filesep subdir(i).name], options, 0);
            if stt.files == 0
                stats.projfold = stats.projfold - 1;
            end
            stats = add_stats(stats, stt);
        end
    end
end

fles = dir('*.m');
if ~isempty(options.include)
    for i = 1:length(options.include)
        tmp = dir(['*' options.include{i}]);
        fles = [fles; tmp];
    end
end

stats.files = stats.files + length(fles);

cmt = 0;
spc = 0;
for i = 1:length(fles)
    pge = 0;
    fle = textread(fles(i).name, '%s');
    stats.words = stats.words + length(fle);
    fle = textread(fles(i).name,'%s','delimiter','\n','whitespace','');
    stats.lines = stats.lines + length(fle);
    cmt = cmt + length(fle);
    spc = spc + length(fle);
    chr = 0;
    for j = 1:length(fle)
        tmp = length(fle{j});
        stats.chars = stats.chars + tmp;
        spc = spc + tmp;
        pge = pge + ceil(tmp/119);
        chr = chr + tmp;
    end
    stats.pages = stats.pages + ceil(pge/42);
    if options.complete
        fid = fopen(fles(i).name);
        tmp = length(fscanf(fid, '%s'));
        stats.sigchar = stats.sigchar + tmp;
        spc = spc - tmp;
        fclose(fid);
        fle = textread(fles(i).name,'%s','delimiter','\n','whitespace','', 'commentstyle', 'matlab');
        stats.codelines = stats.codelines + length(fle);
        cmt = cmt - length(fle);
        fcn = 0;
        gde = 0;
        for j = 1:length(fle)
            if length(fle{j}) == 0
                stats.emptline = stats.emptline + 1;
            else
                if ~isempty(findstr(fle{j}, 'function'))
                    if (fle{j}(1) == 'f') & (fle{j}(2) == 'u')
                        stats.functions = stats.functions + 1;
                        if ~isempty(findstr(fle{j} , '(hObject, eventdata, handles)'))
                            fcn = fcn + 1;
                        end
                    end
                end
                chr = chr - length(fle{j});
                if ~isempty(findstr(fle{j}, 'gui_Singleton = 1;'))
                    stats.GUIDE = stats.GUIDE + 1;
                    gde = 1;
                    tmp = dir([fles(i).name(1:end-1) 'fig']);
                    if ~isempty(tmp)
                        stats.GUIDEb = stats.GUIDEb + tmp.bytes;
                    end
                end
            end
        end
        if gde
            stats.GUIDEf = stats.GUIDEf + fcn + 1;
        end
        stats.comchar = stats.comchar + chr;
    end
end
if options.complete
    stats.comments = stats.comments + cmt;    
    stats.space = stats.space + spc;
end

cd(cur_dr);

if nargin < 3
    % print report:
    disp(' ');
    disp('PROGRAM STATISTICS:');
    disp('~~~~~~~~~~~~~~~~~~~');
    disp(' ');
    if options.recursive
		stats.folders = stats.folders + 1;
		stats.projfold = stats.projfold + 1;
        disp(['Number of folders parsed: ' int2str(stats.folders)]);
        disp(['Number of code folders:   ' int2str(stats.projfold) ' (' num2str(stats.files/stats.projfold) ' files per folder)']);
        disp(' ');
    end
    disp(['Number of files:          ' int2str(stats.files)]);
    if options.complete
        disp(['    - including ' int2str(stats.functions) ' functions (' num2str(stats.functions/stats.files) ' functions per file),']);
        disp(['    - including ' int2str(stats.GUIDE) ' GUI dialog callback files made with GUIDE,']);
        disp(['         (linked with .fig files weighting ' num2str(stats.GUIDEb/1024) ' Kb)']);
        disp(['    - including ' int2str(stats.GUIDEf) ' GUIDE-related functions,']);
        disp(['    - including ' int2str(stats.functions-stats.GUIDEf) ' other functions (' num2str((stats.functions-stats.GUIDEf)/(stats.files-stats.GUIDE)) ' functions per file).']);
        disp(' ');
    end
    disp(['Number of lines:          ' int2str(stats.lines)]);
    if options.complete
        disp(['    - distributed in ' int2str(stats.words) ' words,']);
        disp(['    - including ' int2str(stats.emptline) ' (' num2str(stats.emptline/stats.lines*100) '%) separation lines,']);
        disp(['    - including ' int2str(stats.comments) ' (' num2str(stats.comments/stats.lines*100) '%) lines of comments,']);
        disp(['    - including ' int2str(stats.codelines-stats.emptline) ' (' num2str((stats.codelines-stats.emptline)/stats.lines*100) '%) lines of code.']);
        disp(' ');
    else
        disp(['Number of words:          ' int2str(stats.words)]);
    end
    disp(['Number of characters:     ' int2str(stats.chars)]);
    if options.complete
%         disp(['    - including ' int2str(stats.space) ' (' num2str(stats.space/stats.chars*100) '%) spaces, tabs, newlines,']);
%         disp(['    - including ' int2str(stats.sigchar) ' (' num2str(stats.sigchar/stats.chars*100) '%) other characters,']);
%         disp(['    - including ' int2str(stats.comchar) ' (' num2str(stats.comchar/stats.chars*100) '%) comment characters,']);
%         disp(['    - including ' int2str(stats.sigchar-stats.comchar) ' (' num2str((stats.sigchar-stats.comchar)/stats.chars*100) '%) code characters']);
        disp(['    - including ' int2str(stats.comchar) ' (' num2str(stats.comchar/stats.chars*100) '%) comment characters,']);
        disp(['    - including ' int2str(stats.chars-stats.comchar) ' (' num2str((stats.chars-stats.comchar)/stats.chars*100) '%) code characters.']);
    end
    disp(' ');
    disp(['To print the whole program, ' int2str(stats.pages) ' A4-pages would be necessary.']);
    disp(' ');
end

if nargout > 0
    varargout{1} = stats;
end

function stats = add_stats(stats, stt)

blp = fields(stats);
for i = 1:length(blp)
    eval(['stats.' blp{i} ' = stats.' blp{i}  ' + stt.' blp{i}  ';']);
end
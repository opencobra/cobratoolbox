function L = countcode(varargin);
% COUNTCODE - Counts the total number of code lines of all the M-files in a directory
%
% Syntax options:
%   COUNTCODE
%   COUNTCODE(dir_str)
%   L = COUNTCODE
%   L = COUNTCODE(dir_str)
%   
% By default the current directory is scanned, and the result is displayed
% in the command window. Supply the string dir_str for scanning a directory
% other than the current one. The result can be stored in cell-array L.
%
% Jasper M, November 2005

% Check for a directory request
ScanDir = cd;
if nargin
    if ischar(varargin{1}) && exist(varargin{1}, 'dir')
        ScanDir = varargin{1};
    else
        disp('Warning! Input is not a valid directory.');
    end
end

% See whether command window display is desired
ShowResult = true;
if nargout
    ShowResult = false;
end

Extension   = '.m';
FileList    = dir(ScanDir);
N_code_tot  = 0;
N_lines_tot = 0;

% Display header
if ShowResult
    disp(' ');
    disp('  Ncode   (Ntot)    File');
    disp('  ----------------------');
else
    L    = {};
    L{1} = 'Ncode   (Ntot)    File';
    L{2} = '----------------------';
end

% Scan the directory for script files
for i = 1:length(FileList)
    ScanFile = FileList(i).name;
    if exist(ScanFile, 'file') && numel(findstr([lower(ScanFile),'xxxx'], Extension))
        % File containing script code found!
        Contents = textread(ScanFile, '%s', 'delimiter', '\n', 'whitespace', '');
        % Count all the lines as well as all non-empty lines
        N_code  = sum(~cellfun('isempty', Contents));
        N_lines = length(Contents);

        % Update the totals
        N_code_tot  = N_code_tot  + N_code;
        N_lines_tot = N_lines_tot + N_lines;
        
        % Show the result for the current file
        T      = sprintf('%s%s', blanks(20), ScanFile);
        Tn1    = sprintf('  %d', N_code);
        Pn1    = [1:length(Tn1)];
        T(Pn1) = Tn1;
        Tn2    = sprintf('(%d)', length(Contents));
        Pn2    = 10 + [1:length(Tn2)];
        T(Pn2) = Tn2;
        if ShowResult
            disp(T);
        else
            L{end + 1} = T(3:end);
        end        
    end % of script file check
end % of file loop

% Show the final result
T      = [blanks(20), 'Lines typed so far!'];
Tn1    = sprintf('  %d', N_code_tot);
Pn1    = [1:length(Tn1)];
T(Pn1) = Tn1;
Tn2    = sprintf('(%d)', N_lines_tot);
Pn2    = 10 + [1:length(Tn2)];
T(Pn2) = Tn2;
if ShowResult
    disp('  ________________+');
    disp(T);
    disp(' ');
else
    L{end + 1} = '________________+';
    L{end + 1} = T(3:end);
end

% Finished!
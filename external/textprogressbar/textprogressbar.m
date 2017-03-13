function textprogressbar(c)
% This function creates a text progress bar. It should be called with a
% STRING argument to initialize and terminate. Otherwise the number correspoding
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate
%                       Percentage number to show progress
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

% Changes for The COBRAToolbox:
%
%      - renamed strCR to WAITBAR_HANDLE
%      - changed persistent type of strCR to global type

%% Initialization
global WAITBAR_HANDLE;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 40;   %   The total number of dots in a progress bar

%% Main

if isempty(WAITBAR_HANDLE) && ~ischar(c)
    % Progress bar must be initialized with a string
    error('The text progress must be initialized with a string');
elseif isempty(WAITBAR_HANDLE) && ischar(c)
    % Progress bar - initialization
    fprintf('%s',c);
    WAITBAR_HANDLE = -1;
elseif ~isempty(WAITBAR_HANDLE) && ischar(c)
    % Progress bar  - termination
    WAITBAR_HANDLE = [];
    fprintf([c '\n']);
elseif isnumeric(c)
    % Progress bar - normal progress
    c = floor(c);
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];

    % Print it on the screen
    if WAITBAR_HANDLE == -1
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([WAITBAR_HANDLE strOut]);
    end

    % Update carriage return
    WAITBAR_HANDLE = repmat('\b',1,length(strOut)-1);

    if c == 100
        fprintf('\n');
    end
else
    % Any other unexpected input
    error('Unsupported argument type');
end

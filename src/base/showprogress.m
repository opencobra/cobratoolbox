function fout = showprogress(x, whichbar)
% showprogress shows waitbars
%
% INPUTS:
%   x:         percentage in integer (e.g.: 1 = 1%, 40 = 40%, etc.)
%   whichbar:  caption
%   varagin:   see waitbar header for explanation
%
% OUTPUT:
%   fout: handle output from waitbar() (WAITBAR_TYPE = 1)
%
% .. Author:
%        - Lemmer El Assal (Feb 2017)
%        - CI adaptations: Laurent Heirendt (March 2017)

    global WAITBAR_TYPE;
    global WAITBAR_HANDLE;

    fout = [];

    if isempty(WAITBAR_TYPE)
        WAITBAR_TYPE = 0;
        if isempty(strfind(getenv('HOME'), 'jenkins'))
            WAITBAR_TYPE = 1;
        end
    end
    if isempty(WAITBAR_HANDLE)
        WAITBAR_HANDLE = -1;
    end

    switch WAITBAR_TYPE
        case 0 % silent mode

        case 1 % text
            if x > 0 && (length(WAITBAR_HANDLE) ~= 0)
                textprogressbar(x*100);
            else
                if nargin < 2
                    whichbar = '';
                end
                textprogressbar(whichbar);
            end

        case 2 % graphic waitbar
            if nargin > 1
                fout = waitbar(x*100, whichbar);
            else
                fout = waitbar(x);
            end
            if x == 1
                close(fout);
            end
    end
end

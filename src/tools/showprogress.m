function fout = showprogress(x, whichbar, varargin)
% showprogress shows waitbars
%
% Inputs:
%   x: percentage in integer (e.g.: 1 = 1%, 40 = 40%, etc.)
%   whichbar: caption
%   varagin: see waitbar header for explanation
%
% Output:
%   fout: handle output from waitbar() (WAITBAR_TYPE = 1)
%
% .. Author:
%        - Lemmer El Assal (Feb 2017)
%
    global WAITBAR_TYPE;
    fout = [];
    if ~isempty(WAITBAR_TYPE)
        switch WAITBAR_TYPE
            case 0 % silent mode

            case 1 % text
                if x > 0
                    textprogressbar(num2str(x*100));
                else
                    textprogressbar(whichbar);
                end

            case 2 % graphic waitbar
                if nargin > 2
                    fout = waitbar(x, whichbar, varargin);
                else
                    fout = waitbar(x, whichbar);
                end
        end
    end
end

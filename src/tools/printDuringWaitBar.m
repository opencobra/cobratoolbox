function printDuringWaitBar(StringToPrint)
% printDuringWaitBar prints output during waitbars.
%
% Inputs:
%   StringToPrint The String to print
%
% .. Author:
%        - Thomas Pfau (March 2017)

    global WAITBAR_TYPE;
    global WAITBAR_HANDLE;    

    if isempty(WAITBAR_TYPE)
        if ~isempty(strfind(getenv('HOME'), 'jenkins'))
            WAITBAR_TYPE = 0;
        else
            WAITBAR_TYPE = 1;
        end
    end
    if isempty(WAITBAR_HANDLE)
        fprintf(StringToPrint);
        return;
    end

    switch WAITBAR_TYPE
        case 0 % silent mode

        case 1 % text
            textprogressbar(true)
            %remove trailing carriage return
            StringToPrint = regexprep(StringToPrint,'[\r\n|\n|\r]$','');
            fprintf([StringToPrint '\n']);
            textprogressbar(false);            

        case 2 % graphic waitbar
                fprintf(StringToPrint);
        return;
    end
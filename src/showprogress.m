function fout = showprogress(x,whichbar, varargin)
    global WAITBAR_TYPE;
    fout = [];
    if ~isempty(WAITBAR_TYPE)
        switch WAITBAR_TYPE
            case 1 % graphic waitbar
                fout = waitbar(x,whichbar,varargin);
            %case 2 % text

        end
    end
end

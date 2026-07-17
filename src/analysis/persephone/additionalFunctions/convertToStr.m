function str = convertToStr(element)
% Convert a char array or a single-cell element to a char array
%
% USAGE:
%
%    str = convertToStr(element)
%
% INPUT:
%    element:    char array, or a cell whose contents are converted with cell2mat
%
% OUTPUT:
%    str:        char array representation of element
%
    if ischar(element)
        str = element;
    else
        str = cell2mat(element);
    end
end

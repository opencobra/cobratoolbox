function str = convertToStr(element)
    if ischar(element)
        str = element;
    else
        str = cell2mat(element);
    end
end

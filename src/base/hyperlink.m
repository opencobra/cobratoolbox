function outLink = hyperlink(url, urlText, altText1, altText2)
% converts a url to a clickable link in order to improve usability
% when using the MATLAB desktop environment
%
% USAGE:
%   outLink = hyperlink(url, urlText, altText1, altText2)
%
    if nargin < 2
        urlText = url;
    end
    if nargin < 3
        altText1 = '';
    end
    if nargin < 4
        altText2 = '';
    end

    outLink = [altText1, url, altText2];
    if usejava('desktop')
        outLink = ['<a href=\"', url, '\">', urlText, '</a>'];
    end
end

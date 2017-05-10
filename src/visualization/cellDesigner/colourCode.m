

% Convert 7 digits to 9 digits for CellDesigner to recongnise.

%a='a'


colourScheme={{'#f16359';'#f18d59';'#f9ea76';'#acf3be';'#117e9a'}; % Strawberry Orchard Color Palette
    {'#def595';'#cae45b';'#81c828';'#3dc800';'#279700'};  %Spring Growth Color Palette
    {'#ffedad';'#ffd599';'#ffc471';'#ffb93f';'#ffac37'}}  % Tangerine Color Palette

hexCode={};


for i=1:size(colourScheme,1);
    for m=1:size(colourScheme{1},1)
        if length(colourScheme{i}{m})<9;
            hexCode{i}{m}=[colourScheme{i}{m}(1),'ff',colourScheme{i}{m}(2:end)]
        end
    end
end

%hexcode{i}{m}





% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function closeGUI

selection = questdlg('Do you want to close the GUI?',...
    'Close Reguest Function',...
    'Yes','No','Yes');

switch selection,
    case 'Yes'
        delete(gcf)
    case 'No'
        return
end

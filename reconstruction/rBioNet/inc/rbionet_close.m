% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2012

function rbionet_close(hObject)
% rbionet_close(hObject)
% 
% Remove gui from rBioNet global variable registry and delete object if it
% is no longer in use.

global rbionetGlobal;
if ~isempty(rbionetGlobal)
    rbionetGlobal = rbionetGlobal.Unregister(hObject);
    if isempty(rbionetGlobal.GUIs)
        rbionetGlobal = [];
    end
end
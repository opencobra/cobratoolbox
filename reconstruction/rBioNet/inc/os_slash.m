% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

function slash = os_slash()
%Get forward or backwards slash depending on operating system.
if ispc %windows
    slash = '\';
else % unix, linux or mac
    slash = '/';
end



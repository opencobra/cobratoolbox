function [HMDBId_new] = convertOld2NewHMDB(HMDBId)
% This function converts the old style HMDB ids to the new style
% old style 'HMDB06525'
% new style 'HMDB0006525' -- 7 digits -- fill up old ID to new ID with 0
%
% INPUT
% HMDBId    HMDB id
% 
% OUTPUT
% HMDBId_new    new style HMDB id
%
% Ines Thiele 03/2022
HMDBId_new = '';
if length(HMDBId) < 12 % old style
    % remove HMDB part
    id = regexprep(HMDBId,'HMDB','');
    % add the missing 
    z = '';
    for i = 1 : (7-length(id))
        z =[z '0'];
    end
    HMDBId_new = ['HMDB' z id];
end
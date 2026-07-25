function [HMDBId_new] = convertOld2NewHMDB(HMDBId)
% Convert an old style HMDB id to the new style by zero padding the numeric
% part to 7 digits (old style 'HMDB06525', new style 'HMDB0006525'). Ids that
% are already in the new style are returned as an empty char.
%
% USAGE:
%
%    [HMDBId_new] = convertOld2NewHMDB(HMDBId)
%
% INPUT:
%    HMDBId:        old style HMDB id
%
% OUTPUT:
%    HMDBId_new:    new style HMDB id (7 digit numeric part)
%
% .. Author: - Ines Thiele 03/2022

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
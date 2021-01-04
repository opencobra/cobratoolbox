function [microbeID]=adaptDraftModelID(modelIDIn)
% This function adapts the name of the draft reconstruction entered into
% the pipeline into a suitable curated reconstruction ID.

% USAGE: [microbeID]=adaptKBaseModelID(modelIDIn);
%
% AUTHOR: Almut Heinken, 06/2020.

microbeID=modelIDIn;
microbeID=strrep(microbeID,'.fbamodel.sbml','');
microbeID=strrep(microbeID,'.model.sbml','');
microbeID=strrep(microbeID,'___RAST','');
microbeID=strrep(microbeID,'__.RAST','');
microbeID=strrep(microbeID,'_.RAST','');
microbeID=strrep(microbeID,'-.RAST','');
microbeID=strrep(microbeID,'..RAST','');
microbeID=strrep(microbeID,'.RAST','');
microbeID=strrep(microbeID,'_RAST','');
microbeID=strrep(microbeID,'.fna','');
microbeID=strrep(microbeID,'.fa','');
microbeID=strrep(microbeID,'_DraftModel','');
microbeID=strrep(microbeID,'.contigs','');
microbeID=strrep(microbeID,'__genome','');
microbeID=strrep(microbeID,'_genome','');
microbeID=strrep(microbeID,'_assembly','');
microbeID=strrep(microbeID,'.sbml','');
microbeID=strrep(microbeID,'.mat','');
microbeID=strrep(microbeID,' ','_');
microbeID=strrep(microbeID,'.','_');
microbeID=strrep(microbeID,'-','_');
microbeID=strrep(microbeID,'(','_');
microbeID=strrep(microbeID,')','_');
microbeID=strrep(microbeID,'\','_');
microbeID=strrep(microbeID,'/','_');
microbeID=strrep(microbeID,'+','_');
microbeID=strrep(microbeID,'©','_');
microbeID=strrep(microbeID,'____','_');
microbeID=strrep(microbeID,'___','_');
microbeID=strrep(microbeID,'__','_');
end

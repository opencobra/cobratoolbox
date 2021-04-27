function model = addRefinementComments(model,summary)
% Adds descriptions to the model.comments field based on refinement
% performed by the DEMETER pipeline
%
% USAGE:
%
%   model = addRefinementComments(model,summary)
%
% INPUT
% model:            COBRA model structure
% summary           Structure with description of performed refinement
%
% OUTPUT
% model:            COBRA model structure with comments
%
% .. Author:
%       - Almut Heinken and Stefania Magnusdottir, 2016-2020

%% remove the 'gap_filled' and 'exchange_reaction' label in genes
model.grRules=strrep(model.grRules,'exchange_reaction','');
%% remove other temporary labels
for i=1:length(model.grRules)
    if strcmp(model.grRules{i,1},'gap_filled')
        model.grRules{i,1}=strrep(model.grRules{i},'gap_filled','');
        model.comments{i,1}='Reaction added based in gap-filling during comparative genomic analyses.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'CarbonSourceGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'CarbonSourceGapfill','');
        model.comments{i,1}='Reaction added by DEMETER based on experimental data on carbon sources.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'FermentationGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'FermentationGapfill','');
        model.comments{i,1}='Reaction added by DEMETER based on experimental data on fermentation products.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'uptakeMetaboliteGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'uptakeMetaboliteGapfill','');
        model.comments{i,1}='Reaction added by DEMETER based on experimental data on consumed metabolites.';
    end
    if strcmp(model.grRules{i,1},'secretionProductGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'secretionProductGapfill','');
        model.comments{i,1}='Reaction added by DEMETER based on experimental data on secretion products.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i},'PutrefactionGapfill')
        model.grRules{i}=strrep(model.grRules{i},'PutrefactionGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on putrefaction pathways.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'AnaerobicGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'AnaerobicGapfill','');
        model.comments{i,1}='Reaction added by DEMETER to enable anaerobic growth.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'GrowthRequirementsGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'GrowthRequirementsGapfill','');
        model.comments{i,1}='Reaction added by DEMETER based on experimental data on growth requirements.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'demeterGapfill')
        model.grRules{i,1}=strrep(model.grRules{i},'demeterGapfill','');
        if ~isempty(find(strcmp(summary.('conditionSpecificGapfill'),model.rxns{i,1})))
            model.comments{i,1}='Added by DEMETER to enable flux with VMH-consistent constraints.';
        elseif ~isempty(find(strcmp(summary.('targetedGapfill'),model.rxns{i,1})))
            model.comments{i,1}='Added by DEMETER during targeted gapfilling to enable production of required metabolites.';
        elseif ~isempty(find(strcmp(summary.('relaxFBAGapfill'),model.rxns{i,1})))
            model.comments{i}='Added by DEMETER based on relaxFBA. Low confidence level.';
            model.rxnConfidenceScores(i,1)=1;
        end
    end
    if strcmp(model.grRules{i,1},'essentialGapfill')
        model.grRules{i,1}=strrep(model.grRules{i,1},'essentialGapfill','');
        model.comments{i,1}='Added by DEMETER, reactions that should always be present.';
        model.rxnConfidenceScores(i,1)=2;
    end
    if strcmp(model.grRules{i,1},'Unknown')
        model.grRules{i,1}=strrep(model.grRules{i},'Unknown','');
        model.comments{i,1}='Added by Model SEED/KBase gap-filling pipeline.';
        model.rxnConfidenceScores(i,1)=1;
    end
end

end

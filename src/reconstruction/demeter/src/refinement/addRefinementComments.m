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
    if strcmp(model.grRules{i},'gap_filled')
        model.grRules{i}=strrep(model.grRules{i},'gap_filled','');
        model.comments{i}='Reaction added based in gap-filling during comparative genomic analyses.';
    end
    if strcmp(model.grRules{i},'CarbonSourceGapfill')
        model.grRules{i}=strrep(model.grRules{i},'CarbonSourceGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on carbon sources.';
    end
    if strcmp(model.grRules{i},'FermentationGapfill')
        model.grRules{i}=strrep(model.grRules{i},'FermentationGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on fermentation products.';
    end
    if strcmp(model.grRules{i},'uptakeMetaboliteGapfill')
        model.grRules{i}=strrep(model.grRules{i},'uptakeMetaboliteGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on consumed metabolites.';
    end
    if strcmp(model.grRules{i},'secretionProductGapfill')
        model.grRules{i}=strrep(model.grRules{i},'secretionProductGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on secretion products.';
    end
    if strcmp(model.grRules{i},'PutrefactionGapfill')
        model.grRules{i}=strrep(model.grRules{i},'PutrefactionGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on putrefaction pathways.';
    end
    if strcmp(model.grRules{i},'AnaerobicGapfill')
        model.grRules{i}=strrep(model.grRules{i},'AnaerobicGapfill','');
        model.comments{i}='Reaction added by DEMETER to enable anaerobic growth.';
    end
    if strcmp(model.grRules{i},'GrowthRequirementsGapfill')
        model.grRules{i}=strrep(model.grRules{i},'GrowthRequirementsGapfill','');
        model.comments{i}='Reaction added by DEMETER based on experimental data on growth requirements.';
    end
    if strcmp(model.grRules{i},'demeterGapfill')
        model.grRules{i}=strrep(model.grRules{i},'demeterGapfill','');
        if ~isempty(find(strcmp(summary.('condGF'),model.rxns{i})))
            model.comments{i}='Added by DEMETER to enable flux with VMH-consistent constraints.';
        elseif ~isempty(find(strcmp(summary.('targetGF'),model.rxns{i})))
            model.comments{i}='Added by DEMETER during targeted gapfilling to enable production of required metabolites.';
        elseif ~isempty(find(strcmp(summary.('relaxGF'),model.rxns{i})))
            model.comments{i}='Added by DEMETER based on relaxFBA. Low confidence level.';
        end
    end
    if strcmp(model.grRules{i},'essentialGapfill')
        model.grRules{i}=strrep(model.grRules{i},'essentialGapfill','');
        model.comments{i}='Added by DEMETER, reactions that should always be present.';
    end
    if strcmp(model.grRules{i},'Unknown')
        model.grRules{i}=strrep(model.grRules{i},'Unknown','');
        model.comments{i}='Added by Model SEED/KBase gap-filling pipeline.';
    end
end

end

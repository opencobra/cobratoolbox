function model = addRefinementComments(model)
% Adds descriptions to the model.comments field based on refinement
% performed.

%% remove the 'gap_filled' and 'exchange_reaction' label in genes
model.grRules=strrep(model.grRules,'gap_filled','');
model.grRules=strrep(model.grRules,'exchange_reaction','');
%% remove other temporary labels
for i=1:length(model.grRules)
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
        model.comments{i}='Added by DEMETER to enable growth with VMH-consistent constraints.';
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

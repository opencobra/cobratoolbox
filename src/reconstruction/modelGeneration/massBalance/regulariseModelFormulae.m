function [model, regularisedFormulae,rGroupFormulae] = regulariseModelFormulae(model)
%Update the molecular formulae to make sure that they are consistent with
%model metadata, and expressed in Hill notation, with the exception that
%all R groups are replaced with the letter A

[nMet,~]=size(model.mets);

%requires https://uk.mathworks.com/matlabcentral/fileexchange/29774-stoichiometry-tools
for i = 1:nMet
    try
        formula = hillformula(model.metFormulas{i});
        model.metFormulas{i} = formula{1};
    catch ME
        if 0 %ignore messages when not debugging
            i
            disp(ME.message)        
            fprintf('%s\n',['Could not generate a chemical formulas in Hill Notation from: ' model.metFormulas{i}])
        end
    end
end

regularisedFormulae=false(nMet,1);
newFormulae=cell(nMet,1);
%get formulae from InChI
bool=1;
if isfield(model,'metInChIString')
    for i=1:nMet
        if ~isempty(model.metInChIString{i})
            %                             if i==316
            %                     pause(0.1)
            %                 end
            [formula, ~] = getFormulaFromInChI(model.metInChIString{i});
            hFormula = hillformula(formula);
            newFormulae{i} = hFormula{1};
            if ~strcmp(model.metFormulas{i},newFormulae{i})
                if bool==1
                    fprintf('%s\n','Metabolites that have old formula (left) replaced with InChI derived formula (right):');
                    bool=0;
                end
                regularisedFormulae(i)=1;
                fprintf('%s\t%s\t%s\n',model.mets{i}, model.metFormulas{i},newFormulae{i})
                model.metFormulas{i}=newFormulae{i};
            end
        end
    end
end

rGroupFormulae=false(nMet,1);
if 1
    irregularFormulaeTokens={'FULLRCO2FULLR2CO2','FULLRCO2FULLR2CO2X','FULLRCO','FULLRCO','FULLR2','FULL3','FULL','R2','R'};
    for i = 1:nMet
        if contains(model.metFormulas{i},irregularFormulaeTokens)
            for j=1:length(irregularFormulaeTokens)
                model.metFormulas{i}=strrep(model.metFormulas{i},irregularFormulaeTokens{j},'');
            end
            model.metFormulas{i}=[model.metFormulas{i} 'A'];
            rGroupFormulae(i)=1;
        end
    end
end

%convert to Hill notation - this will crash if anything other than symbol
%for a chemical element or an A
model.metFormulas=hillformula(model.metFormulas);

%put the A at the end
for i=1:nMet
    if rGroupFormulae(i)
    model.metFormulas{i}=strrep(model.metFormulas{i},'A','');
    model.metFormulas{i}=[model.metFormulas{i} 'A'];
    end
end

fprintf('\n%s\n',['#Metabolites: ' num2str(nMet)])
fprintf('%s\n',['#Inchi replacement formulae: ' num2str(nnz(regularisedFormulae))])
fprintf('%s\n',['#Formulae with ''A'' Group: ' num2str(nnz(rGroupFormulae))])
fprintf('%s\n',['#Empty formulae : ' num2str(nnz(isempty(model.metFormulas)))])



end


function outputNetworkOmix(model, rxnBool)
% Outputs a text file for import into omix
% http://www.13cflux.net/omix/
%
% USAGE:
%
%    outputNetworkOmix(model, rxnBool)
%
% INPUT:
%    model:      COBRA model structure
%
% OPTIONAL INPUT:
%    rxnBool:    boolean vector with 1 for each reaction to be exported

if nargin < 2
    rxnBool=true(size(model.S,2),1);
end

filename = 'networkForOmix';
if isfield(model,'description')
    if isstruct(model.description)
        if ~isempty(model.description.name)
            %models from rBioNet have model.description as a structure
            filename = strrep( strrep( strrep(model.description.name,'.','_'), filesep, '_' ), ':','_' );
        end
    else
        filename = strrep( strrep( strrep(model.description,'.','_'), filesep, '_' ), ':','_' );
    end
end

filename=[filename '.txt'];
fid=fopen(filename,'w');

for n=1:size(model.S,2)
    if rxnBool(n)
        formulas=printRxnFormula(model,model.rxns{n},0);
        fprintf(fid,'%s\n',[model.rxns{n} ':' formulas{1}]);
    end
end

fclose(fid);
fprintf('%s\n',['Network saved as ' filename ' in current directory'])

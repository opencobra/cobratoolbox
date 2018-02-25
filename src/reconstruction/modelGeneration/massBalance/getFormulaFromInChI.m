function [formula, protons] = getFormulaFromInChI(InChI)
% Extracts the chemical formula of a given compound from
% the InChI string provided
%
% USAGE:
%
%    [formula, protons] = getFormulaFromInChI(InChI)
%
% INPUT:
%    InChI:      The Inchi String of the chemical formula (e.g. InChI=
%                extract formula from `InChI = 1S/C3H4O3/c1-2(4)3(5)6/h1H3, (H,5,6)/p-1` for pyruvate
%
% OUTPUTS:
%    formula:    The chemical formula (including the protonation state
%    protons:    The total number of protons

[token,rem] = strtok(InChI, '/');
formula=strtok(rem, '/');

%This could be a composite formula, so combine it.
tokens = strsplit(formula,'.');

%The protonation state can also modify the formula! To get it, we remove
%any reconstruction fields, as they do not influence it.
InChI = regexprep(InChI,'/r.*','');
p_layer = regexp(InChI,'/p(.*?)/|/p(.*?)$','tokens');
protonationProtons = 0;
if ~isempty(p_layer)
    individualProtons = cellfun(@(x) {strsplit(x{1},';')},p_layer);
    protonationProtons = cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualProtons);
end


%Calc the coefs for all formulas
if (numel(tokens) > 1) || (~isempty(regexp(formula,'(^[0-9]+)'))) || (~isempty(p_layer))
    CoefLists = cellfun(@(x) calcFormula(x), tokens,'UniformOutput',0);
    if ~isempty(p_layer)
        CoefLists = [CoefLists;{{'H';protonationProtons}}];
    end
    %and now, combine them.
    Elements = {};
    Coefficients = [];
    for i = 1:numel(CoefLists)
        if isempty(CoefLists{i})
            %This should only happen, if there was no actual formula.
            continue
        end
        currentForm = CoefLists{i};
        Elements = [Elements,setdiff(currentForm(1,:),Elements)];
        current_coefs = cell2mat(currentForm(2,:));
        [A,B] = ismember(Elements,currentForm(1,:));
        %Extend the coefficients if necessary
        Coefficients(end+1:numel(Elements)) = 0;
        Coefficients(A) = Coefficients(A)+current_coefs;
    end

    Coefs = num2cell(Coefficients);
    Coefs(cellfun(@(x) x == 1, Coefs)) = {[]};
    Coefs = cellfun(@(x) num2str(x) , Coefs,'UniformOutput',0);
    if nargout > 1
        protons = Coefficients(ismember(Elements,'H'));
    end
    formula = strjoin([Elements , {''}],Coefs);
else
    %had to add this for some inchi, e.g.
    %InChI=1/C21H30O4/c1-19-8-5-14(23)11-13(19)3-4-15-16(19)6-9-20(2)17(15)7-10-21(20,25)18(24)12-22/h11,15-17,22,25H,3-10,12H2,1-2H3/t15-,16+,17+,19+,20+,21+/m1/s1
    protons = numAtomsOfElementInFormula(formula, 'H',0);
end


end


function [CoefList] = calcFormula(Formula)
multiplier = 1;
isReplicated = regexp(Formula,'(^[0-9]+)','tokens');
ElementTokens = regexp(Formula,'([A-Z][a-z]?)([0-9]*)','tokens');
Elements = cellfun(@(x) x{1}, ElementTokens,'UniformOutput',0);
Coefs = cellfun(@(x) str2num(x{2}), ElementTokens,'UniformOutput',0);
Coefs(cellfun(@isempty, Coefs)) = {1};

if ~isempty(isReplicated)
    multiplier = str2num(isReplicated{1}{1});
    Coefs = cellfun(@(x) x*multiplier, Coefs,'UniformOutput',0);
end

CoefList = [Elements;Coefs];
end

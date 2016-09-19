function pKa = estimate_pKa(mets,inchi,npKas,takeMajorTaut)
% Estimates pKa values with ChemAxon's Calculator plugins and determines
% all physiologically relevant pseudoisomers.
%
% pKa = estimate_pKa(mets,inchi,npKas,takeMajorTaut)
%
% INPUTS
% mets              m x 1 array of metabolite identifiers.
% inchi             m x 1 array of InChI strings for metabolites in mets.
%
% OPTIONAL INPUTS
% npKas             Maximum number of acidic and basic pKa values to
%                   estimate for each metabolite. Default is 20.
% takeMajorTaut     {1, (0)}. If 1, pKa values are estimated for the major
%                   tautomer at pH 7. If 0 (default), they are estimated
%                   for the given tautomer.
%
% OUTPUTS
% pKa               m x 1 structure array where each element has the fields
%                   listed below. All fields are empty for metabolites
%                   where no InChI is given. Fields:
% .success          Logical one (true) for metabolites where an InChI was
%                   given.
% .met              Metabolite identifier from mets without compartment
%                   abbreviation.
% .pKas             p x p matrix where element (i,j) is the pKa value for
%                   the acid-base equilibrium between pseudoisomers i and
%                   j.
% .zs               p x 1 array of pseudoisomer charges.
% .nHs              p x 1 array of number of hydrogen atoms in each
%                   pseudoisomer's chemical formula.
% .majorMSpH7       p x 1 logical array. True for the most abundant
%                   pseudoisomer at pH 7.
%
% REQUIRES
% cxcalc            ChemAxon's Calculator plugin, with licence
% cxcalc is part of Marvin Beans, available by academic licence from
% ChemAxon
% https://www.chemaxon.com/download/marvin-suite/#mbeans
% https://docs.chemaxon.com/display/docs/Installation+MS#InstallationMS-MarvinBeansforJava
% https://docs.chemaxon.com/display/CALCPLUGS/cxcalc+command+line+tool
% https://docs.chemaxon.com/display/docs/Installation+MS#InstallationMS-Linux/SolarisLinux/Solaris

% Hulda SH, Nov. 2012, Ronan Fleming 2016



% Configure inputs
if ischar(mets)
    mets = strtrim(cellstr(mets));
end
if iscell(mets)
    mets = regexprep(mets,'(\[\w\])$',''); % Remove compartment assignment
end
if isnumeric(mets)
    mets = num2cell(mets);
end

if ischar(inchi)
    inchi = strtrim(cellstr(inchi));
end

if ~exist('npKas','var')
    npKas = 20;
elseif isempty(npKas)
    npKas = 20;
end

if ~exist('takeMajorTaut','var')
    takeMajorTaut = false;
elseif isempty(takeMajorTaut)
    takeMajorTaut = false;
end
takeMajorTaut = logical(takeMajorTaut);
if ~takeMajorTaut
    takeMajorTaut = 'false';
else
    takeMajorTaut = 'true';
end

% Only estimate pKa for unique metabolites to increase speed
bool = ~cellfun('isempty',inchi);
inchi(~bool) = {''};
bool(ismember(inchi,{'InChI=1/p+1/fH/q+1'; 'InChI=1/H2/h1H'})) = false; % do not estimate for H+ and H2

[umets,crossi,crossj] = unique(mets(bool));
uinchi = inchi(bool);
uinchi = uinchi(crossi);

% Print inchi to temporary file for batch estimation of pKa
inchiFileName = 'inchi.inchi';
fid = fopen(inchiFileName,'w+');
fprintf(fid,'%s\n',uinchi{:});
fclose(fid);

% Estimate pKa
[status,result] = system(['cxcalc pka -a ' num2str(npKas) ' -b ' num2str(npKas) ' -M ' takeMajorTaut ' ' inchiFileName]);

if status ~= 0
    error('Could not estimate pKa values. Check that ChemAxon Calculator Plugins are installed correctly.')
end

% % Split for cxcalc 15.6.15.0 in tabs and empty lines.
% result = regexp(result,'\n?\t?','split');
% 
% % create a new result excluding the header
% for i=1:length(result)
%     if i>(2*npKas + 3)
%         g=i-(2*npKas + 2);
%         newresult{1,g}=result{i};
%     end
% end
% 
% % split this result in lines for each metabolite
% count=0;
% for i=1:(2*npKas + 2):(length(newresult)-(2*npKas + 2))%original
% %for i=1:(2*npKas + 2):length(newresult)%Ronan changed this 20th June 2016, temp fix, need to check with Hulda
%     count=count+1;
%     %disp(count)
%     for j=1:(2*npKas + 2)
%         %disp(j+i-1)
%         if j+i-1>=86702
%             newesresult{count,j}='';
%         else
%             %disp(newresult{j+i-1})
%             if j<(2*npKas + 2)
%                 % for pKa values change , by .
%                 if (j+i-1) <= length(newresult)
%                     newesresult{count,j}=strrep(newresult{j+i-1},',','.');
%                 end
%             else
%                 if (j+i-1) <= length(newresult)
%                     newesresult{count,j}=newresult{j+i-1};
%                 end
%             end
%         end
%     end
%     
% end

% Delete temporary file
delete(inchiFileName);

% Create unique pKa structure
upKa.success = true;
upKa.met = [];
upKa.pKas = [];
upKa.zs = [];
upKa.nHs = [];
upKa.majorMSpH7 = [];
upKa = repmat(upKa,length(uinchi),1);

% Parse cxcalc output
result = regexp(result,'\r?\n','split');
result = regexp(result,'^\d+.*','match');
result = [result{:}];
if length(result) ~= length(uinchi)
    error('Output from ChemAxon''s pKa calculator plugin does not have the correct format.')
end

errorMets = {};
for n = 1:length(uinchi)
    met = umets{n};
    currentInchi = uinchi{n};
    [formula, nH, charge] = getFormulaAndChargeFromInChI(currentInchi);
    
    pkalist = regexp(result{n},'\t','split');
    if length(pkalist) == 2*npKas + 2;
        pkalist = pkalist(2:end-1);
        pkalist = pkalist(~cellfun('isempty',pkalist));
        pkalist = regexprep(pkalist,',','.');
        pkalist = str2double(pkalist);
        pkalist = sort(pkalist,'descend');
        pkalist = pkalist(pkalist >= 0 & pkalist <= 14);
    else
        errorMets = [errorMets; {met}];
        upKa(n).success = false;
        pkalist = [];
    end
    
    if ~isempty(pkalist)
        pkas = zeros(length(pkalist)+1);
        pkas(2:end,1:end-1) = diag(pkalist);
        pkas = pkas + pkas';
        
        mmsbool = false(size(pkas,1),1);
        if any(pkalist <= 7)
            mmsbool(find(pkalist <= 7,1)) = true;
        else
            mmsbool(end) = true;
        end
        
        zs = 1:size(pkas,1);
        zs = zs - find(mmsbool);
        zs = zs + charge;
        
        nHs = 1:size(pkas,1);
        nHs = nHs - find(mmsbool);
        nHs = nHs + nH;
    else
        pkas = [];
        zs = charge;
        nHs = nH;
        mmsbool = true;
    end
    
    upKa(n).met = met;
    upKa(n).pKas = pkas;
    upKa(n).zs = zs;
    upKa(n).nHs = nHs;
    upKa(n).majorMSpH7 = mmsbool;
end

if ~isempty(errorMets)
    fprintf(['\nChemAxon''s pKa calculator plugin returned an error for metabolites:\n' sprintf('%s\n',errorMets{:})]);
end

% Create final output structure
pKa.success = false;
pKa.met = [];
pKa.pKas = [];
pKa.zs = [];
pKa.nHs = [];
pKa.majorMSpH7 = [];
pKa = repmat(pKa,length(inchi),1);

% Map pKa to input cell array
pKa(bool) = upKa(crossj);



% SAVESQUADMODEL  Save Odefy model in SQUAD format
%
%   SAVESQUADMODEL(MODEL,FILE) writes the Odefy model MODEL in SQUAD into
%   FILE.
%
%   SAVESQUADMODEL(MODEL,FILE,IGNOREAMBIGUOUS) takes an additional
%   parameter IGNOREAMBIGUOUS that determines how to handle cases where one
%   species has both and inhibitory and activatory influences on its
%   target. For IGNOREAMBIGUOUS=0 the function will quit with an error,
%   with IGNOREAMBIGUOUS=1 these cases will simply be ignored.
%
%   SQUAD is a software for the dynamic simulation of signaling networks 
%   using the standardized qualitative dynamical systems approach.
%
%
%   Reference:
%   A. Di Cara, A. Garg, G. De Micheli, I. Xenarios, L. Mendoza. Dynamic
%   simulation of regulatory networks using SQUAD. 
%   BMC Bioinformatics (2007), 26;8:462.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function SaveSQUADModel(odefymodel, file, ignoreambiguous)

if nargin < 3
    ignoreambiguous = 0;
end

h = fopen(file, 'w');

species = odefymodel.species;
% iterate over all species
for i=1:numel(odefymodel.species)
    
    inspecies = odefymodel.tables(i).inspecies;
    numinspecies = numel(inspecies);
    truth = odefymodel.tables(i).truth;
        
     if (numinspecies > 0)
         for j=1:numinspecies
             % construct the eval code (dirty!)
             before = '';
             for k=1:j-1
                 before = [before ':,'];
             end

             after = '';
             for k=j+1:numinspecies
                 after = [after ',:'];
             end
             % extract both subcubes, one for each dimension
             % of the input species
             eval(['zerocube = truth(' before '1' after ');']);
             eval(['onecube = truth(' before '2' after ');']);
             % comparison (dirty?)
             allact = numel(find((zerocube <= onecube) > 0)) == 2^(numinspecies-1);
             allinh = numel(find((zerocube >= onecube) > 0)) == 2^(numinspecies-1);
             
             % switch cases
             if (allact && ~allinh)
                 % activator
                 fprintf(h,'%s -> %s\n', species{inspecies(j)}, species{i});
             elseif (allinh && ~allact)
                 % inhibitor
                 fprintf(h,'%s -| %s\n', species{inspecies(j)}, species{i});
             elseif (allinh && allact)
                 % no effect, show warning, leave out
                 fprintf('Warning: %s is contained in the truth table of %s but has no actual effect on it.\n', species{inspecies(j)}, species{i});
             else
                 if (~ignoreambiguous)
                     % both false => ambiguous, we got a problem
                     error(sprintf('The influence of %s on %s is ambiguous. Set third parameter of this function to 1 to ignore such cases.', species{inspecies(j)}, species{i}));
                 end
             end
         end
     else
         % species has no inputs, do nothing
     end
end         

fclose(h);

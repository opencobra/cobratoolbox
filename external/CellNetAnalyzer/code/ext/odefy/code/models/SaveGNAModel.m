% SAVEGNAMODEL  Save Odefy model in Genetic Network Analyzer (GNA) format
%
%   SAVEGNAMODEL(MODEL,FILE) stores the Odefy model MODEL in Genetic
%   Network Analyzer format in FILE.
%
%   GNA employs piece-wise linear differential equations to represent
%   genetic regulatory networks.
%
%   Reference:
%   H. de Jong , J. Geiselmann, C. Hernandez, M. Page. Genetic Network
%   Analyzer: qualitative simulation of genetic regulatory networks.
%   Bioinformatics (2003), 12;19(3):336-44.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function SaveGNAModel(odefymodel, file)

h = fopen(file, 'w');

% gather the number of times each species is an input of reaction
numinputs = zeros(numel(odefymodel.species), 1);
countinputs = numinputs;
for i=1:numel(odefymodel.species)
    % iterate over input species
    for j=odefymodel.tables(i).inspecies
        numinputs(j) = numinputs(j) + 1;
    end
end

species = odefymodel.species;
% iterate over all species
for i=1:numel(odefymodel.species)

    inspecies = numel(odefymodel.tables(i).inspecies);

    if (inspecies > 0)
        % header stuff
        fprintf(h, 'state-variable: %s\n', species{i});
        fprintf(h, '  zero-parameter: z_%s\n', species{i});
        fprintf(h, '  box-parameter: max_%s\n', species{i});

        % generate state equation
        stateeq = [];
        synth = [];
        synthindex = 0;

        % increase counter
        for j=odefymodel.tables(i).inspecies
            countinputs(j) = countinputs(j) + 1;
        end
        % iterate over all dimensions in truth table
        truth = odefymodel.tables(i).truth;
        first = 1;
        for j=1:2^inspecies
            % only go further if value is 1
            if (truth(j) == 1)
                if (first)
                    first = 0;
                else
                    stateeq = [stateeq sprintf('+')];
                end
                % determine if we are in 0 or 1 dimension for each input spec
                binvec = dec2binvec(j-1, inspecies);
                synthindex = synthindex + 1;
                stateeq = [stateeq sprintf('\t\tk_%s_%i\n', species{i}, synthindex)];
                synth = [synth sprintf('k_%s_%i, ', species{i}, synthindex)];

                for k=1:inspecies
                    % inhibitor or activator?
                    if (binvec(k) == 0)
                        sign = '-';
                    else
                        sign = '+';
                    end
                    curinspec = odefymodel.tables(i).inspecies(k);
                    stateeq = [stateeq sprintf('\t\t* s%s(%s,t_%s_%i)\n', sign, species{odefymodel.tables(i).inspecies(k)}, species{curinspec}, countinputs(curinspec))];
                end
            end
        end

        % remove comma at last position
        synth = synth(1:end-2);
        % threshold
        if (numinputs(i) > 0)
            fprintf(h, '  threshold-parameters: ');
            for j=1:numinputs(i)
                if (j>1)
                    fprintf(h, ', ');
                end
                fprintf(h, 't_%s_%i', species{i},j);
            end
            fprintf(h, '\n');
        end
        % generate rest
        fprintf(h, '  synthesis-parameters: %s\n', synth);
        fprintf(h, '  degradation-parameters: g_%s\n', species{i});
        fprintf(h, '  state-equation:\n');
        fprintf(h, '    d/dt %s =\n', species{i});
        fprintf(h, stateeq);
        % append degradation
        fprintf(h, '\t\t- g_%s * %s\n', species{i}, species{i});
        % inequalities
        fprintf(h, '  parameter-inequalities:\n');
        fprintf(h, '\tz_%s < max_%s\n\n', species{i}, species{i});

    else
        % input species, that's easy
        fprintf(h, 'input-variable: %s\n', species{i});
        fprintf(h, '  zero-parameter: z_%s\n', species{i});
        fprintf(h, '  box-parameter: max_%s\n', species{i});
        % threshold
        if (numinputs(i) > 0)
            fprintf(h, '  threshold-parameters: ');
            for j=1:numinputs(i)
                if (j>1)
                    fprintf(h, ', ');
                end
                fprintf(h, 't_%s_%i', species{i},j);
            end
            fprintf(h, '\n');
        end
        % inequalities
        fprintf(h, '  parameter-inequalities:\n');
        fprintf(h, '\tz_%s < max_%s\n\n', species{i}, species{i});

    end

end

fclose(h);


function v = dec2binvec(binnum, n)

v = zeros(n,1);

for i=n-1:-1:0
    pow2 = 2^i;
    if binnum >= pow2
        v(i+1) = 1;
        binnum = binnum - pow2;
    end
end
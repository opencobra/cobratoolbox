function [cxcalcInstalled,oBabelInstalled,javaInstalled ] = checkChemoinformaticDependencies
%check chemoinformatic dependencies

% Check if ChemAxon and 
[cxcalcInstalled, ~] = system('cxcalc');
cxcalcInstalled = ~cxcalcInstalled;
if cxcalcInstalled == 0
    cxcalcInstalled = false;
    disp('cxcalc is not installed')
else
    cxcalcInstalled = true;
end

% Check if openBabel is installed
if isunix || ispc 
    obabelCommand = 'obabel';
else
    obabelCommand = 'openbabel.obabel';
end
[oBabelInstalled, ~] = system(obabelCommand);
if oBabelInstalled ~= 1
    oBabelInstalled = false;
    disp('obabel is not installed')
else
    oBabelInstalled = true;
end

% Check if java is installed
[javaInstalled, ~] = system('java');
if javaInstalled ~= 1 && options.atomMapping
    javaInstalled = false;
    disp('java is not installed')
else
    javaInstalled = true;
end

end


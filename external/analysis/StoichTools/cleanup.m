%% Cleanup the StoichTools Directory

if exist('README.pdf','file')
    delete('README.pdf');
end

if exist('atomic.m~','file')
    delete('atomic.m~');
end

if exist('hillformula.m~','file')
    delete('hillformula.m~');
end

if exist('disp_reaction.m~','file')
    delete('disp_reaction.m~');
end

if exist('install.m~','file')
    delete('install.m~');
end

if exist('molweight.m~','file')
    delete('molweight.m~');
end

if exist('parse_formula.m~','file')
    delete('parse_formula.m~');
end

if exist('README.m~','file')
    delete('README.m~');
end

if exist('stoich.m~','file')
    delete('stoich.m~');
end


publish('README',struct('format','pdf','outputDir',pwd));
publish('README');
publish('zHW_01');
publish('zHW_02');
publish('zHW_03');
publish('zHW_04');
publish('zHW_05');

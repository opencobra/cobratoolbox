function y = testReadFlags(silent)

if (silent == 0)

disp('Testing readFlags');
disp('********************************************************');
disp('Failed read messages will be printed and can be ignored.');
disp('********************************************************');
end;

test = 78;
Totalfail = 0;

filename = fullfile(pwd,'test-data', 'none.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 0)', filename);
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 0)', filename);
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 1)', filename);
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 1)', filename);
[m, e] = TranslateSBML(filename, 1, 1);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 0)', filename);
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 0)', filename);
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==6);

filename = fullfile(pwd,'test-data', 'warn.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 1)', filename);
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 0)', filename);
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 0)', filename);
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);

filename = fullfile(pwd,'test-data', 'errors.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 1)', filename);
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

disp('EXPECTED FAIL 1 Reports: Error encountered during read.');
filename = fullfile(pwd,'test-data', 'readerror.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 0)', filename);
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

filename = fullfile(pwd,'test-data', 'readerror.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 0)', filename);
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==4);

disp('EXPECTED FAIL 2 Reports: Error encountered during read.');
disp('List error 21103')
filename = fullfile(pwd,'test-data', 'readerror.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 1)', filename);
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

filename = fullfile(pwd,'test-data', 'both.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 0)', filename);
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'both.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 0)', filename);
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==4);

filename = fullfile(pwd,'test-data', 'both.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 1)', filename);
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

disp('EXPECTED FAIL 3 Reports: No model returned.');
filename = fullfile(pwd,'test-data', 'fatal.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 0)', filename);
[m, e] = TranslateSBML(filename, 0, 0);
Totalfail = Totalfail + fail_unless(functionCall, isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

disp('EXPECTED FAIL 4 Reports: No model returned.');
filename = fullfile(pwd,'test-data', 'fatal.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 0)', filename);
[m, e] = TranslateSBML(filename, 1, 0);
Totalfail = Totalfail + fail_unless(functionCall, isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

disp('EXPECTED FAIL 5 Reports: No model returned.');
filename = fullfile(pwd,'test-data', 'fatal.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0, 1)', filename);
[m, e] = TranslateSBML(filename, 0, 1);
Totalfail = Totalfail + fail_unless(functionCall, isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

disp('EXPECTED FAIL 6 Reports: No model returned.');
filename = fullfile(pwd,'test-data', 'fatal.xml');
functionCall = sprintf('TranslateSBML(''%s'', 1, 1)', filename);
[m, e] = TranslateSBML(filename, 1, 1);
Totalfail = Totalfail + fail_unless(functionCall, isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

%test default flags

filename = fullfile(pwd,'test-data', 'none.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0)', filename);
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'none.xml');
functionCall = sprintf('TranslateSBML(''%s'')', filename);
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0)', filename);
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'warn.xml');
functionCall = sprintf('TranslateSBML(''%s'')', filename);
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0)', filename);
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'errors.xml');
functionCall = sprintf('TranslateSBML(''%s'')', filename);
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

disp('EXPECTED FAIL 7 Reports: Error encountered during read.');
disp('List error 21103')
filename = fullfile(pwd,'test-data', 'readerror.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0)', filename);
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

disp('EXPECTED FAIL 8 Reports: Error encountered during read.');
disp('List error 21103')
filename = fullfile(pwd,'test-data', 'readerror.xml');
functionCall = sprintf('TranslateSBML(''%s'')', filename);
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

filename = fullfile(pwd,'test-data', 'both.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0)', filename);
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

filename = fullfile(pwd,'test-data', 'both.xml');
functionCall = sprintf('TranslateSBML(''%s'')', filename);
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, isempty(e));

disp('EXPECTED FAIL 9 Reports: No model returned.');
filename = fullfile(pwd,'test-data', 'fatal.xml');
functionCall = sprintf('TranslateSBML(''%s'', 0)', filename);
[m, e] = TranslateSBML(filename, 0);
Totalfail = Totalfail + fail_unless(functionCall, isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

disp('EXPECTED FAIL 10 Reports: No model returned.');
filename = fullfile(pwd,'test-data', 'fatal.xml');
functionCall = sprintf('TranslateSBML(''%s'')', filename);
[m, e] = TranslateSBML(filename);
Totalfail = Totalfail + fail_unless(functionCall, isempty(m));
Totalfail = Totalfail + fail_unless(functionCall, ~isempty(e));
Totalfail = Totalfail + fail_unless(functionCall, length(e)==1);
disp('  ');

if (silent == 0)

disp('**************************************');

disp(sprintf('Number tests: %d', test));
disp(sprintf('Number fails: %d', Totalfail));
disp(sprintf('Pass rate: %d%%\n', ((test-Totalfail)/test)*100));
end;

if (Totalfail == 0)
    y = 0;
else
    y = 1;
end;

function y = fail_unless(functionCall, arg)

if (~arg)
    y = 1;
    disp('=================================================');
    disp(sprintf('TEST FAILURE: %s\n', functionCall));
    disp('=================================================');
else
    y = 0;
end;
    

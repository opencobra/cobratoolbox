load textbook.mat

v = checkThermodynamicConsistency(model);

disp(norm(v))
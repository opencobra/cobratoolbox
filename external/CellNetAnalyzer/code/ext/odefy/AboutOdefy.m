% ABOUTODEFY
%
%   ABOUTODEFY shows the Odefy about dialog (if Java GUIs are available)
%   and prints version information to the console.
function AboutOdefy(parent)

description = 'Odefy - From discrete to continuous models';
curversion = '1.10';
web = 'http://cmb.helmholtz-muenchen.de/odefy ';


fprintf('\n');
fprintf('%s\n',description);
fprintf('Version %s\n',curversion);
fprintf('%s\n',web);
fprintf('\n');

if IsMatlab
    if nargin<1
        parent=[];
    end

    try
        dialog = odefy.ui.AboutDialog(parent,'About Odefy');
        dialog.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
        % image is actually inside the JAR
        dialog.setIcon('images/Odefy_logo.png');
        dialog.setVersion(curversion);
        dialog.setDescription(description);
        dialog.setUrl(web);
        %dialog.setForeground(java.awt.Color.WHITE);
        dialog.setLocationRelativeTo(parent);
        dialog.setVisible(true);
        dialog.pack();
    catch
    end
end
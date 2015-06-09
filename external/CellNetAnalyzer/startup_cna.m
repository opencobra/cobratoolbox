% automatically load Java classes at Matlab startup only because a call to
% javaaddpath implicitly clears all global variables
if isempty(javachk('jvm')) % only load Java classes when the JVM is running
  cna_java_classes_jar= fullfile(pwd, 'code', 'cna_java_classes.jar');
  if exist(cna_java_classes_jar, 'file')
    disp('Loading CNA Java classes.');
    javaaddpath(cna_java_classes_jar);
  end
  clear cna_java_classes_jar
end
startcna

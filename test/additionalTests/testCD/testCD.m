%test to see if io of cell designer maps is lossless
[GlyXml, GlyMap] = transformXML2Map('glycolysisAndTCA.xml');

transformMap2XML(GlyXml,GlyMap,'glycolysisAndTCA_test.xml');

[GlyXml2, GlyMap2] = transformXML2Map('glycolysisAndTCA_test.xml');

%Compare xml structure
[resultXml, whyXml] = structeq(GlyXml, GlyXml2);

assert(resultXml==1)

%Compare map structure
[resultMap, whyMap] = structeq(GlyMap, GlyMap2);

assert(resultMap==1)
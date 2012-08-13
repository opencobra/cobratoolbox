#!perl

use strict;
open(IN, "slvrXX.m") or die ("cannot open file"); #default file name
open(OUT, ">validateIDV.m") or die;

<IN>;
print OUT "function [out] = validateIDV(v, xglcDe, valt, IDVs)\n\n";

print OUT "names = fieldnames(IDVs);\n";
print OUT "for l = 1:length(names)
    name = char(names(l));
    idv = IDVs.(name);
    cdv = idv2cdv(log2(length(idv)))*idv;
    CDVs.(name) = cdv;
end\n";
# idv2idv(log2(length(idv)))*
my $line;
while(($line = <IN>) !~ /^\% level: 1/){
    print OUT $line;
}

while(($line = <IN>) !~ /^\% Assign isotopomers/){
}

while($line = <IN>){
    chomp $line;
    if ($line =~ /(.+)\s*\=\s*(.+);/){
        my $part2 = $2;
        my $part1 = $1;
        if ($part2 =~ /x\d+\(\d+\)/){
            print OUT "$part2 = CDVs.$part1;\n";
        }
    }
}

# pass 2.
close(IN);
open(IN, "slvrXX.m") or die ("cannot open file"); #default file name
while(($line = <IN>) !~ /^\% level: 1/){
}

#for(my $i = 1; $i<=11; $i++){
#    print OUT x$i = $
#}

while(($line = <IN>) !~/^\% Assign isotopomers/){
    if($line =~ /x(\d+)\s*\=/){
        #print OUT "size(x$1)\n";
        #print OUT "size(A$1)\n";
        #print OUT "size(B$1)\n";
        print OUT "[values, index] = sort(-abs(A$1 * x$1' - B$1));\n";
        print OUT "level = $1\n";
        print OUT "[[index(values<-.000001)], [values(values<-.000001)]]\n";
    }
    else{
        print OUT $line;
    }
}



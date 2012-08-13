#!perl

use strict;
open(IN, "slvrCumomer.m") or die ("cannot open file"); #default file name
open(OUT, ">slvrCumomer_fast.m") or die;

my $line;
while(($line = <IN>) !~ /^\% level: 1/){
    print OUT $line;
}

print "initial code print\n";

my %adict;
my @bdict;
my $level = 1;
my $leveln; # size of level;

while(($line = <IN>) !~ /Assign isotopomers/i){
    #if($line =~ /\s+\%/){
    chomp $line;
    if ($line =~ /^\%\s*level/){
        printlevel();
        
        $level++;
        %adict = ();
        @bdict = ();
        
    }
    $line =~ s/\s*\%.*//; # trim comments
    $line =~ s/;.*//; # trim semi colons
    if ($line =~ /sparse\((\d+)/){
        $leveln = $1;
    }
    elsif( $line =~ /zeroes/){}
    elsif($line =~ /^A\d+\((\d+),\s*(\d+)\)/){
        my $x1 = $1;
        my $x2 = $2;
        die unless $x1;
        die unless $x2;
        my $line2;
        if ($x1 == $x2){
            $line =~ /\=/;
            $line2 = $';
        }
        else{
            $line =~ /\=\s*A\d+\(.+?\)/;
            $line2 = $';
        }
        if($line2 !~ /^\s*[+-]/){
            $line2 = '+'.$line2;
        }
        $adict{$x1.'x'.$x2}.= $line2;
        
    }
    elsif($line =~ /^B\d+\((\d+)\)\s*=\s*/){
        my $bindex = $1;
        my $post = $';
        if ($post =~ /B\d+\(\d+\)/){
            $post = $';
        }
        else{
            print "uh\n";
            print $line;
        }
        $bdict[$bindex] = $bdict[$bindex] .$post;
    }
    else{
        
    }
    
}
printlevel();

print OUT $line;

print "Isotopomers\n";
my $i = 0;
while($line = <IN>){
    chomp $line;
    if($line =~ /(x\w+)\s*\=\s*zeros\(.*\)/){
        print OUT "$1 = [\n";
    }
    elsif($line =~ /output\.(x\w+).+cdv2idv\((\d+)\)/){
        print OUT "];\noutput.$1 = cdv2idv($2)*$1;\n";
        $i = 0;
    }
    elsif($line =~ /\s*\=\s*(.+)\;/){
        print OUT "$1; ";
        $i++;
        print OUT "\n" if $i % 10 == 0;
    }
    else{
        print "$line";
    }
}
#print OUT <IN>; # slurp the rest.
print "Done\n";

exit;

sub printlevel(){
    print "printing level $level\n";
    print OUT '% level '."$level\n";
    
    # print I
    print OUT 'i=[';
    my $i = 0;
    foreach my $key (sort keys %adict){
        $i++;
        my @parts = split /x/, $key;
        print OUT $parts[0], "; ";
        print OUT "\n" if ($i % 10 == 0);
    }
    print OUT '];'."\n";
    
    # print J
    print OUT 'j=[';
    $i = 0;
    foreach my $key (sort keys %adict){
        $i++;
        my @parts = split /x/, $key;
        print OUT $parts[1], "; ";
        print OUT "\n" if ($i % 10 == 0);        
    }
    print OUT '];'."\n";
    
    # print K
    print OUT 'k=[';
    foreach my $key (sort keys %adict){
        my $val = $adict{$key};
        if ($val =~ /^\s*\+/){
            $val = $';
        }
        print OUT $val, ";\n";
    }
    print OUT '];'."\n";
    
    
    # print B
    print OUT 'B=[';
    for (my $i = 1; $i<=$leveln; $i++){
        my $val = $bdict[$i];
        if ($val =~ /^\s*\+/){
            $val = $';
        }
        print OUT ($val ? $val:'0'). "; ";
        print OUT "\n" if ($i % 10 == 0);
        
    }
    print OUT '];'."\n";
    
    
    
    # print computations   
    print OUT "A = sparse(i,j,k, $leveln, $leveln);\n";
    
    print OUT "x$level = solveLin(A,B);\n";
    #print OUT "x$level = A\\B;\n"; # regular way
    #print OUT "sort(sum(abs(full(A)),2 ))\npause;";
    #print OUT "t2 = find(sum(abs(A)));\npause;";
    #print OUT "B(t)\npause;";
    #print OUT "A2 = A(:,t2);\n";
    #print OUT "B2 = B;\n";
    #print OUT "size(B2)\nsize(A2)\npause;\n";
    #print OUT "x2t$level = A2\\B2;\npause;";
    
    #print OUT "t3 = find(sum(abs(A2),2));\npause;";
    #print OUT "B(t)\npause;";
    #print OUT "A3 = A2(t3,:);\n";
    #print OUT "B3 = B2(t3);\n";
    #print OUT "size(B3)\nsize(A3)\npause;\n";
    #print OUT "x3t$level = A3\\B3;\npause;\n";
    #print OUT "f2 = null(full(A3))\n";
    #print OUT "ff = find(sum(abs(f2),2)>1e-5),pause;\n";
    #print OUT "f2(ff,:),pause;\n";
    #print OUT "B3(ff),pause;\n";
    #print OUT "tic;rref(A2);toc,pause\n";
    #print OUT "tic;lu(A2);toc,pause\n";
    #print OUT "x$level(isnan(x$level)) = 0;\n";
    #print OUT "x$level = pinv(full(A))*B;\n"; # pseudo inverse way
    #print OUT "x$level = bicgstab(A,B, 1e-8,5000);\n"; # LSQR
    #print OUT "x$level = inv(A'*A)*A'*B;\n"; # other way
    #print OUT "[C,R] = qr(A,B); x$level = R\\C;\n"; # LSQR
    
    
    print OUT "\n\n\n";
}
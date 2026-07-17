#!perl

use strict;
open(IN, "slvrEMU.m") or die ("cannot open file"); #default file name
open(OUT, ">slvrEMU_fast.m") or die;

my $line;
while(($line = <IN>) !~ /^\% level: 1/){
    
        
    $line =~ s/%.*//;
    
    $line =~ s/slvrEMU/slvrEMU_fast/;
    
    print OUT $line;
}

print "initial code print\n";

my %adict;
my @bdict;
my $level = 1;
my $leveln; # size of level;

while(($line = <IN>) !~ /Assign outputs/i){
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
        if ($line !~ /=.*A\d+\(/){
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
    elsif($line =~ /^B\d+\((\d+)..\)\s*=\s*/){
        my $bindex = $1;
        my $post = $';
        if ($post =~ /B\d+\(\d+..\)/){
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

print "outputs\n";
my $i = 0;
while($line = <IN>){
    print OUT $line;
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
        my @parts = split /(?= \+| \-)/, $val;
        my %parthash;
        foreach my $part( @parts){
            next unless $part =~ /\d/;
            my $sign = 1;
            $sign = -1 if $part =~ /\-\s/;
            my $coefficient = 1;
            if ($part =~ /\b(\d*\.?\d*e?\-?\+?\d+)\*/){
                $coefficient = $1;
            }
            my $vindex = 0;
            if ($part =~ /\w+\(.+\)/){
                $vindex = $&;
            }
            else{
                print "$val\n$part  crud\n";<>;
            }
            
            $parthash{$vindex} += $sign * $coefficient;
        }
        #print $val, "<< Original\n";
        #print join " YYY ", @parts;
        #print "\n";
        #print join " XXX ", %parthash;
        #print "<<\n\n";
        #<> if $val =~ /\de\-\d/;
        my $first = 1;
        foreach my $k2 (keys %parthash){
            if($parthash{$k2} == 0){
                print "$k2 uh oh\n";
                print $val, "<< Original\n";
                print join " XYX ", %parthash;
                <>;
            }
                
            if($parthash{$k2} > 0){
                print OUT '+' unless $first;
                print OUT (($parthash{$k2} == 1 ?'': $parthash{$k2}.'*' ).$k2);
            }
            else{
                if ($parthash{$k2} == -1){
                    print OUT '-'.$k2;
                }
                else{
                    print OUT $parthash{$k2}.'*'.$k2;
                }
            }
            $first = 0;
        }
        print OUT ";\n";
    }
    print OUT '];'."\n";
    
    
    # print B
    print OUT "B = zeros($leveln,".($level+1   ).");\n";
    for (my $i = 1; $i<=$leveln; $i++){
        my $val = $bdict[$i];
        if ($val =~ /^\s*\+/){
           $val = $';
        }
        if ($val){
            print OUT "B($i,:) = $val;\n";
        }
    }
    #print OUT 'B=[';
    #for (my $i = 1; $i<=$leveln; $i++){
    #    my $val = $bdict[$i];
    #    if ($val =~ /^\s*\+/){
    #        $val = $';
    #    }
    #    print OUT ($val ? $val:'0'). "; ";
    #    print OUT "\n" if ($i % 10 == 0);
    #    
    #}
    #print OUT '];'."\n";
    
    
    
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
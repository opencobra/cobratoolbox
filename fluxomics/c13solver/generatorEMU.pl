#!perl

use strict;
open(IN, "IsotopomerModel.txt") or die;
my $outfile = "slvrEMU";

my @lv = (); # hash for memoizing levels.

my $known = <IN>;
chomp $known; # first line has to be known carbon source.
my %known =  ( $known =>1 ); #, 'A' =>1);

my %symm; # reactions involving symmetric compounds.
my %reactions; #reaction name -> number between 1 and N
my %metabolites; #metabolite name -> number between 1 and M
my %metabolitesn; #metabolite name -> n (size of metabolite)
my @metabolites;
my @reactions;

my %source;
my %drain;

my $i; #reaction counter
my $j = 1; #metabolite counter

# read in description file
my $line = <IN>;
OUTER: while($line){
  chomp $line;
    
  my @parts = split /\s+/, $line;
  my $name = shift @parts;
  my $i = shift @parts;
  $i =~ s/v//;
  #print scalar @parts, " ", scalar @parts2;
  #print '';
  #die "$line\n $line2" unless scalar @parts == 2*(scalar @parts2)-1;
  my $rflag = 0;
  my @products;
  my @reactants;
  my @pproducts;
  my @preactants;
  my @cproducts;
  my @creactants;
  
  while(my $met = shift @parts){
    if($met eq '>'){
   #   $reversible = 0;
      $rflag = 1;
    }
    elsif($met eq '<=>'){
      die "no longer works with reversible reactions";
    #  $reversible = 1;
      $rflag = 1;
    }
    else{
      my $coefficient = $met;
      $met = shift @parts;
      if (! $metabolites{$met} && ! $known{$met}){
        $metabolites{$met} = $j;
        if (! $met){
          print "whoops";
          die "";
        }
        $j++;
        push @metabolites, $met;
      }
      if($rflag){
      }
      else{
      }
    }
  }

 
  my $k = "00"; # counter of isotopomer definitions for this reaction
  my $line2 = <IN> ; chomp $line2;  
   while ($line2 =~ /#/){ # alternate isotopomer definition exists
    $k++; # counter for isotopomer definitions.
    print ">>> $line, $line2 <<<";
    my @parts = split /\s+/, $line;
    my @parts2 = split /\s+/, $line2;
    $symm{$name}++;
    
    my $name = shift @parts;
    $i = shift @parts; #redundant code...
    $i =~ s/v//;
    
    #print scalar @parts, " ", scalar @parts2;
    
    print scalar @parts;
    print scalar @parts2;
    die "$line\n$line2" unless scalar @parts == 2*(scalar @parts2)-1;
    #my $reversible;
    my $rflag = 0;
    
    my @products;
    my @reactants;
    my @pproducts;
    my @preactants;
    my @cproducts;
    my @creactants;
    
    while(my $met = shift @parts){
      my $met2 = shift @parts2;
      if($met eq '>'){
     #   $reversible = 0;
        $rflag = 1;
      }
      elsif($met eq '<=>'){
        die("can no longer deal with reversible reactions");
      #  $reversible = 1;
        $rflag = 1;
        $symm{$name.'_r'} = 1 if $k > 1;
      }
      else{
        my $coefficient = $met;
        $met = shift @parts;
        $metabolitesn{$met} = length($met2)-1;
        if($rflag){
          push @products, $met;
          push @pproducts, $met2;
          push @cproducts, $coefficient;
        }
        else{
          push @reactants, $met;
          push @preactants, $met2;
          push @creactants, $coefficient;
        }
      }
    }
    $reactions{$name} = $i;
    $k = $k+0;
    if ($k < 10){
      $k = "0".$k;
    }
    $reactions{$name."_$k"} = $i;
    push @reactions, $name unless $reactions[-1] eq $name;
    sourcedrain($name."_$k", \@reactants, \@products, \@preactants, \@pproducts, \@creactants, \@cproducts);
    $line2 = <IN>;
    chomp $line2 if $line2;
    if($line2 =~ /\!\!Measured Metabolites\!\!/){
      # read outputs;
      print "breaking out of loop \n";
      checkmetabolites();
      last OUTER;
    }
  }
  
  checkmetabolites();
  $line = $line2;
}
#read outputs
my %outputs;
my $o;
while($o = <IN>){
  print "blip";
  chomp $o;
  my @parts = split /\->/, $o;
  my $met = $parts[0];
  my $emu = $parts[1];
  $emu =~ s/\D//g;
  
  $outputs{$met.'#'.$emu} = $metabolites{$met};
}

if (scalar %outputs == 0){
  print "outputs file not found.  assuming everything is output\n";
  %outputs = %metabolites;
  die "should not get here because outputs must be known\n";
}
else{
  print "output file found";
}
######################################
############### done reading in. #####
######################################
print "done reading\n";

checkmetabolites();



# build up emu's
my %tmets = %outputs;
my %needed;
my %not_needed;
my @emus;
while(scalar keys %tmets){
  my $not_needed = 0;
  my $key = chooselargest(\%tmets);

  my $size = sizeof($key);
  my ($met, $emut) = split /#/, $key;
  #my @emut = reverse (split //, $emut);
  my @emut = (split //, $emut);
  if($emus[$size]->{$key}){
    delete $tmets{$key};
    next;
  }
  if ($known{$met}){
    $needed{$key} = 1;
    delete $tmets{$key};
    next;
  }
  print "processing: $key\n";
  $emus[$size]->{$key} = 1;
  #print "xx ", $met, "\n";
  if(scalar keys %{$source{$met}} ==1){
    $not_needed = 1;
  }
  foreach my $rxn (keys %{$source{$met}}){
    #print "met: $key - rxn: $rxn\n";
    my %imets;
    for (my $i = 0; $i < @{$source{$met}->{$rxn}}; $i++){
      next unless $emut[$i];
      my $imet = $source{$met}->{$rxn}->[$i]->[0];
      my $atom = $source{$met}->{$rxn}->[$i]->[1];
      $imets{$imet} += 2** $atom;
    }
    foreach my $imet (keys %imets){
      my $imet2 = substr($imet, 0, length($imet)-2);
      #print ">>>$imet $imet2\n";
      my $imetname = $imet2.'#'.dec2bin($imets{$imet}, $metabolitesn{$imet2});
      $tmets{$imetname} = 1;
      push @{$not_needed{$key}}, $imetname if $not_needed;
      #print $imet2.'#'.dec2bin($imets{$imet}, $metabolitesn{$imet2}), "<-sizen: ", $metabolitesn{$imet2},"\n";
    }
    #print "\n";
  }
  #print "finished met $key\n";
  delete $tmets{$key};
}

# total BS hack.  This needs to be fixed.  Only works for one model.
#my @removekeys = grep {$_ =~ /xlacL#/} keys %not_needed;
#foreach (@removekeys){
#  delete $not_needed{$_};
#}

print scalar keys %not_needed, "\n";
open(OUT, ">convertCarbonInput.m");
print OUT "function [out] = convertCarbonInput($known)\n";
print OUT "c2i = cdv2idv(",($metabolitesn{$known}),");\n";
foreach my $key (keys %needed){
  my ($met, $emut) = split /#/, $key;
  my $emut2 = join ';', (split //, $emut);
  print OUT "out.x$emut"." = idv2mdv(".($metabolitesn{$met}).", [".$emut2."])*"."c2i* $known; % $met \n";
}
close(OUT);




#print "@reactions\n";

# xn (x1, x2, x3 ... xn)
# An (A1, A2, A3 ... An)
# Bn (B1, B2 ... Bn)





open(OUT, ">$outfile.m");

print OUT "function [output] = $outfile(v_in, $known)\n";
print OUT "% input:  v has size unknown\n";
print OUT "% input:  $known has size ". (2 ** $metabolitesn{$known})."\n";

#print OUT "if nargin >= 3\n";
#foreach my $rxn (@reactions){
#  print OUT "    v(". $reactions{$rxn}. ") = valt.$rxn;\n";
#}
#print OUT "end\n";


print OUT "\n% dividing symmetric fluxes\n";
print OUT "\n v = v_in;\n";
foreach my $symm (keys %symm){
  if ($symm{$symm} > 1){
    print OUT "v(", $reactions{$symm}, ") = v_in(", $reactions{$symm}, ")/".($symm{$symm}) ."; % $symm is a symmetric reaction\n";
  }
}


my $maxlevel = 0;
for (my $i = 0; $i < scalar @emus; $i++){
  $maxlevel = $i;
  my $j = 1;
  foreach my $key (sort keys %{$emus[$i]}){
    my $key2 = $key;
    $key2 =~ s/#.*//;
    if ($known{$key2}){
      print $key, "crap";
      <>;
      next;
    }
    if($not_needed{$key}){
      print "skipping $key\n";
      next;
    }
    $emus[$i]->{$key} = $j;
    $j++;
  }
}

for(my $n = 1; $n <= $maxlevel; $n++){ # for each level loop
  print ">>>>>>>>>>>>>>>>>>>> level $n <<<<<<<<<<<<<<<\n";
  my $sizen = sizen($n);
  print OUT "\n% level: $n of size $sizen\n";
  
  next if $sizen == 0; # we can skip if x$n is never used. 
  
  print OUT "A$n = sparse($sizen, $sizen);\n";
  print OUT "B$n = zeros($sizen, ".($n+1).");\n";
  foreach my $met(sort {$emus[$n]->{$a} <=> $emus[$n]->{$b}} keys %{$emus[$n]}){  # for each metabolite loop
    if($not_needed{$met}){
      print "$met ... skiping\n";
      next;
    }
    print "$met \n";
    my $metname = $met;
    $metname =~ s/#.*//;
    my $metlabel = $met;
    $metlabel =~ s/.*#//;
    print OUT "%>>> $met#\n";
    my $rowindex = $emus[$n]->{$met}; # get the row index.
    
    
    ############### drains ######################
    print OUT "A$n($rowindex, $rowindex) = ";
    my $commentstring = '';
    my $first = 1;
    if (scalar keys %{$drain{$metname}} == 0){
      print "warning:  $met has no drains.  No way to balance.";
      <>;
    }
    foreach my $drain (keys %{$drain{$metname}} ){  # go through all the drains.
      print OUT " + " unless $first;
      $first = 0;
      print OUT $drain{$metname}->{$drain}, "*" if $drain{$metname}->{$drain} != 1; # coefficient multiplier if needed.
      print OUT "v(", $reactions{$drain} ,")";
      $commentstring .= ":$drain";
    }
    print OUT "; % drain $commentstring \n";
    
    
    
    ################# sources ###################
    my @label = split //, $metlabel; # label of balanced compound.
    foreach my $source (keys %{$source{$metname}} ){  # for each source (reactions)
      my $pcoefficient = 1;
      my @array = @{$source{$metname}->{$source}}; #store info.
      if (scalar @array != $metabolitesn{$metname}){ #sanity check.  Each Carbon must come from somewhere.
        die "unaccounted for carbons";
      }
      my %t; #track where each atom comes from.
      for(my $i = 0; $i<@array; $i++){
        $t{$array[$i]->[0]} += 2**($array[$i]->[1]) if $label[$i];
        if ($array[$i]->[2] != 1){
         # die "non 1 coefficient in products";
         $pcoefficient = $array[$i]->[2];
        }
      }
      my $levelsum = 0;
      foreach my $t (keys %t){
        my $lv = level($t{$t});
        $levelsum += $lv;
      }
      if ($levelsum != $n){
        print "something is not right $levelsum $n";
        die;
      }
      %t;
     # convert one way. 
      my @tnames = map {my $m = $_;
                      my $tindex = $t{$m};
                      my $mname =substr($m, 0, length($m)-2);
                      my $isoindex = dec2bin($tindex, $metabolitesn{$mname});
                      my $actual_metabolite = $mname.'#'.$isoindex;
                      #return $actual_metabolite;
                      #return "hello";
                      } keys %t;
      # fix any that are broken.
      while(grep {$not_needed{$_}} @tnames){
        print "actually doing something! @tnames\n";
        my @oops = grep {$not_needed{$_}} @tnames;
        my @newtnames = ();
        foreach my $oops (@oops){ 
          push @newtnames, @{$not_needed{$oops}};
        }
        @tnames = (@newtnames, grep {!$not_needed{$_}} @tnames);
      }
      # convert back
      die "too many digits" if scalar @tnames > 9;
      my $kk = 0;
      %t = ();
      foreach my $tname (@tnames){
        my $aname = $tname;
        $aname =~ s/#.*//;
        my $aemu = $tname;
        $aemu =~ s/.*#//;
        my $c = 0;
        for(my $g = 0; $g< length($aemu); $g++){
          $c += 2** $g if substr($aemu, $g, 1) eq '1';
        }
        $t{$aname.'_'.$kk} = $c;
        $kk++;
      }
      %t;
      
      my $rxnindex = $reactions{$source};
      if(scalar keys %t == 1){ # metabolites comes from a single source.  It's either known or unknown.
        my $t = join '', keys %t; # the only metabolite...
        my $tindex = $t{$t};
#        print $tindex, "\n";
        $t = substr($t, 0, length($t)-2);
        #die unless level($tindex) == level($index);
        my $indexbin = dec2bin($tindex, $metabolitesn{$t}); # for display purposes
        if (! $known{$t}){ # if unknown
          my $metindex = $emus[$n]->{$t.'#'.dec2bin($tindex,$metabolitesn{$t})};
          unless ($metindex){
            print ">>>>>>",$t.'#'.dec2bin($tindex,$metabolitesn{$t})," ", $emus[$n]->{$t.'#'.dec2bin($tindex,$metabolitesn{$t})} , "\n";
            print "v($rxnindex)\n";
            <>;
          }
          print OUT "A$n($rowindex, $metindex) = A$n($rowindex, $metindex) - " .($pcoefficient == 1?"":"$pcoefficient*"). "v($rxnindex); % source1:$source:$t#$indexbin($tindex)\n";
        }
        else{ # if known...0
          print OUT "B$n($rowindex,:) = B$n($rowindex,:) + " .($pcoefficient ==1?"":"$pcoefficient*"). "$t.x".(dec2bin($tindex, $metabolitesn{$t}))."\' * v($rxnindex); % source1:$source:$t#$indexbin($tindex)\n";
        }
      }
      elsif(scalar keys %t >= 2){ # More than one source.  Each fragment has size < n and is therefore known.
        die "aha" if scalar keys %t > 2;
        my @ts_original = keys %t;
        my @ts = map {substr($_, 0, length($_)-2)} @ts_original;
        
        my @strings = map {''} @ts;
        my @cs = map {''} @ts;
        
        for(my $i = 0; $i< @ts; $i++){
          if($known{$ts[$i]}){  # this case never comes up and is therefore untested as of now.  In theory it may come up
            #$strings[$i] = $ts[$i]."(".$t{$ts_original[$i]}."+1)";
            $strings[$i] = $ts[$i].".x" . dec2bin($t{$ts_original[$i]}, $metabolitesn{$ts[$i]})."\'";
            $cs[$i] = $ts[$i]."#".$t{$ts_original[$i]};
            <>;
          }
          else{
            my $tindex = $t{$ts_original[$i]};
            #$strings[$i] = "x".level($tindex)."(".getindex($ts[$i], $tindex).")";
            my $tn = $metabolitesn{$ts[$i]};
            my $tname = $ts[$i].'#'. dec2bin($tindex,$tn);
            $strings[$i] = "x".level($tindex)."(".$emus[level($tindex)]->{$tname}.",:)";
            unless ($emus[level($tindex)]->{$tname }){
              print $tname, " $tn\n";
              <>;
            }
            $cs[$i] = $ts[$i]."#".dec2bin($tindex, $tn)."($tindex)";
            
          }
        }
        #print OUT "B$n($rowindex) = B$n($rowindex) + $string1 * $string2 * " .($pcoefficient ==1?"":"$pcoefficient*"). "v($rxnindex); % source2:$source:$c1:$c2\n";
        print OUT "B$n($rowindex,:) = B$n($rowindex,:) + conv(".(join ", ", @strings).") * " .($pcoefficient ==1?"":"$pcoefficient*"). "v($rxnindex); % source2:$source:".(join ":", @cs)."\n";
      }
      else{
        die "whoops";
      }
    }
  }
  print OUT "x$n = solveLin(A$n, B$n);  \n";
  #print OUT "sum(x$n,2)\n";
  #print OUT "pause;";
}

print OUT "\n\n";

print OUT '% Assign outputs'."\n";

#foreach my $met(@metabolites){
foreach my $met(sort keys %outputs){
  my $metname = $met;
  $metname =~ s/#.*//;
  my $metlabel = $met;
  $metlabel =~ s/.*#//;
  my $n = $metlabel;
  $n =~ s/0//g;
  $n = length($n);
  my $c = "x$n(".$emus[$n]->{$met}.",:)";
  
  my @mets = ($met);
  while(grep {$not_needed{$_}} @mets){
    my @fixmets = grep {$not_needed{$_}} @mets;
    my @okmets = grep {!$not_needed{$_}} @mets;
    my @outmets = ();
    foreach my $xyz (@fixmets){
      print $xyz, "<<\n";
      push @outmets, @{$not_needed{$xyz}};
    }
    @mets = (@outmets, @okmets);
  }
  if(scalar @mets == 1){
    $c = "x$n(".$emus[$n]->{$mets[0]}.",:)";
  }
  elsif(scalar @mets == 2){
    my $l1 = $mets[0];
    my $l2 = $mets[1];
    $l1 =~ s/.*#//;
    $l2 =~ s/.*#//;
    $l1 =~ s/0//;
    $l2 =~ s/0//;
    my $n1 = length($l1);
    my $n2 = length($l2);
    print $mets[1], "n = $n2 $l2 XYZ\n";
    $c = "conv("."x$n1(".$emus[$n1]->{$mets[0]}.",:),x$n2(".$emus[$n2]->{$mets[1]}.",:)"   . ")";
  }
  else{
    die "shoot.  gotta deal with case 3";
  }
  
  print "output $met\n";
  print OUT "output.$metname$metlabel = $c';\n";
}

close(OUT);
print "done\n";
exit;




# calculates the size of the number of cumomers of size n
#sub sizen{
#  my $level = shift;
#  my $sum = 0;
#  foreach my $met (@metabolites){
#    my $n = $metabolitesn{$met};
#    $sum += comb($n, $level) if $level <= $n;
#  }
#  return $sum;
#}
   
   
sub sizen{
  my $n = shift;
  my $maxt = 0;
  foreach my $key (values %{$emus[$n]}){
    $maxt = $key if $key > $maxt;
  }
  return $maxt;
}
sub chooselargest{
  my $t = shift;
  my @t2 = reverse sort {sizeof($b) <=> sizeof($a)} keys %$t;
  return $t2[0];
}

sub sizeof{
  my $met = shift;
  my @parts = split /#/, $met;
  my $mets2 = $parts[1];
  die unless $mets2;
  $mets2 =~ s/0//g;
  return length($mets2);
}

#sub getindex{
#  my $name = shift; #name of metabolite
#  my $num = shift; #number of the cumomer.
#  #my $a = shift;
#  my $level = level($num);
#  
#  die if $known{$name};
#  
#  my $sum = 0;
#  #my $absolute = 0;
#  foreach my $met (@metabolites){
#    my $n  = 0;
#    $n = $metabolitesn{$met};
#    last if($met eq $name);
#    $sum += comb($n, $level) if $level <= $n;
#  }
#  foreach (0 .. $num -1){
#    $sum++ if level($_) == $level;
#  }
#  return $sum + 1;
#}

sub level{ # counts the number of 1's in a binary representation of a number.
  my $t = shift;
  if ($lv[$t]){
    return $lv[$t];
  }
  my $toriginal = $t;
  my $level = 0;
  while ($t >= 1){
    $level++ if $t % 2 == 1;
    $t = int ((int $t) /2);
  }
  $lv[$toriginal] = $level;
  return $level;
}
  
sub comb { # combinations of n choose m
  my $n = shift;
  my $m = shift;
  return factorial($n)/(factorial($m)*factorial($n-$m));
}
  
sub factorial{ #factorial...
  my $n = shift;
  my $retval = 1;
  foreach (2 .. $n){
    $retval *= $_;
  }
  return $retval;
}

sub sourcedrain{ # takes lots of inputs and fills %source and %drain
  my $name = shift; # reaction name
  my $reactants = shift;
  my $products = shift;
  my $preactants = shift;
  my $pproducts = shift;
  my $creactants = shift;
  my $cproducts = shift;
  
  my @reactants = @$reactants;
  my @products = @$products;
  my @pproducts = @$pproducts;
  my @preactants = @$preactants;
  my @creactants = @$creactants;
  my @cproducts = @$cproducts;
  
  for(my $i = 0; $i<@reactants; $i++){
    $drain{$reactants[$i]}->{$name} += $creactants[$i];
  }
  for(my $k = 0; $k< @products; $k++){
    my $product = $products[$k];
    my $iss = $pproducts[$k];
    my @issparts = split //, $iss;
    my $t = shift @issparts;
    die unless $t eq '#'; #just checking...
    for(my $pos = 0; $pos<@issparts; $pos++){
      my $letter = $issparts[$pos];
      my $found = 0;
      for(my $m = 0; $m< @reactants; $m++){
        if($preactants[$m] =~ /${letter}/){
          $source{$product}->{$name}->[$pos] = [$reactants[$m]."_$m", length($`)-1, $cproducts[$k]];
          $found = 1;
        }
      }
      if(! $found){
        die("cannot find source of letter $letter in product $product in reaction $name");
      }
    }
  }
}

sub dec2bin{ # decimal to binary conversion.  
  my $num = shift;
  my $n = shift || 0; # pad to...
  my $mask = shift; # 0's with x's
  return (wantarray?():0) if $num == 0;
  my @retval = ();
  my $i = 0;
  while($num > 1){
    $retval[$i] = ($num % 2);
    $num = int($num/2);
    $i++;
  }
  $retval[$i] = 1;
  for(my $j = $i+1; $j<$n; $j++){
    $retval[$j] = '0';
  }
  return wantarray ?@retval: (join '', @retval);
}

sub checkmetabolites{
  foreach my $met (@metabolites){
    if (! $met){
      print "whoops";
      die;
    }
  }

}

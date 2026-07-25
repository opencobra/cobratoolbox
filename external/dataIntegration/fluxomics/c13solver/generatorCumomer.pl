#!perl

use strict;
open(IN, "IsotopomerModel.txt") or die;
my $outfile = "slvrCumomer";

my @lv = (); # hash for memoizing levels.

#my %known =  ( 'xglcDe'=>1 ); #, 'A' =>1);
my $known = <IN>;
chomp $known;
my %known = ($known => 1); #, 'A' =>1);

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
  #my $reversible;
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
  $outputs{$met} = $metabolites{$met};
}

if (scalar %outputs ==0){
  print "outputs file not found.  assuming everything is output\n";
  %outputs = %metabolites;
}
else{
  print "output file found";
}
######################################
############### done reading in. #####
######################################
print "done reading\n";

checkmetabolites();

#print "@reactions\n";

# xn (x1, x2, x3 ... xn)
# An (A1, A2, A3 ...
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
foreach my $met (keys %metabolitesn){
  $maxlevel = $metabolitesn{$met} if $metabolitesn{$met} > $maxlevel;
}

for(my $n = 1; $n <= $maxlevel; $n++){ # for each level loop
  print ">>>>>>>>>>>>>>>>>>>> level $n <<<<<<<<<<<<<<<\n";
  print OUT "\n% level: $n\n";
  my $sizen = sizen($n);
  print OUT "A$n = sparse($sizen, $sizen);\n";
  print OUT "B$n = zeros($sizen, 1);\n";
  foreach my $met(@metabolites){  # for each metabolite loop
    print "$met \n";
    foreach my $index (0 .. (2**$metabolitesn{$met}-1))  {  # for each cumomer at this level
      next unless (level($index) == $n); # ignore if not correct level.
      #print "$met: $index\n";
      print OUT "%>>> $met#". dec2bin($index, $metabolitesn{$met})."($index)\n";
      my $rowindex = getindex($met, $index); # get the row index.
      ############### drains ######################
      print OUT "A$n($rowindex, $rowindex) = ";
      my $commentstring = '';
      my $first = 1;
      if (scalar keys %{$drain{$met}} == 0){
        print "warning:  $met has no drains.  No way to balance.";
        <>;
      }
      foreach my $drain (keys %{$drain{$met}} ){  # go through all the drains.
        print OUT " + " unless $first;
        $first = 0;
        print OUT $drain{$met}->{$drain}, "*" if $drain{$met}->{$drain} != 1; # coefficient multiplier if needed.
        print OUT "v(", $reactions{$drain} ,")";
        $commentstring .= ":$drain";
      }
      print OUT "; % drain $commentstring \n";
      
      ################# sources ###################
      my @label = dec2bin($index, $metabolitesn{$met}); # label of balanced compound.
      foreach my $source (keys %{$source{$met}} ){  # for each source (reactions)
        my $pcoefficient = 1;
        my @array = @{$source{$met}->{$source}}; #store info.
        if (scalar @array != $metabolitesn{$met}){ #sanity check.  Each Carbon must come from somewhere.
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
        my $rxnindex = $reactions{$source};
        if(scalar keys %t == 1){ # metabolites comes from a single source.  It's either known or unknown.
          my $t = join '', keys %t; # the only metabolite...
          my $tindex = $t{$t};
          $t = substr($t, 0, length($t)-2);
          die unless level($tindex) == level($index);
          my $indexbin = dec2bin($tindex, $metabolitesn{$t}); # for display purposes
          if (! $known{$t}){ # if unknown
            my $metindex = getindex($t, $tindex);
            print OUT "A$n($rowindex, $metindex) = A$n($rowindex, $metindex) - " .($pcoefficient == 1?"":"$pcoefficient*"). "v($rxnindex); % source1:$source:$t#$indexbin($tindex)\n";
          }
          else{ # if known...0
            print OUT "B$n($rowindex) = B$n($rowindex) + " .($pcoefficient ==1?"":"$pcoefficient*"). "$t($tindex+1) * v($rxnindex); % source1:$source:$t#$indexbin($tindex)\n";
          }
        }
        elsif(scalar keys %t >= 2){ # More than one source.  Each fragment has size < n and is therefore known.
          my @ts_original = keys %t;
          my @ts = map {substr($_, 0, length($_)-2)} @ts_original;
          
          my @strings = map {''} @ts;
          my @cs = map {''} @ts;
          
          for(my $i = 0; $i< @ts; $i++){
            if($known{$ts[$i]}){
              $strings[$i] = $ts[$i]."(".$t{$ts_original[$i]}."+1)";
              $cs[$i] = $ts[$i]."#".$t{$ts_original[$i]};
            }
            else{
              my $tindex = $t{$ts_original[$i]};
              $strings[$i] = "x".level($tindex)."(".getindex($ts[$i], $tindex).")";
              $cs[$i] = $ts[$i]."#".dec2bin($tindex, $metabolitesn{$ts[$i]})."($tindex)";
            }
          }
          #print OUT "B$n($rowindex) = B$n($rowindex) + $string1 * $string2 * " .($pcoefficient ==1?"":"$pcoefficient*"). "v($rxnindex); % source2:$source:$c1:$c2\n";
          print OUT "B$n($rowindex) = B$n($rowindex) + ".(join " * ", @strings)." * " .($pcoefficient ==1?"":"$pcoefficient*"). "v($rxnindex); % source2:$source:".(join ":", @cs)."\n";
        }
        else{
          die "whoops";
        }
      }
    }
  }
  #print OUT "x$n = A$n\\B$n;  \n"; # yay.  performing actual computation.
  print OUT "x$n = solveLin(A$n, B$n);  \n";
  #print OUT "[x$n, flag] = pcg(A$n,B$n, 10e-7, 2000 );  \n";
  #print OUT "if flag ~= 0 \n flag \n pause; \n end \n ";
}

print OUT "\n\n";

print OUT '% Assign isotopomers'."\n";

#foreach my $met(@metabolites){
foreach my $met(sort keys %outputs){
  my $n = $metabolitesn{$met};
  print OUT "$met = zeros(".(2**$n).",1);\n";
  foreach my $index (0 .. (2**($n)-1) ){
    my $level = level($index);
    my $metindex = getindex($met, $index);
    if($level != 0){
      print OUT "$met($index+1,1) = x$level($metindex);\n";
    }else{
      print OUT "$met($index+1,1) = 1;\n";
    }
  }
  #print OUT "$met\n";
  print "cumomer2isomer $met\n";
  print OUT "output.$met = cdv2idv($n) * $met;\n\n";
  print OUT "output.$met;\n";
}
for(my $i = 1; $i<=$maxlevel; $i++){
  #print OUT "cond(full(A$i))\n"; 
  #print OUT "det(full(A$i))\n";
}

#print OUT "mins = [];\n";
#foreach my $met(@metabolites){
#  print OUT "mins = [mins min($met)];\n";
#}
#print OUT "mins\n";
#print OUT "min(mins)\n";

close(OUT);
print "done\n";
exit;




# calculates the size of the number of cumomers of size n
sub sizen{
  my $level = shift;
  my $sum = 0;
  foreach my $met (@metabolites){
    my $n = $metabolitesn{$met};
    $sum += comb($n, $level) if $level <= $n;
  }
  return $sum;
}
  
sub getindex{
  my $name = shift; #name of metabolite
  my $num = shift; #number of the cumomer.
  #my $a = shift;
  my $level = level($num);
  
  die if $known{$name};
  
  my $sum = 0;
  #my $absolute = 0;
  foreach my $met (@metabolites){
    my $n  = 0;
    $n = $metabolitesn{$met};
    last if($met eq $name);
    $sum += comb($n, $level) if $level <= $n;
  }
  foreach (0 .. $num -1){
    $sum++ if level($_) == $level;
  }
  return $sum + 1;
}

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

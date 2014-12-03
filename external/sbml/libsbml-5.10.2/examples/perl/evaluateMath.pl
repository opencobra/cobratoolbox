#!/usr/bin/env perl
# -*-Perl-*-
##
## \file    evaluateMath.pl
## \brief   Evaluates infix expressions
## \author  TBI {xtof,raim}@tbi.univie.ac.at
##

##
## Copyright 2005 TBI
##
## This library is free software; you can redistribute it and/or modify it
## under the terms of the GNU Lesser General Public License as published
## by the Free Software Foundation; either version 2.1 of the License, or
## any later version.
##
## This library is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
## MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
## documentation provided hereunder is on an "as is" basis, and the
## California Institute of Technology and Japan Science and Technology
## Corporation have no obligations to provide maintenance, support,
## updates, enhancements or modifications.  In no event shall the
## California Institute of Technology or the Japan Science and Technology
## Corporation be liable to any party for direct, indirect, special,
## incidental or consequential damages, including lost profits, arising
## out of the use of this software and its documentation, even if the
## California Institute of Technology and/or Japan Science and Technology
## Corporation have been advised of the possibility of such damage.  See
## the GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this library; if not, write to the Free Software Foundation,
## Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
##
## The original code contained here was initially developed by:
##
##     Christoph Flamm and Rainer Machne
##     Institut fuer Theoretische Chemie
##     Universitaet Wien
##     Waehringerstrasse 17/3/308
##     A-1090 Wien, Austria

use Benchmark qw/:hireswallclock/;
use Math::Trig;
use POSIX;
use blib '../../src/bindings/perl';
use LibSBML;
use strict;
use vars qw/$ACTIONS $TU/;

# read action table from internal filehandle
$ACTIONS = {util_getTable()}; warn $@ if $@;

# main loop
for (;;) {
  print "Enter infix formula (Empty line to quit):\n\n> ";
  my $t0        = new Benchmark;  
  my $ast       = LibSBML::parseFormula(util_trim($_=<>)) || last;
  my $result    = evalAST($ast);
  my $t1        = new Benchmark;
  (my $ellapsed = timestr(timediff($t1, $t0), 'nop')) =~ s/\A([\d\.]+)/$1/;

  printf
      "\n%s\n= %.10g\n\nevaluation time: %lu ms\n\n",
      LibSBML::formulaToString($ast),
      $result,
      $ellapsed;
}

#---
sub evalAST {
  my  $astnode = shift
      || do {warn "empty AST node", return};
  $ACTIONS->{$astnode->getType()}->($astnode);
}

#---
sub util_getTable {
  local $/; undef $/; # enable slurp mode
  eval <DATA>;
}

#---
sub util_getValue {
  printf
      "Please enter a nummeric value for the variable %s: ", $_[0]->getName();
  return util_trim(local $_ = <>);
}

#---
sub util_trim {
  local $_ = shift;
  s/^\s+//; s/\s+$//; chomp();
  return $_;
}

#---
BEGIN {
  $main::TU = 'ms';
  eval "use Time::HiRes";
  warn "\nModule Time::HiRes not installed.\n"
      . "Time granularity will be integer seconds not milliseconds!\n" if $@;
   $main::TU = ' s' if $@;
}

__DATA__
  # numeric values
$LibSBML::AST_INTEGER          => sub { $_[0]->getInteger() },
$LibSBML::AST_REAL             => sub { $_[0]->getReal() },
$LibSBML::AST_REAL_E           => sub { $_[0]->getReal() },
$LibSBML::AST_NAME             => sub { util_getValue($_[0]) },
$LibSBML::AST_FUNCTION_DELAY   => sub { return evalAST($_[0]->getChild())
					      if $_[0]->getNumChildren() > 1;
					  return 0 },
$LibSBML::AST_NAME_TIME        => sub { 0 },
# constants
$LibSBML::AST_CONSTANT_E       => sub { exp(1) },
$LibSBML::AST_CONSTANT_FALSE   => sub { 0 },
$LibSBML::AST_CONSTANT_PI      => sub { pi() }, # 4 * atan2(1, 1)
$LibSBML::AST_CONSTANT_TRUE    => sub { 1 },
# arithmetic operators
$LibSBML::AST_PLUS             => sub { evalAST($_[0]->getChild(0))
					      + evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_MINUS            => sub { return -evalAST($_[0]->getChild(0))
					      if $_[0]->getNumChildren() == 1;
					  return evalAST($_[0]->getChild(0))
					      - evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_TIMES            => sub { evalAST($_[0]->getChild(0))
					      * evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_DIVIDE           => sub { evalAST($_[0]->getChild(0))
					      / evalAST($_[0]->getChild(1));
					},

$LibSBML::AST_LAMBDA           => sub { 0 }, # not yet implemented
$LibSBML::AST_FUNCTION         => sub { return evalAST($_[0]->getChild(0))
					      if $_[0]->getNumChildren()== 1;
					  return 0 },
# functions
$LibSBML::AST_FUNCTION_ABS     => sub { abs(evalAST($_[0]->getChild(0)))  },
$LibSBML::AST_FUNCTION_CEILING => sub { ceil(evalAST($_[0]->getChild(0))) },
$LibSBML::AST_FUNCTION_EXP     => sub { exp(evalAST($_[0]->getChild(0))) },
$LibSBML::AST_FUNCTION_FACTORIAL => sub { my ($r, $i);
					    $r = 1;
					    $i = evalAST($_[0]->getChild(0));
					    $r *= $_ for 2..floor($i);
					  },
$LibSBML::AST_FUNCTION_LN      => sub { log(evalAST($_[0]->getChild(0))) },
$LibSBML::AST_FUNCTION_LOG     => sub { log(evalAST($_[0]->getChild(0)))
					      / log(10);
					},
$LibSBML::AST_FUNCTION_PIECEWISE => sub { 0 }, # not yet implemented
$LibSBML::AST_POWER            => sub { evalAST($_[0]->getChild(0))
                                            ** evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_FUNCTION_ROOT    => sub { evalAST($_[1]->getChild()) **
					      (1./evalAST($_[0]->getChild(0)));
					},
# trigonometric functions
$LibSBML::AST_FUNCTION_ARCCOS  => sub {   acos(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCCOSH => sub {  acosh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCCOT  => sub { acotan(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCCOTH => sub {acotanh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCCSC  => sub {   acsc(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCSEC  => sub {   asec(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCSECH => sub {  asech(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCSIN  => sub {   asin(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCSINH => sub {  asinh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCTAN  => sub {   atan(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_ARCTANH => sub {  atanh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_COS     => sub {    cos(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_COSH    => sub {   cosh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_COT     => sub {    cot(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_COTH    => sub { cotanh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_CSC     => sub {    csc(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_CSCH    => sub {   csch(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_SEC     => sub {    sec(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_SECH    => sub {   sech(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_SIN     => sub {    sin(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_SINH    => sub {   sinh(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_TAN     => sub {    tan(evalAST($_[0]->getChild(0)))},
$LibSBML::AST_FUNCTION_TANH    => sub {   tanh(evalAST($_[0]->getChild(0)))},
# logical operators
$LibSBML::AST_LOGICAL_AND      => sub { evalAST($_[0]->getChild(0))
					      && evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_LOGICAL_NOT      => sub { !evalAST($_[0]->getChild(0)) },
$LibSBML::AST_LOGICAL_OR       => sub { evalAST($_[0]->getChild(0))
					      || evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_LOGICAL_XOR      => sub { !(evalAST($_[0]->getChild(0))  &&
					    evalAST($_[0]->getChild(1))) ||
					    (evalAST($_[0]->getChild(0)) &&
					     !evalAST($_[0]->getChild(1)));
					},
# relational operators
$LibSBML::AST_RELATIONAL_EQ    => sub { evalAST($_[0]->getChild(0))
					      == evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_RELATIONAL_GEQ   => sub { evalAST($_[0]->getChild(0))
					      >= evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_RELATIONAL_GT    => sub { evalAST($_[0]->getChild(0))
					      > evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_RELATIONAL_LEQ   => sub { evalAST($_[0]->getChild(0))
					      <= evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_RELATIONAL_LT    => sub { evalAST($_[0]->getChild(0))
					      < evalAST($_[0]->getChild(1));
					},
$LibSBML::AST_UNKNOWN          => sub { 0 }, # default case

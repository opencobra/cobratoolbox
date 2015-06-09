# This is the makefile to create the mex-function for lu1fac
# from file lu1fac.c, mi27lu.f, mi15blas.f and sort.c.

# The matlab directory
MATLAB =/home/rfleming/bin/matlab08a/
# The matlab include file directory
INCLUDE = ${MATLAB}/extern/include

# The libraries
LIBS =-lmx -lmex -lmat -lm -lgfortran -lstdc++
G77=gfortran
#G77=g77
# The compile options
#OPTIONS  = -g -O
#F77OPTS  = -g -c -O -64 -i4
OPTIONS  = -O
#F77OPTS  = -c -O -64 -i4
F77OPTS  = -c -O -i4

# Clear suffix list, then define the ones we want
.SUFFIXES:
.SUFFIXES: .c .f .f90 .o

.f90.o:; ${FC} ${FFLAGS} -c -o $@ $<
.f.o:;   ${FC} ${FFLAGS} -c -o $@ $<
.c.o:;   $(CC) $(CFLAGS) -c -o $@ $<

#lu1fac.mexsg : lu1fac.c mi27lu.o mi15blas.o sort.c
#	mex $(OPTIONS)  -L/usr/lib/gcc/i586-suse-linux/4.2.1/ -lg2c lu1fac.c -I$(INCLUDE) mi27lu.o mi15blas.o sort.c $(LIBS)

lu1fac.mexglx : lu1fac.c mi27lu.o mi15blas.o sort.c
	mex $(OPTIONS)  -L/usr/lib/gcc/i486-linux-gnu/4.3/ -lg2c lu1fac.c -I$(INCLUDE) mi27lu.o mi15blas.o sort.c $(LIBS)

mi27lu.o : mi27lu.f
	${G77} $(F77OPTS) -o mi27lu.o mi27lu.f

mi15blas.o : mi15blas.f
	${G77} $(F77OPTS) -o mi15blas.o mi15blas.f

#ZIP : 
#	\rm -f lusolMex.zip
#	zip    lusolMex.zip \
#	   README makefile mi15blas.f mi27lu.f \
#	   nrutil.h lu1fac.c sort.c \
#	   lusolFactor.m luSOL.m lusolSet.m lusolTest.m \
#	   illc1033.mat
#	ls -lFh    --color=auto --time-style=locale *.zip


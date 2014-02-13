              Optimized GotoBLAS libraries

                       By Kazushige Goto <kgoto@tacc.utexas.edu>

0. License

   See 00TACC_Research_License.txt.

1. Supported OS

     Linux
     FreeBSD(Also it may work on NetBSD)
     OSX
     Soralis
     Windows 2k, XP, Server 2003(both 32bit and 64bit)
     AIX
     Tru64 UNIX

2. Supported Architecture

    X86  : Pentium3 Katmai
                    Coppermine
           Athlon  (not well optimized, though)
           PentiumM Banias, Yonah
           Pentium4 Northwood
                    Nocona (Prescott)
	   Core 2   Woodcrest
	   Core 2   Penryn
           Opteron
	   Barlcelona(Quad Core Opteron)

   X86_64: Pentium4 Nocona
	   Core 2   Woodcrest
	   Core 2   Penryn
           Opteron
	   Barlcelona(Quad Core Opteron)

   IA64  : Itanium2

   Alpha : EV4, EV5, EV6

   POWER : POWER4
           PPC970/PPC970FX
           PPC970MP
	   CELL (PPU only)
           POWER5
           PPC440   (QCDOC)
           PPC440FP2(BG/L)
	   POWERPC G4(PPC7450)

   SPARC : SPARC IV

3. Supported compiler

   C compiler       : GNU CC (Intel compiler may also work)
                      If you want Windows 2K/XP version, you need
                      Cygwin(http://www.cygwin.com/) to compile it.

   Fortran Compiler : GNU G77, G95, GFORTRAN
                      Compaq
                      F2C
                      IBM
                      Intel
                      PathScale
                      PGI
                      SUN

4. Suported precision

 Now x86/x86_64 version support 80bit FP precision in addition to
normal double presicion and single precision. Currently only 
gfortran supports 80bit FP with "REAL*10".


5. How to build library?

 Please see 02QuickInstall.txt.

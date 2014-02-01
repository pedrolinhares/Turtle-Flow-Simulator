//** @file CSolver.cpp */

#include "CSolver.h" 

CSolver::CSolver(int nl) : nlines(nl)   {
      /// Solver constructor.
      
      maxiter = 50; ///< Default number for maximum iterations;
      erro= 0.000001; ///< Default number for maximum error.
      
                  
}

CSolver::CSolver(int nl, int _maxiter, double _erro) : nlines(nl), 
 maxiter(_maxiter) , erro(_erro) {} /// Overloaded Solver constructor.

CSolver::~CSolver()
{
	/// Solver destructor.
}

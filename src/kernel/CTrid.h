//** @file CTrid.h */

#ifndef CTrid_h
#define CTrid_h

#include <iostream>
#include "CSolver.h" 
#include <cmath>

/*
 * This class represents the solver for tri-diagonal matrices.
 */
 
class CTrid : public CSolver
{
    private:
        
        double *verror; ///< Array used to store the error calculated in each line of the equation system.
          
	public:
		
		CTrid(int nl); ///< Solver constructor;
		CTrid(int nl, int _maxiter, double _erro); ///< Overloaded Solver constructor;
		~CTrid(); ///< Solver destructor;
		
		virtual void GaussSeidel( double **a , double *b ,double *x); ///< Gauss-Seidel algorithm.
};

#endif // CTrid_h

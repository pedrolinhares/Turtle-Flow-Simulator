//** @file CSolver.h */

#ifndef CSolver_h
#define CSolver_h

/**
 * This class is an abstract class used to represent the numerical solver.
 * The solver can be used to solve tri-diagonal, penta-diagonal or hepta-diagonal systems.
 * Can be implemented different kinds of numerical algorithims for each solver.
 */
 
class CSolver
{
    protected:
    	
        int nlines; ///< Number of lines in the linear equation system;
        int maxiter; ///< Maximum number of iterations;
        double erro; ///< Maximum error of solver.
        
	public:
		
		CSolver(int nl); ///< Solver constructor;
		CSolver(int nl, int _maxiter, double _erro); ///< Overloaded Solver constructor;
		virtual ~CSolver(); ///< Solver destructor;
		
		virtual void GaussSeidel( double **a , double *b ,double *x) = 0; ///< Gauss-Seidel algorithm.
		
};

#endif // CSolver_h

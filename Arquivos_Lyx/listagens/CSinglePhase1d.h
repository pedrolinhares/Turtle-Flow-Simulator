//** @file CSinglePhase1d.h */

#ifndef CSinglePhase1d_h
#define CSinglePhase1d_h

#include "CSinglePhase.h"

/**
 * This class represents the one-dimensional single phase model.
 * A reservoir model is used to discretize differential equations, and to create a linear equations system.
 */

class CSinglePhase1d : public CSinglePhase
{
	protected:
		
		int cpoints; ///< Number of cells in the reservoir. It is the same number of the linear equation system lines.
		
	public:
		
		CSinglePhase1d(int _cpoints); ///< Single Phase 1d constructor;
		~CSinglePhase1d(); ///< Single Phase 1d destructor;
		
		virtual void BuildMatrix(CGrid *grid, double **A, double deltat); ///< Builds the coefficient matrix "A"; 
		virtual void BuildCoefVector(CGrid *grid, double *b, double deltat); ///< Builds the free vector "b";
		virtual void BuildSolution(CGrid *grid, double *x);	///< Builds the solution "X"; 
		virtual double Gamma( CGrid *grid, int i); ///< Calculates the Gamma factor of the reservoir.	
	
};

#endif //CSinglePhase1d_h

//** @file CSinglePhase.h */

#ifndef CSinglePhase_h
#define CSinglePhase_h

#include "CModelType.h"

/**
 * This class is an abstract class used to represent all single phase reservoir models.
 * The reservoir model is used to discretize differential equations, and to create a linear equations system.
 */

class CSinglePhase : public CModelType
{
	protected:
		
	public:
		
		CSinglePhase(); ///< Single phase constructor;
		virtual ~CSinglePhase(); ///< Single phase destructor;
		
		virtual void BuildMatrix(CGrid *grid, double **A, double deltat) = 0; ///< Builds the coefficient matrix "A"; 
		virtual void BuildCoefVector(CGrid *grid, double *b, double deltat) = 0; ///< Builds the free vector "b";
		virtual void BuildSolution(CGrid *grid, double *x) = 0;  ///< Builds the solution "X";
		virtual double Gamma( CGrid *grid, int i) = 0;	 ///< Calculates the Gamma factor of the reservoir.		
	
};

#endif // CSinglePhase_h

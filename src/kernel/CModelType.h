//** @file CModelType.h */

#ifndef CModelType_h
#define CModelType_h

#include <iostream>

#include "CGrid.h"
#include "CGrid1d.h"

/**
 * This class is an abstract class used to represent a reservoir model.
 * The reservoir model is used to discretize differential equations, and to create a linear equations system.
 */

class CModelType
{
	protected:
		CDataControl *dcontrol; ///< Pointer to the simulation data;
		
	public:
		CModelType(); ///< Model constructor;
		virtual ~CModelType(); ///< Model destructor;
		
		virtual void BuildMatrix(CGrid *grid, double **A, double deltat) = 0; ///< Builds the coefficient matrix "A"; 
		virtual void BuildCoefVector(CGrid *grid, double *b, double deltat) = 0; ///< Builds the free vector "b";
		virtual void BuildSolution(CGrid *grid, double *x) = 0; ///< Builds the solution "X";
		virtual double Gamma( CGrid *grid, int i) = 0;	///< Calculates the Gamma factor of the reservoir.	
};

#endif // CModelType_h

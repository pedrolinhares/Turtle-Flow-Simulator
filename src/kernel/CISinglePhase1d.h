//** @file CISinglePhase1d.h */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz Barros.
 *
 *  TFS is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  TFS is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TFS.  If not, see <http://www.gnu.org/licenses/>.
 *****************************************************************************/

#ifndef CISinglePhase1d_h
#define CISinglePhase1d_h

#include "CResModelType.h"

/**
 * CISinglePhase (Class Implicit Single Phase)
 * This class represents the one-dimensional single phase model, using the implicit discretization.
 * A reservoir model is used to discretize differential equations, and to create a linear equations system.
 */

class CISinglePhase1d : public CResModelType
{
	protected:
				
  		int cpoints; ///< Number of cells in the reservoir. It is the same number of the linear equation system lines;
  		int elem_numb; ///< Number of non-zeros elements in matrix A;
	 	int maxni; ///< Max number of iterations in linearization;
  		double erroni; ///< Precision of linearization.

		/// The solver will be called to solve the linear system:
		/// A' * Xni = b, Where A' = f(Acol, Arow, Aval)	
		double *b; ///< Free Vector;
  		double *Xni; ///< Solution Vector;
		
		/// The A matrix must be constructed using three arrays of data. More details are described in UMFPack user-guide.
		int *Acol; ///< Column index for all non-zero elements in matrix A;
		int *Arow; ///< Cumulative Row sum for the number of non-zeros elements;
		double *Aval; ///< Value for all non-zero elements in matrix A.
		
		
	public:

		CISinglePhase1d(CGrid *grid, int _maxni, double _erroni); ///< Single Phase 1d Constructor; 
		virtual ~CISinglePhase1d(); ///< Single Phase 1d destructor;	
		
		/// Model Functions ///		
		int MatrixElementsNumber(CGrid *grid); ///< Returns the number of elements that will be created in matrix A;
		virtual void Iterationt(CGrid *grid, CSolverMatrix *solver, double deltat); ///< Makes a time iteration for the problem;
		void BuildJacobian(CGrid *grid, double deltat); ///< Builds the Jacobian matrix "A";
		void BuildCoefVector(CGrid *grid, double deltat); ///< Builds the free vector "b";
		virtual void BuildInitialSolution(CGrid *grid);	///< Builds the solution "X";
		virtual void Print(); ///< This function prints on screen all the matrix. It is used to debug the code.
		
		/// Implicit Residual Functions ///
		double CellResidual(CGrid *grid, double deltat, int celln); ///< Returns the residual for the cell n in domain;
		double RHSTerm(CGrid *grid, double deltat, int celln); ///< Returns the Qi term used for calculate the residual for cell n;
		double LeftResDer(int celln); ///< Returns the left residual derivative for cell n;
		double CentralResDer(int celln); ///< Returns the central residual derivative for cell n;
		double RightResDer(int celln); ///< Returns the right residual derivative for cell n.

};

#endif //CSinglePhase1d_h

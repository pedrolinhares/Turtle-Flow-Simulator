//** @file CSinglePhase1d.h */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz.
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

#ifndef CSISinglePhase1d_h
#define CSISinglePhase1d_h

#include "CResModelType.h"

/**
 * CSISinglePhase (Class Semi-Implicit Single Phase)
 * This class represents the one-dimensional single phase model, using the semi-implicit discretization.
 * A reservoir model is used to discretize differential equations, and to create a linear equations system.
 */

class CSISinglePhase1d : public CResModelType
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

		CSISinglePhase1d(CGrid *grid, int _maxni, double _erroni); ///< Single Phase 1d Constructor; 
		virtual ~CSISinglePhase1d(); ///< Single Phase 1d destructor;	
		
		/// Model Functions ///		
		int MatrixElementsNumber(CGrid *grid); ///< Returns the number of elements that will be created in matrix A;
		virtual void Iterationt(CGrid *grid, CSolverMatrix *solver, double deltat); ///< Makes a time iteration for the problem;
		void BuildMatrix(CGrid *grid, double deltat); ///< Builds the coefficient matrix "A";
		void BuildCoefVector(CGrid *grid, double deltat); ///< Builds the free vector "b";
		virtual void BuildInitialSolution(CGrid *grid);	///< Builds the solution "X";
		virtual void Print(); ///< This function prints on screen all the matrix. It is used to debug the code.

};

#endif //CSinglePhase1d_h

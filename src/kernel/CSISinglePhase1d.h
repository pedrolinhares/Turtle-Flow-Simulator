//** @file CSinglePhase1d.h */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz Barros.
 *  
 *  Class Author: Wagner Queiroz Barros.
 *  Last Update: 08/04/2014
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
#include "CGrid1d1p.h"
#include "CSolverMatrix.h"

/**
 * CSISinglePhase (Class Semi-Implicit Single Phase)
 * This class represents the one-dimensional single phase model, using the semi-implicit discretization.
 * A reservoir model is used to discretize differential equations, and to create a linear equations system.
 */

class CSISinglePhase1d : public CResModelType
{
	protected:
						
		CGrid1d1p *grid;
		CSolverMatrix *solver;
		
	public:

		CSISinglePhase1d(CGrid1d1p *_grid, CSolverMatrix *_solver, int _maxni, double _erroni); ///< Single Phase 1d Constructor; 
		virtual ~CSISinglePhase1d(); ///< Single Phase 1d destructor;	
		
		/// Model Functions ///		
		int MatrixElementsNumber(); ///< Returns the number of elements that will be created in matrix A;
		void Iterationt(double deltat); ///< Makes a time iteration for the problem;
		void BuildMatrix(double deltat); ///< Builds the coefficient matrix "A";
		void BuildCoefVector(double deltat); ///< Builds the free vector "b";
		void BuildInitialSolution();	///< Builds the solution "X";
		void Print(); ///< This function prints on screen all the matrix. It is used to debug the code.

};

#endif //CSinglePhase1d_h

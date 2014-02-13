//** @file CSolverMatrix.h */
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

#ifndef CSolverMatrix_h
#define CSolverMatrix_h

#include "umfpack.h"

/**
 * This class is an abstract class used to represent the numerical solver.
 * The solver can be used to solve tri-diagonal, penta-diagonal or hepta-diagonal systems.
 * Can be implemented different kinds of numerical algorithims for each solver.
 */

class CSolverMatrix
{
    protected:
	

	public:

		CSolverMatrix(); ///< Solver constructor;
		~CSolverMatrix(); ///< Solver destructor;
		
		void UMFPack( int *Acol, int *Arow,	double *Aval, double *b, double *x, int n ); ///< Uses the UMFPack to solve the matrix system A'x=b;
		
};

#endif // CSolverMatrix_h

//** @file CSolverMatrix.cpp */
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

#include "CSolverMatrix.h"

CSolverMatrix::CSolverMatrix()  {
      /// Solver constructor.

}

CSolverMatrix::~CSolverMatrix()  {
	/// Solver destructor.
}

void CSolverMatrix::UMFPack( int *Acol, int *Arow,	double *Aval, double *b, double *x, int n )  {
	/// Uses the UMFPack to solve the matrix system A'x=b.
	/// This function returns the x vector with the correct solution of the problem.
	
	void *Symbolic, *Numeric;
	
	/// This function returns a Symbolic element if the matrix construction was successful
	umfpack_di_symbolic(n, n, Arow, Acol, Aval, &Symbolic, NULL, NULL);
	
	/// This function returns a Numeric element if the matrix factoration was successful
	umfpack_di_numeric(Arow, Acol, Aval, Symbolic, &Numeric, NULL, NULL);
	
	/// This function returns the x array with the solution af system A'x=b;
	umfpack_di_solve(UMFPACK_At, Arow, Acol, Aval, x, b, Numeric, NULL, NULL);
	
	/// This function deallocates the Symbolic object and sets the Symbolic pointer to NULL.
	umfpack_di_free_symbolic(&Symbolic);
	
	/// This function deallocates the Numeric object and sets the Numeric pointer to NULL.
	umfpack_di_free_numeric(&Numeric);
	
}


//** @file CSolMatTrid.h */
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

#ifndef CSolMatTrid_h
#define CSolMatTrid_h

#include <iostream>
#include "CSolverMatrix.h"
#include <cmath>

/*
 * This class represents the solver for tri-diagonal matrices.
 */

class CSolMatTrid : public CSolverMatrix
{
    private:

        double *verror; ///< Array used to store the error calculated in each line of the equation system.

	public:

		CSolMatTrid(int nl); ///< Solver constructor;
		CSolMatTrid(int nl, int _maxiter, double _erro); ///< Overloaded Solver constructor;
		~CSolMatTrid(); ///< Solver destructor;

		virtual void GaussSeidel( double **a , double *b ,double *x); ///< Gauss-Seidel algorithm.
};

#endif // CSolMatTrid_h

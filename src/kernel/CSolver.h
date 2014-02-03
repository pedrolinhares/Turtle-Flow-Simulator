//** @file CSolver.h */
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

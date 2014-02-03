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

CSolverMatrix::CSolverMatrix(int nl) : nlines(nl)   {
      /// Solver constructor.

      maxiter = 50; ///< Default number for maximum iterations;
      erro= 0.000001; ///< Default number for maximum error.


}

CSolverMatrix::CSolverMatrix(int nl, int _maxiter, double _erro) : nlines(nl),
 maxiter(_maxiter) , erro(_erro) {} /// Overloaded Solver constructor.

CSolverMatrix::~CSolverMatrix()
{
	/// Solver destructor.
}

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

		int cpoints; ///< Number of cells in the reservoir. It is the same number of the linear equation system lines.

	public:

		CSISinglePhase1d(int _cpoints); ///< Single Phase 1d constructor;
		~CSISinglePhase1d(); ///< Single Phase 1d destructor;

		virtual void BuildMatrix(CGrid *grid, double **A, double deltat); ///< Builds the coefficient matrix "A";
		virtual void BuildCoefVector(CGrid *grid, double *b, double deltat); ///< Builds the free vector "b";
		virtual void BuildSolution(CGrid *grid, double *x);	///< Builds the solution "X";
		virtual double Gamma( CGrid *grid, int i); ///< Calculates the Gamma factor of the reservoir.

};

#endif //CSinglePhase1d_h

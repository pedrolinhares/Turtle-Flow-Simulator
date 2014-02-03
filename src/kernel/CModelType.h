//** @file CModelType.h */
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

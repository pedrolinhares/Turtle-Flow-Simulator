//** @file CGrid.h */
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

#ifndef CGrid_h
#define CGrid_h

#include <string>
#include <iostream>
#include <fstream>
#include <iomanip>

#include "CBlock.h"
#include "CFluid.h"
#include "CWater.h"
#include "COil.h"
#include "CGas.h"
#include "CWell1d.h"

/**
 * This class is an abstract class used to represent a grid.
 * Each type of grid will receive a diferent kind of cell, it helps to implement the cell based in the grid struct.
 */

class CGrid
{

    protected:
		
		int cellnumber; ///< Number of cells in domain
    	CFluid *fluid; ///< Pointer to the fluid data;
    	int fluidtype1; ///< Type of simulated fluid;
        int blknumber; ///< Number of blocks in domain;
		CBlock *block; ///< Pointer to a block array;
		double betac; ///< Conversion factor.

	public:

		CGrid(); ///< Grid constructor;
		virtual ~CGrid(); ///< Grid destructor;

		virtual void Print() = 0; ///< Function used to print all the reservoir data on screen;
		virtual void SaveGridSolution(std::ofstream *fout, double time) = 0; ///< Function used to save the solution in disk.
		virtual void SaveWellSolution(std::ofstream *fout, int welln, double time) = 0; ///< Function used to save the well solution in disk.
	
		//////////  Numerical Functions  //////////
		virtual void InitiateSolution(double pref, double href) = 0; ///< Initiate the solution in all reservoir;
		virtual void Iterationni(double *Xni) = 0; ///< Makes the linear iteration "ni" in all cells;
		virtual void Iterationt(double deltat) = 0; ///< Makes the time iteration in all cells.

		//////////  Fluid Functions  /////////
		virtual double FVF( int celln ) = 0; ///< Return the FVF of a specific cell in domain;
		virtual double BackFVF( int celln ) = 0; ///< Return the back FVF of a specific cell in domain.

		//////////  Rock Functions  //////////
		virtual double RockComp( int celln ) = 0; ///< Return the rock compressibility of a specific cell in domain;
		virtual double Por0( int celln ) = 0; ///< Return the initial porosity of a specific cell in domain;
		virtual double Porosity( int celln, double pressure) = 0; ///< Return the atual porosity of a specific cell in domain.

		//////////  Cell Functions  //////////
		virtual int CellNumber() = 0; ///< Return the number of cells in domain;
		virtual int CellId( int celln ) = 0; ///< Return the cell ID of a specific cell in domain;
		virtual double Pressure( int celln ) = 0; ///< Return the atual pressure of a specific cell in domain;
		virtual double BackPressure( int celln ) = 0; ///< Return the back pressure of a specific cell in domain;
		virtual double Volume( int celln ) = 0; ///< Return the volume of a specific cell in domain;
		virtual double Deepth( int celln ) = 0; ///< Return the Deepth of a specific cell in domain.

		//////////  Transmissibility Functions //////////
		virtual void SetGTransmx() = 0; ///< Sets the Geometric transmissibility in all cells;
		virtual double RightTrasmx( int celln) = 0; ///< Return the right transmissibility of a specific cell in ddomain;
		virtual double RightGravityTransmx( int celln ) = 0; ///< Return the right gravitational transmissibility of a specif cell.

		//////////  Well Functions //////////
		virtual double WellRate( int celln ) = 0; ///< Return the flow rate of a well in a specific cell in domain;
		virtual int WellNumbers() = 0; ///< Return the number of wells in domain.

		////////// Boundary Conditions //////////
		virtual void SetBoundConditions(std::ifstream * fgrid) = 0; ///< Sets the boundary condition for the problem.

};

#endif // CGrid_h

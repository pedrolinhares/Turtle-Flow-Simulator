//** @file CGrid1d.h */
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

#ifndef CGrid1d_h
#define CGrid1d_h

#include <cmath>

#include "CGrid.h"
#include "CCell1d.h"

/**
 * This class represents a One-Dimensional single-phase Grid. It inherits from CGrid.h that is a abstract class.
 * This class has a array with one-dimensional cells.
 */

class CGrid1d1p : public CGrid
{

    private:

		CBlock1d *block; ///< Pointer to a block array;
    	CCell1d *cells; ///< Array with all cells of domain
    	
    protected:
    	
    	int xcells; ///< Number of cells in x direction;
    	double *lenght; ///< Vector representing the lenght of each cell in domain
    	double *width;   ///< Vector representing the Width of each cell in domain.
		double *thickness;  ///< Vector representing the Thickness of each cell in domain.

	public:

		CGrid1d1p(int _fluidtype); ///< One-Dimensional Grid Constructor
		CGrid1d1p(); ///< Overloaded One-Dimensional Grid Constructor
		virtual ~CGrid1d1p(); ///< One-Dimensional Grid Destructor

		virtual void Print(); ///< Function used to print all the reservoir data on screen.
		virtual void SaveGridSolution(std::ofstream *fout, double time); ///< Function used to save the grid solution in disk.
		virtual void SaveWellSolution(std::ofstream *fout, int welln, double time);///< Function used to save the well solution in disk.

		//////////  Numerical Functions  //////////
		virtual void InitiateSolution(double pref, double href); ///< Initiate the solution in all reservoir;
		virtual void Iterationni(double *Xni); ///< Makes the linear iteration "ni" in all cells;
		virtual void Iterationt(double deltat); ///< Makes the time iteration in all cells.

		//////////  Fluid Functions  /////////
		double FVF( int celln ) { return cells[celln].FVF(); }; ///< Return the FVF of a specific cell in domain;
		double BackFVF( int celln ) { return cells[celln].BackFVF(); }; ///< Return the back FVF of a specific cell in domain.

		//////////  Rock Functions  //////////
		double RockComp( int celln ) { return cells[celln].RockComp(); }; ///< Return the rock compressibility of a specific cell in domain;
		double Por0( int celln ) { return cells[celln].Porosity(); }; ///< Return the initial porosity of a specific cell in domain;
		double Porosity( int celln, double pressure) { return cells[celln].Porosity(pressure); }; ///< Return the atual porosity of a specific cell in domain.

		//////////  Cell Functions  //////////
		virtual int CellNumber() { return cellnumber; }; ///< Return the number of cells in domain;
		double XCells() { return xcells; }; ///< Retunr the number of cells in x direction;
		int CellId( int celln ) { return cells[celln].CellId(); }; ///< Return the cell ID of a specific cell in domain;
		double Pressure( int celln ); ///< Return the atual pressure of a specific cell in domain;
		double RightPressure( int celln ); ///< Return the atual pressure of the right cell of a specific cell in domain;
		double LeftPressure( int celln ); ///< Return the atual pressure of the left cell of a specific cell in domain;
		double BackPressure( int celln ) { return cells[celln].BackPressure(); }; ///< Return the back pressure of a specific cell in domain;
		double Volume( int celln ); ///< Return the volume of a specific cell in domain;
		double Deepth( int celln ); ///< Return the Deepth of a specific cell in domain.
		double RightDeepth( int celln ); ///< Return the Deepth of the right cell of a specific cell in domain.
		double LeftDeepth( int celln ); ///< Return the Deepth of the left cell of a specific cell in domain.
		
		//////////  Cell Connection Functions  //////////
		int ConnectionsNumber() { return (xcells - 1); }; ///< Returns the number of connections among cells in the grid.

		//////////  Transmissibility Functions //////////
		virtual void SetGTransmX(); ///< Sets the Geometric transmissibility in all cells;
		double RightTrasmX( int celln ); ///< Return the right transmissibility of a specific cell in ddomain;
		double RightGravityTransmX( int celln ); ///< Return the right gravitational transmissibility of a specif cell.
		double LeftTrasmX( int celln ); ///< Return the left transmissibility of a specific cell in ddomain;
		double LeftGravityTransmX( int celln ); ///< Return the left gravitational transmissibility of a specif cell.
		double Gamma( int celln ); ///< Return the gamma factor of a specific cell;
		
		//////////  Transmissibility Derivative Functions  //////////
		double GammaDer( int celln );  ///< Returns the derivative of the gamma function in relation of the cell pressure;
		double RightTransmXDer( int celln ); ///< Returns the derivative of the right transm. in relation of the right cell pressure for celln;
		double LeftTransmXDer( int celln ); ///< Returns the derivative of the left transm. in relation of the right cell pressure for celln;
		double CenterTransmXDer( int celln ) { return cells[celln].CenterTransmXDer(); }; ///< Returns the derivative of the right transm. in relation of the cell press for celln;
		double RightGravityTransmXDer( int celln ); ///< Returns the derivative of the right gravitational transmissibility in relation of the right cell pressure;
		double LeftGravityTransmXDer( int celln ); ///< Returns the derivative of the left gravitational transmissibility in relation of the right cell pressure;
		double CenterGravityTransmXDer( int celln )  { return cells[celln].CenterGravityTransmXDer(); }; ///< Returns the derivative of the right gravitational transmissibility in relation of the center cell pressure;

		//////////  Well Functions //////////
		double WellRate( int celln ) { return cells[celln].WellRate(); }; ///< Return the flow rate of a well in a specific cell in domain.
		virtual int WellNumbers(); ///< Return the number of wells in domain.

		////////// Boundary Conditions //////////
		void SetBoundConditions(std::ifstream * fgrid); ///< Sets the boundary condition for the problem;
		void SetCellConnections(); ///< Sets the connections between neighbooring cells.

};

#endif // CGrid1d_h

//** @file CCell2d.h */
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

#ifndef CCell2d_h
#define CCell2d_h

#include "CCell1d.h"
#include "CBlock2d.h"
#include "CFluid.h"
#include "CWell2d.h"

/**
 * This class is used to represent a two-dimensional cell.
 * Each cell will be created inside the two-dimensional grid, and will be organized in an array of cells.
 */

class CCell2d : public CCell1d
{
	private:
		
		CBlock2d *block; ///< Pointer to the block containing this cell;
		CWell2d  *well; ///< Pointer to a well in this cell. If the cell doesn't have a well, this pointer is NULL;
		CCell2d *leftcell; ///< Pointer to the left cell;
		CCell2d *rightcell; ///< Pointer to the right cell.
		CCell2d *frontcell; ///< Pointer to the left cell;
		CCell2d *backcell; ///< Pointer to the left cell;
		
	protected:
		
		double gtransmy; ///< Geometric transmissibility in y direction;
		
	public:

		CCell2d(); ///< Cell 1d constructor;
		CCell2d(int _cellid, double _deepth, CBlock2d *blk, CFluid *fld); ///< Overloaded cell constructor;
		CCell2d(CCell2d & _cell); ///< Copy constructor;
		~CCell2d(); ///< Cell 1d destructor;

		void Print(); ///< Function used to print all cell parameters on screen;

		//////////  Fluid Functions  /////////
		inline double FVF() { return fluid->FVF(pressure); }; ///< Return the FVF of the fluid inside this cell, at atual time of simulation.
		inline double BackFVF() { return fluid->FVF(backpressure); }; ///< Return the FVF of the fluid inside this cell, at back time of simulation.
		inline CFluid * Fluid() { return fluid; }; ///< Return a pointer to the fluid;

		//////////  Rock Functions  //////////
		inline double RockComp() { return block->RockComp(); }; ///< Return the rock compressibility at atual pressure;
		inline double Porosity() { return block->Porosity(); }; ///< Return the initial rock porosity;
		inline double Porosity(double pressure) { return block->Porosity(pressure); }; ///< Return the atual rock porosity;
		inline double Permeability_x() { return block->Permeability_x();  }; ///< Return the rock permeability in x directon;
		inline double Permeability_y() { return block->Permeability_y();  }; ///< Return the rock permeability in y direction;
		inline CBlock2d * Block() { return block; }; ///< Return a pointer to the block
		
		////////// Connection Functions  //////////
		inline void LeftCell( CCell2d *_leftcell) { leftcell = _leftcell; }; ///< Set a pointer to left cell;
		inline void RightCell( CCell2d *_rightcell) { rightcell = _rightcell; }; ///< Set a pointer to right cell;
		inline void FrontCell( CCell2d *_frontcell) { frontcell = _frontcell; }; ///< Set a pointer to front cell;
		inline void BackCell( CCell2d *_backcell) { backcell = _backcell; }; ///< Set a pointer to back cell;
		
		CCell2d * LeftCell() { return leftcell; }; ///< Return a pointer to the right cell;
		CCell2d * RightCell() { return rightcell; }; ///< Return a pointer to the right cell;
		CCell2d * FrontCell() { return frontcell; }; ///< Return a pointer to the front cell;
		CCell2d * BackCell() { return backcell; }; ///< Return a pointer to the back cell;
		
		//////////  Cell Functions  //////////
		inline int CellId() { return cellid; }; ///< Return the cell identification;
		inline double Pressure() { return pressure; }; ///< Return the cell pressure;
		inline void Pressure(double _pressure) { pressure = _pressure; }; ///< Set the cell pressure;
		inline double BackPressure() { return backpressure; }; ///< Return the cell pressure in the back time iteration;
		inline void BackPressure( double _backpressure) { backpressure = _backpressure; }; ///< Set the pressure of the back time iteration;
		inline double Weight() { return fluid->Weight(pressure); };  ///< Return the cell weight;
		inline double Deepth()  { return deepth; }; ///< Return the cell deepth;

		//////////  Transmissibility Functions //////////
		inline void GTransmx( double _gtransmx) { gtransmx = _gtransmx; }; ///< Set the geometric transmissibility in x direction;
		inline void GTransmy( double _gtransmy) { gtransmy = _gtransmy; }; ///< Set the geometric transmissibility in y direction;
		inline double GTransmx() { return gtransmx; }; ///< Get the geometric transmissibility in x direction;
		inline double GTransmy() { return gtransmy; }; ///< Get the geometric transmissibility in y direction;
		double RightTransmx(); ///< Return the right transmissibility;
		double RightGravityTransmx(); ///< Return the right gravitational transmissibility;
		double FrontTransmy(); ///< Return the front transmissibility;
		double FrontGravityTransmy(); ///< Return the front gravitational transmissibility;
		double Gamma(double CellVolume); ///< Return the gamma factor;
		
		//////////  Transmissibility Derivative Functions  //////////
		double GammaDer(double CellVolume); ///< Returns the derivative of the gamma function in relation of the cell pressure;
		double RightTransmxDer( ); ///< Returns the derivative of the right transmissibility in relation of the right cell pressure;
		double CenterTransmxDer( ); ///< Returns the derivative of the right transmissibility in relation of the cell pressure;
		double RightGravityTransmxDer( ); ///< Returns the derivative of the right gravitational transmissibility in relation of the right cell pressure;
		double CenterGravityTransmxDer( ); ///< Returns the derivative of the right gravitational transmissibility in relation of the center cell pressure;

		//////////  Well Functions //////////
		int WellId();
		void SetWell(CWell2d *_well) { well = _well; }; ///< Set the well in this cell;
		double WellRate(); ///< Return the well flow rate in this cell.
		void IterationtWell(double deltat) { well->IterationtWell(deltat); }; ///< This function makes the cumulative volume Iteration for the well;
		double WellCumulative_Phase1(); ///< This function returns the cumulative volume of the phase 1;
		inline CWell2d * Well() { return well; }; ///< Return a pointer to the well.

};

#endif // CCell1d_h

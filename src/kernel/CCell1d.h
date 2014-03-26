//** @file CCell1d.h */
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

#ifndef CCell1d_h
#define CCell1d_h

#include "CBlock1d.h"
#include "CFluid.h"
#include "CWell1d.h"

/**
 * This class is used to represent a one-dimensional cell.
 * Each cell will be created inside the one-dimensional grid, and will be organized in an array of cells.
 */

class CCell1d
{
	private:
		
		CBlock1d *block; ///< Pointer to the block containing this cell;
		CWell1d  *well; ///< Pointer to a well in this cell. If the cell doesn't have a well, this pointer is NULL;
		CCell1d *leftcell; ///< Pointer to the left cell;
		CCell1d *rightcell; ///< Pointer to the right cell.
		
	protected:
		
		double alphac; ///< Convertion units factor;
		int cellid; ///< Cell Id;
		double deepth; ///< Cell deepth;
		double pressure; ///< Pressure at atual time;
		double backpressure; ///< Pressure at back iteration time;
		double gtransmx; ///< Geometric transmissibility in x direction;
		CFluid *fluid; ///< Pointer to the fluid;

	public:

		CCell1d(); ///< Cell 1d constructor;
		CCell1d(int _cellid, double _deepth, CBlock1d *blk, CFluid *fld); ///< Overloaded cell constructor;
		CCell1d(CCell1d & _cell); ///< Copy constructor;
		~CCell1d(); ///< Cell 1d destructor;

		void Print(); ///< Function used to print all cell parameters on screen;

		//////////  Fluid Functions  /////////
		inline double FVF() { return fluid->FVF(pressure); }; ///< Return the FVF of the fluid inside this cell, at atual time of simulation.
		inline double BackFVF() { return fluid->FVF(backpressure); }; ///< Return the FVF of the fluid inside this cell, at back time of simulation.
		inline CFluid * Fluid() { return fluid; }; ///< Return a pointer to the fluid;
		inline double Weight() { return fluid->Weight(pressure); };  ///< Return the weight of the fluid inside the cell ;

		//////////  Rock Functions  //////////
		inline double RockComp() { return block->RockComp(); }; ///< Return the rock compressibility at atual pressure;
		inline double Porosity() { return block->Porosity(); }; ///< Return the initial rock porosity;
		inline double Porosity(double pressure) { return block->Porosity(pressure); }; ///< Return the atual rock porosity;
		inline double Permeability_x() { return block->Permeability_x();  }; ///< Return the rock permeability;
		inline CBlock1d * Block() { return block; }; ///< Return a pointer to the block

		//////////  Cell Functions  //////////
		inline int CellId() { return cellid; }; ///< Return the cell identification;
		inline double Pressure() { return pressure; }; ///< Return the cell pressure;
		inline void Pressure(double _pressure) { pressure = _pressure; }; ///< Set the cell pressure;
		inline double BackPressure() { return backpressure; }; ///< Return the cell pressure in the back time iteration;
		inline void BackPressure( double _backpressure) { backpressure = _backpressure; }; ///< Set the pressure of the back time iteration;
		inline void LeftCell( CCell1d *_leftcell) { leftcell = _leftcell; }; ///< Set a pointer to left cell;
		inline void RightCell( CCell1d *_rightcell) { rightcell = _rightcell; }; ///< Set a pointer to right cell;
		CCell1d * LeftCell() { return leftcell; }; ///< Return a pointer to the right cell;
		CCell1d * RightCell() { return rightcell; }; ///< Return a pointer to the right cell;
		inline double Deepth()  { return deepth; }; ///< Return the cell deepth;

		//////////  Transmissibility Functions //////////
		inline void GTransmx( double _gtransmx) { gtransmx = _gtransmx; }; ///< Set the geometric transmissibility;
		inline double GTransmx() { return gtransmx; }; ///< Get the geometric transmissibility;
		double RightTransmx(); ///< Return the right transmissibility;
		double RightGravityTransmx(); ///< Return the right gravitational transmissibility;
		double Gamma(double CellVolume); ///< Return the gamma factor;
		
		//////////  Transmissibility Derivative Functions  //////////
		double GammaDer(double CellVolume); ///< Returns the derivative of the gamma function in relation of the cell pressure;
		double RightTransmxDer( ); ///< Returns the derivative of the right transmissibility in relation of the right cell pressure;
		double CenterTransmxDer( ); ///< Returns the derivative of the right transmissibility in relation of the cell pressure;
		double RightGravityTransmxDer( ); ///< Returns the derivative of the right gravitational transmissibility in relation of the right cell pressure;
		double CenterGravityTransmxDer( ); ///< Returns the derivative of the right gravitational transmissibility in relation of the center cell pressure;

		//////////  Well Functions //////////
		int WellId();
		void SetWell(CWell1d *_well) { well = _well; }; ///< Set the well in this cell;
		double WellRate(); ///< Return the well flow rate in this cell.
		void IterationtWell(double deltat) { well->IterationtWell(deltat); }; ///< This function makes the cumulative volume Iteration for the well;
		double WellCumulative_Phase1(); ///< This function returns the cumulative volume of the phase 1;
		inline CWell1d * Well() { return well; }; ///< Return a pointer to the well.

};

#endif // CCell1d_h

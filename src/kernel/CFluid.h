//** @file CFluid.h */
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

#ifndef CFluid_h
#define CFluid_h

#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>

/**
 * This class is an abstract class used to represent a fluid.
 * The fluid can be oil, gas or water, and specific properties can be modeled in these children classes.
 */

class CFluid
{
	protected:

		int pvtpoints; ///< Number of PVT points used to describe the fluid behaviour;
		double *pressure; ///< Array containing all pressure points in PVT;
		double *fvf; ///< Array containing all FVF points in PVT;
		double *weight; ///< Array containing all Specific Weight points in PVT;
		double *viscosity; ///< Array containing all viscosity points in PVT;

	public:

		CFluid(); ///< Fluid constructor;
		virtual ~CFluid(); ///< Fluid destructor;
		
		//////////  Interpolation Functions  //////////
		virtual double FVF(double pressure) = 0; ///< Returns the FVF of a specific pressure;
		virtual double Weight(double pressure) = 0; ///< Returns the Specific Weight of a specific pressure;
		virtual double Viscosity(double pressure) = 0; ///< Returns the Viscosity of a specific pressure;
		virtual double AveragePVTPressure() = 0; ///< Returns the average pressure of the PVT test;
		
		//////////  Derivative Functions  //////////
    	virtual double FVF_Derivative(double pres) = 0; ///< Returns the FVF derivative of a specific pressure;
    	virtual double Weight_Derivative(double pres) = 0; ///< Returns the Weight derivative of a specific pressure;
   		virtual double Viscosity_Derivative(double pres) = 0; ///< Returns the Viscosity derivative of a specific pressure;
		
		virtual void Print() = 0; ///< Prints all fluid data.
};

#endif // CFluid_h

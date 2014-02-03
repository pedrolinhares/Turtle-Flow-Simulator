//** @file CRock.h */
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

#ifndef CRock_h
#define CRock_h

#include <cmath>
#include <iostream>

/**
 * This Class is used to store the Rock parameters, and its object will be created inside the Blocks.
 */

class CRock
{

    private:

        double rockcomp; // Rock Compressibility
        double permeability; //Rock Permeability
        double por0; //Inicial Rock Porosity
		double refpressure; //Reference Pressure
	public:

		CRock();
		~CRock();

		inline void Rockcomp(double _rockcomp) {rockcomp = _rockcomp;}; ///< Sets the Rock Compressibility;
		inline double Rockcomp() {return rockcomp;}; ///< Returns Rock Compressibility;

		inline void Permeability(double _permeability) {permeability = _permeability;}; ///< Sets the Rock Permeability;
		inline double Permeability() {return permeability;}; ///< Returns Rock Permeability;

		inline void Por0(double _porosity) {por0 = _porosity;}; ///< Sets the initial Rock Porosity;

		inline double Porosity() { return por0; }; ///< Returns initial Rock Porosity;
		double Porosity(double pressure); ///< Returns atual Rock Porosity;

		inline void RefPressure( double _refpressure) { refpressure = _refpressure; }; ///< Sets the reference pressure of porosity.
};

#endif // CRock_h

//** @file CRock2d.h */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz Barros.
 *  
 *  Class Author: Wagner Queiroz Barros.
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
 
#ifndef CRock2d_h
#define CRock2d_h

#include "CRock1d.h"


/**
 * This Class is used to store the Two-Dimensional Rock parameters, and its object will be created inside the Blocks.
 */

class CRock2d : public CRock1d
{

    protected:

    double permeability_y; //Rock Permeability in direction y;
	
	public:

		CRock2d();
		~CRock2d();

		inline void Permeability_y(double _permeability_y) {permeability_y = _permeability_y;}; ///< Sets the Rock Permeability_y;
		inline double Permeability_y() {return permeability_y;}; ///< Returns Rock Permeability_y;
		
};

#endif // CRock2d_h

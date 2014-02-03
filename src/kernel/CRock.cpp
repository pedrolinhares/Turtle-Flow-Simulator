//** @file CRock.cpp */
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

#include "CRock.h"


CRock::CRock() : rockcomp(0), permeability(0), por0(0), refpressure(0)
{
	/// Class constructor

}


CRock::~CRock()
{
	/// Class destructor

}

double CRock::Porosity(double pressure) {
	/// This function returns the porosity in function of the pressure variation. The rock porosity is
	/// calculated based in an elastic compressibility.

	return  por0*exp(rockcomp*(pressure-refpressure));

}

//** @file CWell1d.cpp */
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

#include "CWell1d.h"

CWell1d::CWell1d() : rate(0) , id(0) , cumulative_phase1(0)
{
	/// Well constructor.
}

CWell1d::~CWell1d()
{
	/// Well destructor.
}

void CWell1d::Rate( double _rate, int _id) {
	 ///< Sets the well flow rate, and the well Id.

	rate = _rate;
	id = _id;
}

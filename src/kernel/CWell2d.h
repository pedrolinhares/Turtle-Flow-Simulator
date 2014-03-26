/** @file CWell2d.h */
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

#ifndef CWell2d_h
#define CWell2d_h

/**
 * This class represents a two-dimensional well.
 * The one-dimensional well is the simplest well to model, and it can be setted only as a constant well rate.
 */

#include "CWell1d.h"

class CWell2d : public CWell1d
{
	protected:
		
	public:

		CWell2d(); ///< Well constructor;
		CWell2d(double _rate); ///< Overloaded well constructor;
		CWell2d(double _rate, int _id); ///< Overloaded well constructor;
		void SetWell2d( double _rate, int _id); ///< Sets the well flow rate, and the well Id.
		~CWell2d(); ///< Well destructor;
};

#endif // CWell2d_h

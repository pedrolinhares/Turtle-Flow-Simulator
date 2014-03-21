//** @file CBlock1d.cpp */
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

#include "CBlock1d.h" // class's header file

using namespace std;

CBlock1d::CBlock1d() : blockid(0)
{
	/// Class constructor

}

CBlock1d::CBlock1d(int _blkid, double _comp, double _perm, double _por, double _ref_pres) : blockid(_blkid)
{
	/// Overloaded Class constructor
	rock.Rockcomp(_comp);
    rock.Permeability_x(_perm);
	rock.Por0(_por);
	rock.RefPressure(_ref_pres);

}

CBlock1d::~CBlock1d()
{
	/// class destructor

}

void CBlock1d::Print() {
	/// This function prints all block parameters on screen. It is used to debug the code,
	/// during programing, but it won't be used when the final code is ready.

        cout << "Block ID - " << blockid << endl;
		cout << "Rock Compressibility - " << rock.Rockcomp() << "\n";
        cout << "Rock Permeability - " << rock.Permeability_x() << "\n";
		cout << "Rock Porosity - " << rock.Porosity() << "\n";
  }


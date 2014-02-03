//** @file CBlock.h */
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

#ifndef CBlock_h
#define CBlock_h

#include <iostream>
#include <fstream>

#include "CRock.h"

/**
 * This Class is used to describe a block in reservoir.
 * A Block is defined as a group of cells having the same rock proprieties.
 * It is used to save data storing, in homogeneous simulations.
 */

class CBlock
{
    private:

        int blockid; ///< Id of Block;
        CRock rock; ///< Rock object stored in this block;

	public:

		CBlock(); ///< Block constructor;
		CBlock(double *data); ///< Overloaded Block constructor;
		~CBlock(); ///< Block destructor;

		///////////  Block Functions  //////////
		inline int Blockid() {return blockid;}; ///< Returns the Block Id;
		void PrintBlock(); ///< Prints the Block proprieties on screen.

		///////////  Rock Functions  //////////
		inline double Permeability() {	return rock.Permeability();	}; ///< Returns the Rock permeability;
		inline double Porosity() { return rock.Porosity(); }; ///< Returns the initial Rock porosity;
		inline double Porosity(double pressure) { return rock.Porosity(pressure); }; ///< Returns the atual Rock porosity;
		inline double RockComp() { return rock.Rockcomp(); }; ///< Returns the Rock compressibility;

};

#endif // CBlock_h

//** @file CReservoir.h */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz Barros.
 *  
 *  Class Author: Wagner Queiroz Barros.
 *  Date: 08/04/2014
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

#ifndef CReservoir1d_h
#define CReservoir1d_h

#include "CReservoir.h"

#include <fstream>
#include "CGrid1d1p.h"

#include "CResModelType.h"
#include "CSISinglePhase1d.h"
#include "CISinglePhase1d.h"

#include "CSolverMatrix.h"

/**
 * The CReservoir1d is a inheritance of the main Creservoir class. It is responsible of manage all the simulation of 1d cases.
 * This class is responsible to create all other classes, and to manage the simulation flow.
 */

class CReservoir1d : public CReservoir {
	
	private:
		
	  //////////  Reservoir Parameters  //////////
	  CGrid1d1p *grid; ///< Pointer to the reservoir grid;
	  CResModelType *model; ///< Pointer to the model that describes the reservoir behaviour;
	  void OutPutInitiate(); ///< This function is used to initiate the output files;
	
	public:
	  CReservoir1d();
	  CReservoir1d(std::ifstream *fmodel);
	  ~CReservoir1d();
	  void Run(); ///< Function used to manage the reservoir simulation

};

#endif // CReservoir1d_h

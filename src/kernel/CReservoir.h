//** @file CReservoir.h */
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

#ifndef CReservoir_h
#define CReservoir_h

#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>

#include "CSolverMatrix.h"

/**
 * The CReservoir is the main class of the project, responsible of manage all the simulation.
 * This class is responsible to create all other classes, and to manage the simulation flow.
 */

class CReservoir {
	
	protected:
		
	  //////////  Reservoir Parameters  //////////
	  int cpoints; //Number of lines of linear equation system, and of cells in reservaoir;
	
	  ///////////  Numerical Parameters  /////////
	  CSolverMatrix *solver; ///< Pointer to numerical solver;
	  double deltat; ///< Delta time of simulation;
	  double finalt; ///< Final simulation time;
	  int savet; ///< Time frequency of exporting solution from disk, multiple of deltat;
	
	  ///////////  Output Parameters  /////////
	  std::ofstream grid_data; ///< Out put file for the pressure in all cell points;
	  std::ofstream *well_data; ///< Out put file for the pressure in all cell points;
	
	public:
	  CReservoir();
	  virtual ~CReservoir();
	  virtual void Run() = 0; ///< Function used to manage the reservoir simulation

};

#endif // CReservoir_h

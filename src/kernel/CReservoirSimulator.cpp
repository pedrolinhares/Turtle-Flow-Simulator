//** @file CReservoirSimulator.cpp */
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

#include "CReservoirSimulator.h"
#include "filename_definitions.h"
#include <cstdlib>

using namespace std;
using namespace filename_definitions;

CReservoirSimulator::CReservoirSimulator()
{
}

CReservoirSimulator::~CReservoirSimulator()
{
}

void CReservoirSimulator::Run() {
	
    /// Getting simulation parameters
  
  	ifstream fmodel(ARQ_MODEL_FILE.c_str());
  
    if (fmodel.fail())
       {
            cerr << "There is no model data." << endl;
            exit(EXIT_FAILURE);
       }

  	int phase_number, dimensions;
  
  	fmodel >> phase_number;
  	fmodel.ignore(256, '\n');
  
  	fmodel >> dimensions;
  	fmodel.ignore(256, '\n');
  
	  switch (phase_number) {
	  	case 1: {
	  		switch (dimensions) {
	  			case 1: {
	  				reservoir = new CReservoir1d(&fmodel); ///< Constructing 1d grid.				
	  				break;
	  			}
	  			
	  		}
	  		
	  		break;
	  	}
	  }
  
   	fmodel.close();  ///< Closing the input file
   	reservoir->Run(); ///< Running simulation.
		
}


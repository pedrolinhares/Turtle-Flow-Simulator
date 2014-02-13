//** @file CReservoir.cpp */
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

#include <cstdlib>
#include "CReservoir.h"

#include "filename_definitions.h"

using namespace std;
using namespace filename_definitions;

CReservoir::CReservoir()
{
  // class constructor
  
  ifstream fmodel(ARQ_MODEL_FILE.c_str());
  
    if (fmodel.fail())
       {
            cerr << "There is no model data." << endl;
            exit(EXIT_FAILURE);
       }

  int phase_number, fluid_type, dimensions;
  
  fmodel >> phase_number;
  fmodel.ignore(256, '\n');
  
  fmodel >> fluid_type;
  fmodel.ignore(256, '\n');
  
  fmodel >> dimensions;
  fmodel.ignore(256, '\n');
  
  switch (phase_number) {
  	case 1: {
  		switch (dimensions) {
  			case 1: {
  				grid = new CGrid1d1p(fluid_type); ///< Constructing the grid.				
  				break;
  			}
  		}
  		
  		break;
  	}
  }
  
  cpoints=grid->CellNumber(); ///< Getting the number of cells in domain.
  
  //////////  Constructing Model //////////
  int model_type, model_maxni;
  double model_errorni;
  
  fmodel >> model_type;
  fmodel.ignore(256, '\n');
  
  fmodel >> model_maxni;
  fmodel.ignore(256, '\n');
  
  fmodel >> model_errorni;
  fmodel.ignore(256, '\n');
  
  switch (model_type) {
  	case 1:  {
  		model = new CSISinglePhase1d(grid, model_maxni, model_errorni); ///< Constructing the Reservoir Model.		
  		break;
  	}
  }
  
  //////////  Constructing Solver //////////
  int solverid, solver_maxit;
  double solver_error;
  
  fmodel >> solverid;
  fmodel.ignore(256, '\n');
  
  fmodel >> solver_maxit;
  fmodel.ignore(256, '\n');
  
  fmodel >> solver_error;
  fmodel.ignore(256, '\n');
  
  switch (solverid) {
  	case 1: {
  		switch (dimensions) {
  			case 1: {
  				solver = new CSolverMatrix(); ///< Constructing Solver.
  				break;
  			}
  		}
  		break;
  	}
  }
  
  ////////// Constructing time parameters /////////
  fmodel >> deltat;
  fmodel.ignore(256, '\n');
  
  fmodel >> finalt;
  fmodel.ignore(256, '\n');
  
  ///////// Initiating Initial Solution //////////
  double ref_press, ref_deepth;
  
  fmodel >> ref_press;
  fmodel.ignore(256, '\n');
  
  fmodel >> ref_deepth;
  fmodel.ignore(256, '\n');
  
  grid->InitiateSolution(ref_press, ref_deepth);
  
}

CReservoir::~CReservoir() {
  // class destructor

  delete grid;

  
}

void CReservoir::Run() {
  ///This function manages all the simulation. The loops used to advance time are implemented here.

  grid->Print(); ///< Printing the grid data on screen, Only for debugging.

     model->BuildInitialSolution(grid); ///< Constructing an initial solution, according to the grid data.

     
     double tme = 0;

     OutPutInitiate(); ///< Initiating output files;

     /// Saving initial solution in disk;
     grid->SaveGridSolution(&grid_data, tme);

     for (int i = 0; i < grid->WellNumbers(); i++) {
         grid->SaveWellSolution(&well_data[i], (i + 1), tme);
     }

		/////////  Time Iteration  //////////
     while ( (finalt - tme + deltat) > deltat) {

     	tme = tme + deltat;

    	cout.precision(4);
    	cout << "\n Time - "<< tme << std::fixed;
	   
   		model->Iterationt(grid, solver, deltat); ///< Iterating the time in all cells;

    	/// Saving the solution in disk;
    	grid->SaveGridSolution(&grid_data, tme);
    	for (int i = 0; i < grid->WellNumbers(); i++) {
      		grid->SaveWellSolution(&well_data[i], (i + 1), tme);
    	}
    }
    
} 

void CReservoir::OutPutInitiate() {
  /// This function is used to initiate the output files;
   grid_data.open(OUT_GRID_FILE.c_str());

   grid_data << "Time [day]\t";  ///File header;
   for (int i=0; i<cpoints; i++) {
    grid_data << "Cell " << (i+1) << "[psia]\t";  ///File header;
   }
   grid_data << endl;

   int welln;
   welln = grid->WellNumbers(); ///< Return the number of wells;

   well_data = new ofstream[welln];

   for (int k = 0; k < welln; k++) {
    ostringstream wdn;
    wdn << OUT_WELLS_FILE << (k+1) << ".out";
    well_data[k].open(wdn.str().c_str());

    well_data[k] << "Time [day]"<< setw(20) <<"Pressure [psia]" << setw(30) <<"CumulativePhase1 [STB] \n";  ///File header;
    well_data[k] << endl;
   }
}

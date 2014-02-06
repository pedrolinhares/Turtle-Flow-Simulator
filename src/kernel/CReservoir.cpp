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

//#ifndef KERNEL_DEFINITIONS_H
#include "filename_definitions.h"
//#endif

using namespace std;
using namespace filename_definitions;

CReservoir::CReservoir(CDataControl *_dcontrol)
{
  // class constructor

  dcontrol = _dcontrol;

    dimtype = 1; //Only the 1d case is implemented at this moment. It need to be changed when the 2D case will be implemented.

    grid = new CGrid1d(dcontrol); ///< Constructing the grid.

  cpoints=grid->CellNumber(); ///< Getting the number of cells in domain.

  

  //////////  Constructing Solver and Model //////////
  double *data;
  data = dcontrol->DataNumeric(ARQ_NUMERICS_FILE); ///< Getting solver parameters

  int maxsolver;
  double errorsolver;
  
  int maxni;
  double erroni;

  maxsolver = (int) data[1];
  errorsolver = data[2];
  deltat = data[3];
  finalt = data[4];
  maxni = (int) data[5];
  erroni = data[6];
  
  model = new CSISinglePhase1d(cpoints, maxni, erroni); ///< Constructing the Reservoir Model.
  
  solver = new CSolMatTrid(cpoints, maxsolver, errorsolver); ///< Constructing Tridiagonal Solver.  It need to be changed when the 2D case will be implemented.

    delete [] data;

}

CReservoir::~CReservoir() {
  // class destructor

  delete grid;

  
}

void CReservoir::Run() {
  ///This function manages all the simulation. The loops used to advance time are implemented here.

     //grid->PrintData(); ///< Printing the grid data on screen, Only for debugging.

     model->BuildInitialSolution(grid); ///< Constructing an initial solution, according to the grid data.

     /////////  Time Iteration  //////////

     double tme = 0;

     OutPutInitiate(); ///< Initiating output files;

     /// Saving initial solution in disk;
     grid->SaveGridSolution(&grid_data, tme);

     for (int i = 0; i < grid->WellNumbers(); i++) {
         grid->SaveWellSolution(&well_data[i], (i + 1), tme);
     }


     while ( (finalt - tme + deltat) > deltat) {

     	tme = tme + deltat;

    	cout.precision(4);
    	cout << "\n Time - "<< tme << std::fixed;
	   
   		model->Iterationt(grid, solver, deltat); ///< Iterating the time in all cells;
    	grid->Iterationt(deltat);  ///< Updating the back pressure in all reservoir;

    	/// Saving the solution in disk;
    	grid->SaveGridSolution(&grid_data, tme);
    	for (int i = 0; i < grid->WellNumbers(); i++) {
      		grid->SaveWellSolution(&well_data[i], (i + 1), tme);
    	}
    }
} 

void CReservoir::OutPutInitiate() {
  /// This function is used to initiate the output files;
   grid_data.open(OUT_GRIDS_FILE.c_str());

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

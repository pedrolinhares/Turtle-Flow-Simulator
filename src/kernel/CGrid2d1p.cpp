//** @file CGrid1d.cpp */
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

#include <cstdlib>
#include "filename_definitions.h"
#include "CGrid2d1p.h"

using namespace std;
using namespace filename_definitions;

CGrid2d1p::CGrid2d1p(int _fluidtype) : CGrid1d1p()
{
  /// class constructor
  
	ifstream fgrid(ARQ_GRID2d_FILE.c_str());
  
    if (fgrid.fail())
       {
            cerr << "There is no grid data." << endl;
            exit(EXIT_FAILURE);
       }

    //////////  Constructing CBlock  //////////
    fgrid >> blknumber;
    fgrid.ignore(256, '\n');
    
    block = new CBlock2d[blknumber];
	
	{
	    int blkid;
	    double rockcomp, rockpermx, rockpermy, rockpor, refpres;
	    
	     for(int i = 0; i < blknumber ; i++) {
	       
		   fgrid >> blkid;	
	       fgrid.ignore(256, '\n');	
	       
	       fgrid >> rockcomp;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> rockpermx;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> rockpermy;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> rockpor;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> refpres;	
	       fgrid.ignore(256, '\n');
	       
	       CBlock2d blk(blkid, rockcomp, rockpermx, rockpermy, rockpor, refpres); ///< Constructing a block;
	
	       block[i]=blk; ///< adding the constructed block in the block array;
	     }
	     
	}
	/*
	//////////  Constructing CGrid1d  //////////
	  fgrid >> cellnumber;
	  fgrid.ignore(256, '\n');
		fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
    
		lenght = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> lenght[i];
    }

		fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
		width = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> width[i];
    }
    
    fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
    thickness = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> thickness[i];
    }
    
    //////////  Constructing CFluid  //////////
    fluidtype1 = _fluidtype;
   
    switch (fluidtype1) {
     case 1: { ///< Case 1 represents a water simulation
         fluid = new CWater; ///< Constructing the water object;
     break;
     }
     case 2: {
         fluid = new COil; ///< Constructing the oil object;
     break;
     }
     case 3: {
         fluid = new CGas; ///< Constructing the gas object;
     break;
     }
    }
    
    //////////  Constructing CCell  //////////
   cells = new CCell1d[cellnumber]; ///< constructing an array of cells;

	 fgrid.ignore(256, '#');
   fgrid.ignore(256, '#');
   double *deepth; ///< Temporary array of cells deepth;
   deepth = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> deepth[i];
    }
   
   fgrid.ignore(256, '#');
   fgrid.ignore(256, '#');
   int *block_cell_conection; ///< Temporary array of cenections between blocks and cells;
   block_cell_conection = new int[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> block_cell_conection[i];
    }
   
   for( int i=0; i < cellnumber ; i++ ) {
       CCell1d c1d((i+1), deepth[i], &block[block_cell_conection[i]-1], fluid); ///< Constructing a cell, and connecting this cell with the matching block and fluid;
       cells[i] = c1d; ///< adding the cell in the cell arrray.
   }
   
   delete [] deepth;
   deepth = NULL;
       
   delete [] block_cell_conection;
   block_cell_conection = NULL;
    
   //////////  Constructing CWell1d  //////////
    ifstream fwell1d(ARQ_WELL1D_FILE.c_str());
  
    if (fwell1d.fail())
       {
            cerr << "There is no well data." << endl;
            exit(EXIT_FAILURE);
       }
   
   int wellsnumber;
   fwell1d >> wellsnumber;
   fwell1d.ignore(256, '\n');
   
   for (int j = 0 ; j < wellsnumber ; j++) {  ///< Loop for all wells in problem;
   
	   int wellid, cell_wellid, wellfluidtype;
	   double wellrate;
	   
	   fwell1d >> cell_wellid;
	   fwell1d.ignore(256, '\n');
	   
	   fwell1d >> wellid;
	   fwell1d.ignore(256, '\n');
	   
	   fwell1d >> wellrate;
	   fwell1d.ignore(256, '\n');
	   
	   fwell1d >> wellfluidtype;
	   fwell1d.ignore(256, '\n');
	   
	   CWell1d * tempwell; ///< Temporary Well;
	   tempwell = new CWell1d(wellrate, wellid);
	   
	   cells[(cell_wellid - 1)].SetWell(tempwell);
	   tempwell = NULL;
   }

  ////////// Setting connections between neighbooring cells //////////
  for( int i = 1; i < (cellnumber - 1) ; i++ ) {
    cells[i].LeftCell(&cells[i-1]);
    cells[i].RightCell(&cells[i+1]);
  }
  cells[0].RightCell(&cells[1]);
  cells[cellnumber-1].LeftCell(&cells[cellnumber-2]);

  ////////// Setting Geometric Transmissibility in all cells //////////
  SetGTransmx();
  
  ////////// Setting Boundary Conditions //////////
  SetBoundConditions(&fgrid);
  */
}


CGrid2d1p::~CGrid2d1p()
{
  ///< Class destructor

  delete [] lenght;
  lenght = NULL;
  
  delete [] cells;
  cells = NULL;
  
  delete [] width;
  width = NULL;
  
  delete [] thickness;
  thickness = NULL;

}

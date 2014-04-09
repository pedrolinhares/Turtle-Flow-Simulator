//** @file CGrid1d.cpp */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz Barros.
 *  
 *  Class Author: Wagner Queiroz Barros.
 *  Date: 09/04/2014
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

CGrid2d1p::CGrid2d1p() : CGrid1d1p() {}

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
		
	//////////  Constructing CGrid2d  //////////
	fgrid >> xcells;
	fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
    
    fgrid >> ycells;
	fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
    
    int gridsize;
	gridsize = xcells*ycells; /// Size of grid;
    
    fgrid.ignore(256, '#');
    fgrid.ignore(256, '#'); 
    cellsID = new int * [ycells];
    for (int h=0; h < ycells; h++) {
        cellsID[h] = new int [xcells];
    }
   
   int auxcount = 0;
   for (int i=0; i<ycells; i++) {
   		for (int j=0; j<xcells; j++) {
   				fgrid >> cellsID[i][j]; /// Storing the connection between adjacent cells;
   				if (cellsID[i][j] != 0) { 
				    auxcount++; /// Counting the number of non-NULL cells; 
				    //cellsID[i][j] = auxcount; /// Replacing the number 1 with the cell ID "Only if the cells number is not given by user"
				} 
   		}
   }
      
   cellnumber = auxcount;
	        
    fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
	lenght = new double[xcells];
    for (int i=0; i < xcells; i++) {
        fgrid >> lenght[i];
    }
    

	fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
	width = new double[ycells];
    for (int i=0; i < ycells; i++) {
        fgrid >> width[i];
    }
    
    fgrid.ignore(256, '#');
    fgrid.ignore(256, '#');
    double trash;
    int thicknesscount = 0;
        
    thickness = new double[cellnumber];
    for (int i=0; i<ycells; i++) {
   		for (int j=0; j<xcells; j++) {
   			if (cellsID[i][j] != 0) {
   				fgrid >> thickness[thicknesscount];
   				thicknesscount++;
   			} else {
   				fgrid >> trash;
   			}
   		}
   	}
       
    //////////  Constructing CFluid  //////////
    fluidtype1 = _fluidtype;
    ConstructingCFluid();    
    
   //////////  Constructing CCell  //////////
   fgrid.ignore(256, '#');
   fgrid.ignore(256, '#');
   double *deepth; ///< Temporary array of cells deepth;
   deepth = new double[cellnumber];  
      
   int deepthcount = 0;
   for (int i=0; i<ycells; i++) {
   		for (int j=0; j<xcells; j++) {
   			if (cellsID[i][j] != 0) {
   				fgrid >> deepth[deepthcount];
   				deepthcount++;
   			} else {
   				fgrid >> trash;
   			}
   		}
   	} 
	
   fgrid.ignore(256, '#');
   fgrid.ignore(256, '#');
   int *block_cell_conection; ///< Temporary array of cenections between blocks and cells;
   block_cell_conection = new int[cellnumber];
   int inttrash;

   int blkcellcount = 0;
   for (int i=0; i<ycells; i++) {
   		for (int j=0; j<xcells; j++) {
   			if (cellsID[i][j] != 0) {
   				fgrid >> block_cell_conection[blkcellcount];
   				blkcellcount++;
   			} else {
   				fgrid >> inttrash;
   			}
   		}
   	}
   
   
   cells = new CCell2d [cellnumber]; ///< constructing an array of cells
   int cellcount = 0;
    
   for (int i=0; i<ycells; i++) {
   		for (int j=0; j<xcells; j++) {
   				if (cellsID[i][j] != 0) {
   						/// It means a non-NULL cell
   						CCell2d c2d(cellsID[i][j], deepth[cellcount], &block[block_cell_conection[cellcount]-1], fluid); ///< Constructing a cell, and connecting this cell with the matching block and fluid;
       					cells[cellcount] = c2d; ///< adding the cell in the cell arrray.
       					cellcount++;
   				}
   		}
   }
     
   /// Destructing Temporary files
   delete [] deepth;
   deepth = NULL;
       
   delete [] block_cell_conection;
   block_cell_conection = NULL;
   
  //////////  Constructing CWell2d  //////////  
  ConstructingCWell();
  
  ////////// Setting connections between neighbooring cells //////////
  SetCellConnections();
  
  ////////// Setting Geometric Transmissibility in all cells //////////
  SetGTransmX();
  SetGTransmX();
  
  ////////// Setting Boundary Conditions //////////
  //SetBoundConditions(&fgrid);
  fgrid.close();
  
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
  
  for (int h=0; h < xcells; h++) {
   		delete cellsID[h];
   }
   delete [] cellsID;

}

void CGrid2d1p::Print() {
  /// This function prints all the reservoir data on screen. It is used to debug the code, and it is not
  /// necessary in the final program.

    cout << "Number of Blocks in Domain: " << blknumber << "\n";
    cout << "Number of Cells in Domain: " << cellnumber << "\n";
    cout << "Number of Cells in x Direction: " << xcells << "\n";
    cout << "Number of Cells in y Direction: " << ycells << "\n";
    cout << "Number od Cells Connections in Domain: " << ConnectionsNumber() << "\n";
    
    cout << "Cells ID: \n";
    
    for (int i=0; i<ycells; i++) {
   		for (int j=0; j<xcells; j++) {
   			cout << cellsID[i][j] << "\t";
   		}
   		cout << endl;
   	}

    /// Printing the cells width of all cells in domain.
    for (int j=0; j < ycells ; j++ ){
       cout << "Cell Width: " << width[j] << "\n";
    }

    /// Printing the cells lenght of all cells in domain.
    for (int j=0; j < xcells ; j++ ){
        cout << "Cell Lenght: " << lenght[j] << "\n";
    }
    
    /// Printing the cells thickness of all cells in domain.
    for (int j=0; j < cellnumber ; j++ ){
        cout << "Cell Thickness: " << thickness[j] << "\n";
    }

  /// Printing all the Rock proprieties, for all Blocks in domain;
    for (int j=0; j < blknumber ; j++ ) {
    	block[j].Print();
    }

  /// Printing all the cell proprieties, for all cells in domain;
  for (int j=0; j < cellnumber; j++) {
    cells[j].Print();
      cout << endl;
  }

  fluid->Print(); ///< Printing the fluid proprieties.

}

void CGrid2d1p::SaveGridSolution(ofstream *fout, double time) {
  /// This function save all the reservoir data in disk.

  fout->precision(4);
  *fout << std::fixed;
  *fout <<  time;

  /// Printing all the cell pressures;
  for (int j=0; j < cellnumber; j++) {
    *fout << setw(17) << Pressure(j);
  }
  *fout << endl;
}

void CGrid2d1p::SaveWellSolution(std::ofstream *fout, int welln, double time) {
  ///< Function used to save the well solution in disk.

  for (int i=0; i<cellnumber; i++) {

    if (cells[i].WellId() == welln) {
      //cout.precision(4);
      fout->precision(4);
      *fout <<  std::fixed;
      *fout <<  time << setw(20);
      *fout << cells[i].Pressure() << setw(21);
      *fout << cells[i].WellCumulative_Phase1() << endl;
    }
  }
}

void CGrid2d1p::SetCellConnections() {
	/// Function that sets the connections between neighbooring cells.
	
   int cont = 0;
   int auxcellid;
   
   for( int i = 0; i < ycells ; i++ ) {
		for( int j = 0; j < xcells ; j++ ) {
			
			if (cellsID[i][j] != 0) {			
				///Setting the Left Cell
				if ( (j-1) >= 0 ) {
					auxcellid = cellsID[i][j-1];
					cells[cont].LeftCell( Cell(auxcellid) );
				} else {
					cells[cont].LeftCell( NULL );
				}
				
				///Setting the Right Cell
				if ( (j+1) < xcells ) {
					auxcellid = cellsID[i][j+1];
					cells[cont].RightCell( Cell(auxcellid) );
				} else {
					cells[cont].RightCell( NULL );
				}
				
				///Setting the Back Cell
				if ( (i-1) >= 0 ) {
					auxcellid = cellsID[i-1][j];
					cells[cont].BackCell( Cell(auxcellid) );
				} else {
					cells[cont].BackCell( NULL );
				}
				
				///Setting the Front Cell
				if ( (i+1) < ycells ) {
					auxcellid = cellsID[i+1][j];
					cells[cont].FrontCell( Cell(auxcellid) );
				} else {
					cells[cont].FrontCell( NULL );
				}
				
			cont++;
			}
		}
   }
    
}

void CGrid2d1p::SetBoundConditions(ifstream *fgrid) {
  /// Function used to set the boundary condition to all boundary cells in grid.
  
	/// Setting Down Boundary Condition
	for( int i = 0; i < xcells ; i++ ) {
        cells[i].FrontCell(NULL);        
 	}
 	
 	/// Setting Left Boundary Condition
 	for ( int j = 0; j < ycells; j++ ) {
 		cells[(j*xcells)].LeftCell(NULL);
 	}
 	
 	/// Setting Up Boundary Condition
 	for( int i = 0; i < xcells ; i++ ) {
        cells[(cellnumber - i - 1)].BackCell(NULL);        
 	}
 	
 	/// Setting Right Boundary Condition
 	for ( int j = 1; j <= ycells; j++ ) {
 		cells[(xcells)*j - 1].RightCell(NULL);	
 	}
 	
}

void CGrid2d1p::SetGTransmX() {
  /// Setting the Geometric Transmissibilities, for all cells in domain, in direction x.
  /// The Geometric Transmissibilities are calculated only once, and are stored in all cells,
  /// avoiding waste of processing time. They are calculated based on an harmonic media between
  /// adjacent cells.
	
   double Ai1, Ai0, perm1, perm0, gtr;
   int xpos, ypos;
   
	for( int i = 0; i < cellnumber ; i++ ) {
			
		if (cells[i].RightCell() == NULL) {
			cells[i].GTransmX(0);
		}
		else {
			
			xpos = CellXPosition(cells[i].CellId()); ///< Getting the x position of the cell;
			ypos = CellYPosition(cells[i].CellId()); ///< Getting the y position of the cell;
		
			Ai0 = thickness[i]*width[ypos];
	    	Ai1 = thickness[i+1]*width[ypos];
	    	
	    	perm0 = cells[i].Permeability_x();
		    perm1 = cells[i].RightCell()->Permeability_x();
		
		    gtr = 2*betac*Ai1*Ai0*perm1*perm0/(Ai0*perm0*lenght[xpos+1]+Ai1*perm1*lenght[xpos]);
		    cells[i].GTransmX(gtr);
				
		}
			
    }
				
}

void CGrid2d1p::SetGTransmY() {
  /// Setting the Geometric Transmissibilities, for all cells in domain, in direction y;
  /// The Geometric Transmissibilities are calculated only once, and are stored in all cells,
  /// avoiding waste of processing time. They are calculated based on an harmonic media between
  /// adjacent cells.
  
   double Ai1, Ai0, perm1, perm0, gtr;
   int xpos, ypos, frontcellid, frontposition;
   
	for( int i = 0; i < cellnumber ; i++ ) {
			
		if (cells[i].FrontCell() == NULL) {
			cells[i].GTransmY(0);
		}
		else {
			
			frontcellid = cells[i].FrontCell()->CellId();  ///< Getting the ID of the front cell;
			frontposition = CellPositioninGrid(frontcellid); ///< Getting the position of the front cell;
						
			xpos = CellXPosition(cells[i].CellId()); ///< Getting the x position of the cell;
			ypos = CellYPosition(cells[i].CellId()); ///< Getting the y position of the cell;
		
	    	Ai0 = thickness[i]*lenght[xpos];
	    	Ai1 = thickness[frontposition]*lenght[xpos];
	    	
	    	perm0 = cells[i].Permeability_y();
		    perm1 = cells[i].FrontCell()->Permeability_y();
		
		    gtr = 2*betac*Ai1*Ai0*perm1*perm0/(Ai0*perm0*width[ypos+1]+Ai1*perm1*width[ypos]);
		    cells[i].GTransmY(gtr);
				
		}
			
    }
	
   

}

void CGrid2d1p::InitiateSolution(double pref, double href) {
  /// This function is used to initiate the pressure in all cells of domain.
  /// The solution is initiated based on the hydrostatic pressure, in all reservoir.

  double press, erro, erromax;

    do {

        for (int i=0 ; i<cellnumber ; i++) {

            press = pref +  cells[i].Weight()*(cells[i].Deepth() - href); ///< Setting the hydrostatic pressure;

            erro=abs(cells[i].Pressure() - press)/(press);  ///< Calculating the error in the pressure variation.

            if (i==0) { erromax = erro; }
            else {
                if (erromax < erro) { erromax = erro;};
            }

            cells[i].Pressure(press); ///< Setting the initial pressure in all cells;
            cells[i].BackPressure(press); ///< Setting the initial back pressure in all cells;
        }

    } while (erromax > 0.1); ///< 0.1 is the precision of the initialization. Maybe it will be set by the user in future.
}


double CGrid2d1p::RightTrasmX( int celln ) {
  /// This function return the right transmissibility of a specif cell.

  if (cells[celln].RightCell() == NULL) { return 0; }
  
  return cells[celln].RightTransmX();
    
}

double CGrid2d1p::LeftTrasmX( int celln ) {
  /// This function return the right transmissibility of a specif cell.

  if (cells[celln].LeftCell() == NULL) { return 0; }
  
  return cells[celln].LeftCell()->RightTransmX();
    
}


double CGrid2d1p::RightGravityTransmX( int celln ){
  /// This function return the right gravitational transmissibility of a specif cell.
  
  if (cells[celln].RightCell() == NULL) { return 0; }
  
  return cells[celln].RightGravityTransmX();
    
}

double CGrid2d1p::LeftGravityTransmX( int celln ){
  /// This function return the right gravitational transmissibility of a specif cell.
  
  if (cells[celln].LeftCell() == NULL) { return 0; }
  
  return cells[celln].LeftCell()->RightGravityTransmX();
    
}

double CGrid2d1p::RightTransmXDer( int celln ) { 
 	///< Returns the derivative of the right transm. in relation of the right cell pressure for celln;
 	
 	if (cells[celln].RightCell() == NULL) { return 0; }
 	
 	return cells[celln].RightTransmXDer(); 

}

double CGrid2d1p::LeftTransmXDer( int celln ) { 
 	///< Returns the derivative of the right transm. in relation of the right cell pressure for celln;
 	
 	if (cells[celln].LeftCell() == NULL) { return 0; }
 	
    return cells[celln].LeftCell()->RightTransmXDer(); 
    
}

double CGrid2d1p::RightGravityTransmXDer( int celln )  { 
	/// Returns the derivative of the right gravitational transmissibility in relation of the right cell pressure;
	
	if (cells[celln].RightCell() == NULL) { return 0; }
	
	return cells[celln].RightGravityTransmXDer();
	
} 

double CGrid2d1p::LeftGravityTransmXDer( int celln )  { 
	/// Returns the derivative of the right gravitational transmissibility in relation of the right cell pressure;
	
	if (cells[celln].LeftCell() == NULL) { return 0; }
	
	return cells[celln].LeftCell()->RightGravityTransmXDer(); 
	
} 

double CGrid2d1p::Gamma( int celln ) {
	 ///This function returns the gamma factor of a specific cell in domain;
	 
	 return cells[celln].Gamma(Volume(celln));
	 
}

double CGrid2d1p::FrontTrasmY( int celln ) {
  /// This function return the front transmissibility of a specif cell.

  if (cells[celln].FrontCell() == NULL) { return 0; }
  
  return cells[celln].FrontTransmY();
    
}

double CGrid2d1p::BackTrasmY( int celln ) {
  /// This function return the right transmissibility of a specif cell.

  if (cells[celln].BackCell() == NULL) { return 0; }
  
  return cells[celln].BackCell()->FrontTransmY();
    
}

double CGrid2d1p::FrontGravityTransmY( int celln ){
  /// This function return the right gravitational transmissibility of a specif cell.
  
  if (cells[celln].FrontCell() == NULL) { return 0; }
  
  return cells[celln].FrontGravityTransmY();
    
}

double CGrid2d1p::BackGravityTransmY( int celln ){
  /// This function return the right gravitational transmissibility of a specif cell.
  
  if (cells[celln].BackCell() == NULL) { return 0; }
  
  return cells[celln].BackCell()->FrontGravityTransmY();
    
}


double CGrid2d1p::GammaDer( int celln ) {
	  /// Returns the derivative of the gamma function in relation of the cell pressure;
	  
	  return cells[celln].GammaDer(Volume(celln));
	  
}

double CGrid2d1p::Pressure( int celln ) {
    /// This function returns the atual pressure of a specific cell in domain;

    return cells[celln].Pressure();
}

double CGrid2d1p::RightPressure( int celln ) {
    /// This function returns the atual pressure of a right cell in relation of a specific cell in domain;

    if (cells[celln].RightCell() == NULL ) { return 0; }
	return cells[celln].RightCell()->Pressure();
}

double CGrid2d1p::LeftPressure( int celln ) {
    /// This function returns the atual pressure of a left cell in relation of a specific cell in domain;

    if (cells[celln].LeftCell() == NULL ) { return 0; }
	return cells[celln].LeftCell()->Pressure();
}

double CGrid2d1p::Deepth( int celln ) {
    /// This function returns the Deepth of a specific cell in domain;
    
    return cells[celln].Deepth();
}

double CGrid2d1p::RightDeepth( int celln ) {
    /// This function returns the deepth of a right cell in relation of a specific cell in domain;

    if (cells[celln].RightCell() == NULL ) { return 0; }
	return cells[celln].RightCell()->Deepth();
}

double CGrid2d1p::LeftDeepth( int celln ) {
    /// This function returns the deepth of a left cell in relation of a specific cell in domain;

    if (cells[celln].LeftCell() == NULL ) { return 0; }
	return cells[celln].LeftCell()->Deepth();
}


void CGrid2d1p::ConstructingCFluid() {
    /// Construct the fluid in grid in domain;
    
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
    
}

double CGrid2d1p::Volume( int celln) {
  /// This function calculates the volume of a specific cell in the grid.
  /// It is used to avoid storing this information in the cell.

  return width[celln]*thickness[celln]*lenght[celln];
}

void CGrid2d1p::Iterationni(double *Xni) {
  /// This function makes the linear iteration "ni Iteration" in all cells in reservoir.
  /// The linear iteration is made for correct the atual pressure in reservoir.

  for ( int j=0 ; j < cellnumber ; j++) {
    cells[j].Pressure(Xni[j]);
  }
}

void CGrid2d1p::Iterationt(double deltat) {
  /// This function makes the time iteration in all cells in reservoir.
  /// The time iteration is made advance the simulation in time, correcting the back pressure.

  double bpress;

  /// Iterating the cell pressure
  for ( int j=0 ; j < cellnumber ; j++) {

    bpress = cells[j].Pressure();
    cells[j].BackPressure(bpress);
  }

  /// Iterating the well cumulative volume
  for ( int j=0 ; j < cellnumber ; j++) {
    if (cells[j].WellId() != 0) { cells[j].IterationtWell(deltat); }
  }
}

void CGrid2d1p::ConstructingCWell() {
	/// This function construct and connects all wells in domain.
	
	ifstream fwell2d(ARQ_WELL2D_FILE.c_str());
  
    if (fwell2d.fail())
       {
            cerr << "There is no well data." << endl;
            exit(EXIT_FAILURE);
       }
   
   int wellsnumber;
   fwell2d >> wellsnumber;
   fwell2d.ignore(256, '\n');
   
   for (int j = 0 ; j < wellsnumber ; j++) {  ///< Loop for all wells in problem;
   
	   int wellid, rowid, columnid;
	   double wellrate;
	   
	   fwell2d >> rowid;
	   fwell2d.ignore(256, '\n');
	   
	   fwell2d >> columnid;
	   fwell2d.ignore(256, '\n');
	   
	   fwell2d >> wellid;
	   fwell2d.ignore(256, '\n');
	   
	   fwell2d >> wellrate;
	   fwell2d.ignore(256, '\n');
	   	   
	   CWell2d * tempwell; ///< Temporary Well;
	   tempwell = new CWell2d(wellrate, wellid);
	   
	   int tempcellid;
	   tempcellid = cellsID[rowid - 1][columnid - 1];
	   if (tempcellid == 0) {
            cerr << "Cannot be sent a well in a NULL cell." << endl;
            exit(EXIT_FAILURE);
       }
       
       Cell(tempcellid)->SetWell(tempwell);
	   tempwell = NULL;
   }
	
}

 int CGrid2d1p::WellNumbers() {
  ///< Return the number of wells in domain.

  int cont = 0;

  for ( int j = 0; j < cellnumber ; j++) {
    if ( cells[j].WellRate() != 0) { cont++; }
  }

  return cont;
}

CCell2d * CGrid2d1p::Cell( int cellid )  {
    ///< Return a pointer to the cell which cell ID is cellid;
    for (int i=0; i<cellnumber; i++) {
    	if (cells[i].CellId() == cellid) { return &cells[i]; }
    }
    
    return NULL;
 
}

int CGrid2d1p::CellXPosition(int _cellid) {
	///this function returns the x position of the cell _cellid
	///in the grid of cell connections.
	///if the cellid does not exist, this function returns -1.
	///NOTE: the first position starts with 0 in c++.
	
	for (int i=0; i<ycells; i++) {
		for (int j=0; j<xcells; j++) {
			if(cellsID[i][j] == _cellid) { return j;}
		}
	}
	
	return -1;
}

int CGrid2d1p::CellYPosition(int _cellid) {
	///this function returns the y position of the cell _cellid
	///in the grid of cell connections.
	///if the cellid does not exist, this function returns -1.
	///NOTE: the first position starts with 0 in c++.
	
	for (int i=0; i<ycells; i++) {
		for (int j=0; j<xcells; j++) {
			if(cellsID[i][j] == _cellid) { return i;}
		}
	}
	
	return -1;
}

int CGrid2d1p::CellPositioninGrid(int _cellid) {
	 ///Returns the cell position of the cell with _cellid;
	 ///Renember that this software allocates all cells in an array, 
	 ///so this function returns this arra index.
	 ///if the cellid does not exist, this function returns -1.
	 ///NOTE: the first position starts with 0 in c++.
	 
	 for (int index=0; index<cellnumber; index++) {
	 	if (cells[index].CellId() == _cellid) { return index; }
	 }
	 
	 return -1;
	 
}

int CGrid2d1p::ConnectionsNumber() {
	///< This Function returns the number of connections among cells in the grid.
	
	int connections = 0; /// Connection counter;
	
	for (int i=0; i<ycells; i++) {
		for (int j=0; j<xcells; j++) {
			if (cellsID[i][j] != 0) {
				///Left Connection
				if (j>0) {
					if(cellsID[i][j-1] != 0) { connections++;}		
				}
				
				///Right Connection
				if (j<(xcells-1)) {
					if(cellsID[i][j+1] != 0) { connections++;}		
				}
				
				///Back Connection
				if (i>0) {
					if(cellsID[i-1][j] != 0) { connections++;}		
				}
				
				///Front Connection
				if (i<(ycells-1)) {
					if(cellsID[i+1][j] != 0) { connections++;}		
				}
			}
		}
	}
	
	return connections/2;  ///< The connections were counted twice;
}

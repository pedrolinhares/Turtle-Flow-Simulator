//** @file CGrid1d.cpp */
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
#include "filename_definitions.h"
#include "CGrid1d1p.h"

using namespace std;
using namespace filename_definitions;

CGrid1d1p::CGrid1d1p(int _fluidtype) :CGrid()
{
  /// class constructor
  
	ifstream fgrid(ARQ_GRID1d_FILE.c_str());
  
    if (fgrid.fail())
       {
            cerr << "There is no grid data." << endl;
            exit(EXIT_FAILURE);
       }

    //////////  Constructing CBlock  //////////
    fgrid >> blknumber;
    fgrid.ignore(256, '\n');
    
    block = new CBlock[blknumber];
	
	{
	    int blkid;
	    double rockcomp, rockperm, rockpor, refpres;
	    
	     for(int i = 0; i < blknumber ; i++) {
	       
		   fgrid >> blkid;	
	       fgrid.ignore(256, '\n');	
	       
	       fgrid >> rockcomp;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> rockperm;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> rockpor;	
	       fgrid.ignore(256, '\n');
	       
	       fgrid >> refpres;	
	       fgrid.ignore(256, '\n');
	       
	       CBlock blk(blkid, rockcomp, rockperm, rockpor, refpres); ///< Constructing a block;
	
	       block[i]=blk; ///< adding the constructed block in the block array;
	     }
	     
	}
	
	//////////  Constructing CGrid1d  //////////
	fgrid >> cellnumber;
    fgrid.ignore(256, '\n');
    
    width = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> width[i];
        fgrid.ignore(256, '\n');
    }
    
    lenght = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> lenght[i];
        fgrid.ignore(256, '\n');
    }
    
    thickness = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> thickness[i];
        fgrid.ignore(256, '\n');
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

   double *deepth; ///< Temporary array of cells deepth;
   deepth = new double[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> deepth[i];
        fgrid.ignore(256, '\n');
    }
   
   int *block_cell_conection; ///< Temporary array of cenections between blocks and cells;
   block_cell_conection = new int[cellnumber];
    for (int i=0; i < cellnumber; i++) {
        fgrid >> block_cell_conection[i];
        fgrid.ignore(256, '\n');
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
  
}


CGrid1d1p::~CGrid1d1p()
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

void CGrid1d1p::Print() {
  /// This function prints all the reservoir data on screen. It is used to debug the code, and it is not
  /// necessary in the final program.

    cout << "Number of Blocks in Domain: " << blknumber << "\n";
    cout << "Number of Cells in Domain: " << cellnumber << "\n";

    /// Printing the cells width of all cells in domain.
    for (int j=0; j < cellnumber ; j++ ){
        cout << "Cell Width: " << width[j] << "\n";
    }

    /// Printing the cells lenght of all cells in domain.
    for (int j=0; j < cellnumber ; j++ ){
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

void CGrid1d1p::SaveGridSolution(ofstream *fout, double time) {
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

void CGrid1d1p::SaveWellSolution(std::ofstream *fout, int welln, double time) {
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

void CGrid1d1p::SetBoundConditions(ifstream *fgrid) {
  /// Function used to set the boundary condition to all boundary cells in grid.
  
	/// Left Boundary Condition ///
	int leftbc_type;
	double leftbc_value;
	  
	*fgrid >> leftbc_type;
	fgrid->ignore(256, '\n');
	
	*fgrid >> leftbc_value;
	fgrid->ignore(256, '\n');
    
    switch (leftbc_type) {
      case 0: {
      if (leftbc_value == 0) { ///Closed system case
        cells[0].LeftCell(NULL);
        }
      break;
      }
      
      case 1: {   ///Specified Pressure Case

        CCell1d *leftcell;
        leftcell = new CCell1d;

        *leftcell = cells[0]; ///< Copying the properties of the first element;

        leftcell->Pressure(leftbc_value); /// Setting the specified pressure;
        leftcell->RightCell(&cells[0]); /// Conecting the boundary condition with the left block;
        leftcell->LeftCell(NULL);
        
        /// Setting the left transmissibility ///
        double Ai0, perm0, gtr;
        
        Ai0 = thickness[0]*width[0];
        perm0 = cells[0].Permeability();
        gtr = 2*betac*Ai0*Ai0*perm0*perm0/(Ai0*perm0*lenght[0]);
        leftcell->GTransmx(gtr);

        cells[0].LeftCell(leftcell);
        break;
      }
    }

	/// Right Boundary Condition ///
	int rightbc_type;
	double rightbc_value;
	  
	*fgrid >> rightbc_type;
	fgrid->ignore(256, '\n');
	
	*fgrid >> rightbc_value;
	fgrid->ignore(256, '\n');
  
  switch (rightbc_type) {
      case 0: {
      if (rightbc_value == 0) { ///Closed system case
        cells[(cellnumber - 1)].RightCell(NULL);
      }
        break;
        }
      case 1: {   ///Specified Pressure Case

        CCell1d *rightcell;
        rightcell = new CCell1d;

        *rightcell = cells[(cellnumber - 1)]; ///< Copying the properties of the last element;

        rightcell->Pressure(rightbc_value); /// Setting the specified pressure;
        rightcell->RightCell(NULL); /// Conecting the boundary condition with the right block;
        rightcell->LeftCell(&cells[(cellnumber - 1)]);
        
        /// Setting the right transmissibility ///
        double Ai0, perm0, gtr;
        
        Ai0 = thickness[(cellnumber - 1)]*width[(cellnumber - 1)];
        perm0 = cells[(cellnumber - 1)].Permeability();
        gtr = 2*betac*Ai0*Ai0*perm0*perm0/(Ai0*perm0*lenght[(cellnumber - 1)]);
        cells[(cellnumber - 1)].GTransmx(gtr);

        cells[(cellnumber - 1)].RightCell(rightcell);
        break;
      }
    }

}

void CGrid1d1p::SetGTransmx() {
  /// Setting the Geometric Transmissibilities, for all cells in domain.
  /// The Geometric Transmissibilities are calculated only once, and are stored in all cells,
  /// avoiding waste of processing time. They are calculated based on an harmonic media between
  /// adjacent cells.

   double Ai1, Ai0, perm1, perm0, gtr;

    for ( int j=0 ; j < (cellnumber - 1) ; j++) {

      Ai0 = thickness[j]*width[j];
      Ai1 = thickness[j+1]*width[j+1];
      
      perm0 = cells[j].Permeability();
      perm1 = cells[j].RightCell()->Permeability();
      
      gtr = 2*betac*Ai1*Ai0*perm1*perm0/(Ai0*perm0*lenght[j+1]+Ai1*perm1*lenght[j]);
      cells[j].GTransmx(gtr);
  }
}

void CGrid1d1p::InitiateSolution(double pref, double href) {
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

double CGrid1d1p::RightTrasmx( int celln ) {
  /// This function return the right transmissibility of a specif cell.
  /// if celln == -1, Left Boundary condition case.
    /// if celln == cellnumber, Right Boundary condition case.

  /// Left Boudary Condition
  if (celln == -1) {
        if (cells[0].LeftCell() == NULL) { return 0; }
        else{ return cells[0].LeftCell()->RightTransmx(); }
    }

  /// Right Boudary Condition
    if (celln == cellnumber) {
        if (cells[cellnumber - 1].RightCell() == NULL) { return 0; }
        else{ return cells[cellnumber - 1].RightTransmx(); }
    }

    return cells[celln].RightTransmx();
}

double CGrid1d1p::RightGravityTransmx( int celln ){
  /// This function return the right gravitational transmissibility of a specif cell.
  /// if celln == -1, Left Boundary condition case.
    /// if celln == cellnumber, Right Boundary condition case.

  /// Left Boudary Condition
  if (celln == -1) {
        if (cells[0].LeftCell() == NULL) { return 0; }
        else{ return cells[0].LeftCell()->RightGravityTransmx(); }
    }

  /// Right Boudary Condition
    if (celln == cellnumber) {
        if (cells[cellnumber - 1].RightCell() == NULL) { return 0; }
        else{ return cells[cellnumber - 1].RightGravityTransmx(); }
    }

    return cells[celln].RightGravityTransmx();
}

double CGrid1d1p::Pressure( int celln ) {
    /// This function returns the atual pressure of a specific cell in domain;
    /// if celln == -1, Left Boundary condition case.
    /// if celln == cellnumber, Right Boundary condition case.

    if (celln == -1) {
        if (cells[0].LeftCell() == NULL) { return 0; }
        else{ return cells[0].LeftCell()->Pressure(); }
    }

    if (celln == cellnumber) {
        if (cells[cellnumber - 1].RightCell() == NULL) { return 0; }
        else{ return cells[cellnumber - 1].RightCell()->Pressure(); }
    }

    return cells[celln].Pressure();
}

double CGrid1d1p::Deepth( int celln ) {
    /// This function returns the Deepth of a specific cell in domain;
    /// if celln == -1, Left Boundary condition case.
    /// if celln == cellnumber, Right Boundary condition case.

    if (celln == -1) {
        if (cells[0].LeftCell() == NULL) { return 0; }
        else{ return cells[0].LeftCell()->Deepth(); }
    }

    if (celln == cellnumber) {
        if (cells[cellnumber - 1].RightCell() == NULL) { return 0; }
        else{ return cells[cellnumber - 1].RightCell()->Deepth(); }
    }

    return cells[celln].Deepth();
}

double CGrid1d1p::Volume( int celln) {
  /// This function calculates the volume of a specific cell in the grid.
  /// It is used to avoid storing this information in the cell.

  return width[celln]*thickness[celln]*lenght[celln];
}

void CGrid1d1p::Iterationni(double *Xni) {
  /// This function makes the linear iteration "ni Iteration" in all cells in reservoir.
  /// The linear iteration is made for correct the atual pressure in reservoir.

  for ( int j=0 ; j < cellnumber ; j++) {
    cells[j].Pressure(Xni[j]);
  }
}

void CGrid1d1p::Iterationt(double deltat) {
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

 int CGrid1d1p::WellNumbers() {
  ///< Return the number of wells in domain.

  int cont = 0;

  for ( int j = 0; j < cellnumber ; j++) {
    if ( cells[j].WellRate() != 0) { cont++; }
  }

  return cont;
}


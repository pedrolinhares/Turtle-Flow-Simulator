//** @file CGrid1d.cpp */

#include "kernel_definitions.h"
#include "CGrid1d.h"

using namespace std;
using namespace definitions;

CGrid1d::CGrid1d(CDataControl *_dcontrol) :CGrid(_dcontrol)
{
  /// class constructor
  double *data;

    //////////  Constructing CGrid1d  //////////

    data = dcontrol->DataCGrid1d(ARQ_RESERVOIR_FILE); ///< Getting Grid data;

    blknumber = (int) data[0];
    cellnumber = (int) data[1];
    width = data[2];
    fluidtype1 = (int) data[3];

    lenght = new double[cellnumber];

    for(int i = 4; i <  (cellnumber+4) ; i++) {
        lenght[(i-4)]=data[i];
    }

    delete [] data;
    data = NULL;

    //////////  Constructing CBlock  //////////

    block = new CBlock[blknumber];

     for(int i = 0; i < blknumber ; i++) {

           data = dcontrol->DataCBlock(ARQ_BLOCKS_FILE, i); ///< Getting data of Block i;
           CBlock blk(data); ///< Constructing a block;

       block[i]=blk; ///< adding the constructed block in the block array;
       delete [] data;
       data = NULL;
   }

   //////////  Constructing CFluid  //////////

   switch (fluidtype1) {
    case 1: { ///< Case 1 represents a water simulation
        data = dcontrol->DataCFluid(ARQ_WATER_FILE); ///< Getting the water data;
        if (data == NULL) {
        cerr << "There is no water data." << endl;
        // cin.ignore();
        exit(EXIT_FAILURE);
      }
        fluid = new CWater(data); ///< Constructing the fluid object;
      break;
      }
    case 2: {
        data = dcontrol->DataCFluid(ARQ_OIL_FILE); ///< Getting the oil data;
        if (data == NULL) {
        cerr << "There is no oil data." << endl;
        // cin.ignore();
        exit(EXIT_FAILURE);
      }
        fluid = new COil(data); ///< Constructing the fluid object;
      break;
      }
    case 3: {
        data = dcontrol->DataCFluid(ARQ_GAS_FILE);  ///< Getting the gas data;
        if (data == NULL) {
          cerr << "There is no gas data." << endl;
          // cin.ignore();
          exit(EXIT_FAILURE);
        }
        fluid = new CGas(data); ///< Constructing the gas object;
        break;
      }
    }

   delete [] data;
   data = NULL;

    //////////  Constructing CCell  //////////

   cells = new CCell1d[cellnumber]; ///< constructing an array of cells;

   for( int i=0; i < cellnumber ; i++ ) {

    data = dcontrol->DataCell1d(ARQ_CELL1D_FILE, i);  ///< Getting the data of the cell i;

    int idb;
    idb = (int) (data[3] - 1); ///< Position of the associated block in array; (If idb == -1, the block is NULL,
    /// but doesn't have NULL blocks in one-dimensional simulations.)

    CCell1d c1d(data, &block[idb], fluid); ///< Constructing a cell, and connecting this cell with the matching block and fluid;
    cells[i] = c1d; ///< adding the cell in the cell arrray.

    delete [] data;
    data = NULL;
   }

    ///< Setting connections between neighbooring cells
  for( int i=1; i < (cellnumber - 1) ; i++ ) {
    cells[i].LeftCell(&cells[i-1]);
    cells[i].RightCell(&cells[i+1]);
  }
  cells[0].RightCell(&cells[1]);
  cells[cellnumber-1].LeftCell(&cells[cellnumber-2]);

   SetGTransmx();
   SetBoundConditions();


   //////////  Constructing CWells  //////////

   int cellidw, index, wid;
   double wrate;

   data = dcontrol->DataCWell1d(ARQ_WELL1D_FILE); ///< Getting well data;

     for (int j =1 ; j<=data[0] ; j++) { ///< Loop for all wells in problem;

        index = (j-1)*4;

      cellidw = (int) data[index+1]; ///< Id of cell owning the well j;
      wid = (int) data[index+2];  ///< Well Id;
      wrate =   data[index+4]; ///< Flow rate of the well j.


        cells[cellidw-1].WellRate(wrate, wid); ///< Connecting a well j, in the cell.

     }

   InitiateSolution(); ///< Initiating the solution in all cells of domain.

}


CGrid1d::~CGrid1d()
{
  ///< Class destructor

  delete [] lenght;
  lenght = NULL;
  delete [] cells;
  cells = NULL;

}

void CGrid1d::PrintData() {
  /// This function prints all the reservoir data on screen. It is used to debug the code, and it is not
  /// necessary in the final program.

    cout << "Number of Blocks in Domain: " << blknumber << "\n";
    cout << "Number of Cells in Domain: " << cellnumber << "\n";
    cout << "Width of all Cells in Domain: " << width << "\n";

  /// Printing the cells lenght of all cells in domain.
    for (int j=0; j < cellnumber ; j++ ){
        cout << "Cell Lenght: " << lenght[j] << "\n";
    }

  /// Printing all the Rock proprieties, for all Blocks in domain;
    for (int j=0; j < blknumber ; j++ ) {
     block[j].PrintBlock();
    }

  /// Printing all the cell proprieties, for all cells in domain;
  for (int j=0; j < cellnumber; j++) {
    cells[j].PrintCell();
      cout << endl;
  }

  fluid->PrintFluid(); ///< Printing the fluid proprieties.

}

void CGrid1d::SaveGridSolution(ofstream *fout, double time) {
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

void CGrid1d::SaveWellSolution(std::ofstream *fout, int welln, double time) {
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

void CGrid1d::SetBoundConditions() {
  /// Function used to set the boundary condition to all boundary cells in grid.

  double *data;
    data = dcontrol->DataBoundCond1d(ARQ_BOUNDARY_FILE); ///< Getting Boundary Conditions data;

    /// Left Boundary Condition ///
    switch ((int) data[0]) {
      case 0: {
      if (data[1] == 0) { ///Closed system case
        cells[0].LeftCell(NULL);
      }
        break;
        }
      case 1: {   ///Specified Pressure Case

        CCell1d *leftcell;
        leftcell = new CCell1d;

        *leftcell = cells[0]; ///< Copying the properties of the first element;

        leftcell->Pressure(data[1]); /// Setting the specified pressure;
        leftcell->RightCell(&cells[0]); /// Conecting the boundary condition with the left block;
        leftcell->LeftCell(NULL);

        cells[0].LeftCell(leftcell);
        break;
      }
    }

  /// Right Boundary Condition ///
  switch ((int) data[2]) {
      case 0: {
      if (data[3] == 0) { ///Closed system case
        cells[(cellnumber - 1)].RightCell(NULL);
      }
        break;
        }
      case 1: {   ///Specified Pressure Case

        CCell1d *rightcell;
        *rightcell = cells[(cellnumber - 1)]; ///< Copying the properties of the last element;

        rightcell->Pressure(data[3]); /// Setting the specified pressure;
        rightcell->RightCell(NULL); /// Conecting the boundary condition with the right block;
        rightcell->LeftCell(&cells[(cellnumber - 1)]);

        cells[(cellnumber - 1)].RightCell(rightcell);
        break;
      }
    }

  delete [] data;
  data = NULL;
}

void CGrid1d::SetGTransmx() {
  /// Setting the Geometric Transmissibilities, for all cells in domain.
  /// The Geometric Transmissibilities are calculated only once, and are stored in all cells,
  /// avoiding waste of processing time. They are calculated based on an harmonic media between
  /// adjacent cells.

   double Ai1, Ai0, perm1, perm0, gtr;

    for ( int j=0 ; j < (cellnumber - 1) ; j++) {

      Ai1 = cells[j].RightCell()->Thickness()*width;
      Ai0 = cells[j].Thickness()*width;

      perm1 = cells[j].RightCell()->Permeability();
      perm0 = cells[j].Permeability();

      gtr = 2*betac*Ai1*Ai0*perm1*perm0/(Ai0*perm0*lenght[j+1]+Ai1*perm1*lenght[j]);
      cells[j].GTransmx(gtr);
  }
}

void CGrid1d::InitiateSolution() {
  /// This function is used to initiate the pressure in all cells of domain.
  /// The solution is initiated based on the hydrostatic pressure, in all reservoir.

  double *data;
    data = dcontrol->DataInitiate1d(ARQ_INIT_FILE); ///< Getting the initialization data;

    double pref, href;
    pref = data[0]; ///< Reference pressure;
    href = data[1]; ///< Reference Height.

    delete [] data;
    data = NULL;

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

double CGrid1d::RightTrasmx( int celln ) {
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

double CGrid1d::RightGravityTransmx( int celln ){
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

double CGrid1d::Pressure( int celln ) {
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

double CGrid1d::Deepth( int celln ) {
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

double CGrid1d::Volume( int celln) {
  /// This function calculates the volume of a specific cell in the grid.
  /// It is used to avoid storing this information in the cell.

  return width*cells[celln].Thickness()*lenght[celln];
}

void CGrid1d::Iterationni(double *Xni) {
  /// This function makes the linear iteration "ni Iteration" in all cells in reservoir.
  /// The linear iteration is made for correct the atual pressure in reservoir.

  for ( int j=0 ; j < cellnumber ; j++) {
    cells[j].Pressure(Xni[j]);
  }
}

void CGrid1d::Iterationt(double deltat) {
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

 int CGrid1d::WellNumbers() {
  ///< Return the number of wells in domain.

  int cont = 0;

  for ( int j = 0; j < cellnumber ; j++) {
    if ( cells[j].WellRate() != 0) { cont++; }
  }

  return cont;
}


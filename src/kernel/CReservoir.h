//** @file CReservoir.h */

#ifndef CReservoir_h
#define CReservoir_h

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>

#include "CDataControl.h"
#include "CGrid.h"
#include "CGrid1d.h"

#include "CModelType.h"
#include "CSinglePhase1d.h"

#include "CSolver.h"
#include "CTrid.h"

/**
 * The CReservoir is the main class of the project, responsible of manage all the simulation.
 * This class is responsible to create all other classes, and to manage the simulation flow.
 */

class CReservoir {
private:
    //////////  Reservoir Parameters  //////////

  CDataControl *dcontrol; ///< Pointer to the reservoir data;
  int dimtype; ///< Dimension of the problem: 1 - 1D, 2 - 2D, 3 - 3D, 4 - radial;
  CGrid *grid; ///< Pointer to the reservoir grid;
  CModelType *model; ///< Pointer to the model that describes the reservoir behaviour;
  int cpoints; //Number of lines of linear equation system, and of cells in reservaoir;

  ///////////  Numerical Parameters  /////////
  /// "the solver is used to solve this equation system: A * Xni = B" ///

  CSolver *solver; ///< Pointer to numerical solver;
  double **A; ///< Coefficient Matrix
    double *B; ///< Free Vector
      double *Xni; ///< Solution Vector

  double deltat; ///< Delta time of simulation
  double finalt; ///< Final simulation time
  int maxni; ///< Max number of iterations in linearization
  double erroni; ///< Precision of linearization

  ///////////  Output Parameters  /////////
  std::ofstream grid_data; ///< Out put file for the pressure in all cell points;
  std::ofstream *well_data; ///< Out put file for the pressure in all cell points;
  void OutPutInitiate(); ///< This function is used to initiate the output files;

public:
  CReservoir(CDataControl *_dcontrol);
  ~CReservoir();
  void Run(); ///< Function used to manage the reservoir simulation

};

#endif // CReservoir_h

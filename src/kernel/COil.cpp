//** @file COil.cpp */

#include <cstdlib>
#include "COil.h"

using namespace std;

COil::COil()
{
  /// Oil constructor;
}

COil::COil(double *data)
{
  /// Overloaded oil constructor.
  /// This constructor constructs the oil class using the data array from DataControl.


  pvtpoints = (int) data[0];

  pressure = new double[pvtpoints]; ///< Creating the pressure array from data;
  fvf = new double[pvtpoints]; ///< Creating the FVF array from data;
  weight = new double[pvtpoints]; ///< Creating the specific weight array from data;
  viscosity = new double[pvtpoints]; ///< Creating the viscosity array from data;


  for (int i=0 ; i < pvtpoints ; i++) {

      pressure[i] = data[4*i+1];
      fvf[i] = data[4*i+2];
      weight[i] = data[4*i+3];
      viscosity[i] = data[4*i+4];

  }

}

COil::~COil()
{
  /// Oil destructor.


  delete [] fvf;
  delete [] weight;
  delete [] viscosity;
}

double COil::FVF(double pres) {
  /// Function that interpolates FVF from de PVT data.
  /// This function uses the linear interpolation model.

  if ((pres < pressure[0]) || (pres > pressure[pvtpoints-1])) { ///< If the reservoir pressure is out of PVT test, the user will be warned.
    cerr << "Error - Pressure out of PVT range \n";
    // cin.ignore();
    exit(EXIT_FAILURE);
  }

  int imin=0;

  while (pres > pressure[imin]) { imin++; } ///< Searching the position of the pressure in the PVT tabble;
  imin--;
  if (imin == (pvtpoints - 1)) {return fvf[imin]; } ///< This case is used when the pressure is the last pressure of the PVT tabble.

  return fvf[imin]+(pres-pressure[imin])*(fvf[imin+1]-fvf[imin])/(pressure[imin+1]-pressure[imin]);
}

double COil::Weight(double pres) {
  /// Function that interpolates Specific Weight from de PVT data.
  /// This function uses the linear interpolation model.

  if ((pres < pressure[0]) || (pres > pressure[pvtpoints-1])) { ///< If the reservoir pressure is out of PVT test, the user will be warned.
    cerr << "Error - Pressure out of PVT range \n";
    // cin.ignore();
    exit(EXIT_FAILURE);
    // return 0;
  }

  int imin=0;

  while (pres > pressure[imin]) { imin++; } ///< Searching the position of the pressure in the PVT tabble;
  imin--;
  if (imin == (pvtpoints - 1)) { return weight[imin]; } ///< This case is used when the pressure is the last pressure of the PVT tabble.

  return weight[imin]+(pres-pressure[imin])*(weight[imin+1]-weight[imin])/(pressure[imin+1]-pressure[imin]);
}

double COil::Viscosity(double pres) {
  /// Function that interpolates Viscosity from de PVT data.
  /// This function uses the linear interpolation model.

  if ((pres < pressure[0]) || (pres > pressure[pvtpoints-1])) { ///< If the reservoir pressure is out of PVT test, the user will be warned.
    cout << "Error - Pressure out of PVT range \n";
    // cin.ignore();
    exit(EXIT_FAILURE);
  }

  int imin=0;

  while (pres > pressure[imin]) { imin++; } ///< Searching the position of the pressure in the PVT tabble;
  imin--;
  if (imin == (pvtpoints - 1)) { return viscosity[imin]; } ///< This case is used when the pressure is the last pressure of the PVT tabble.

  return viscosity[imin]+(pres-pressure[imin])*(viscosity[imin+1]-viscosity[imin])/(pressure[imin+1]-pressure[imin]);
}

double COil::AveragePVTPressure() {
  /// This function returns the average pressure of the PVT test.
  /// The function uses the linear averaging model.

  return (pressure[0]+pressure[pvtpoints-1])/2;

}

void COil::PrintFluid() {
  /// This function prints all the fluid data on screen. It is used to debug the code, and it is not
  /// necessary in the final program.

  cout << "Press \t  FVF  \t  Weight \t  Viscosity \n";
  for (int j=0 ; j<pvtpoints ; j++) {

    cout << pressure[j] << "\t";
    cout << fvf[j] << "\t";
    cout << weight[j] << "\t";
    cout << viscosity[j] << "\n";
  }
}

//** @file main.cpp */

#include <cstdlib>
#include <iostream>

#include "CReservoir.h"
#include "CDataControl.h"

using namespace std;

void onExit() {
  cout << "End of Execution" << endl;
  cout << "UENF - LENEP"  << endl;
}

int main()
{
  std::atexit(onExit);
    {
          CDataControl dcontrol; ///< Class created to manage the variables input.
          CReservoir reservoir(&dcontrol); ///< Reservoir Constructor
          reservoir.Run(); ///< Running the simulation. This is the main code of the program.
    }

    //cout << "Pedro Henrique Linhares" << endl;
    //cout << "Wagner Queiroz Barros" << endl;
    //cout << "Petroleum Engineer" << endl;
    return 0;
}

//** @file main.cpp */

#include <cstdlib>
#include <iostream>

#include "CReservoir.h"
#include "CDataControl.h"

using namespace std;

int main()
{
	
    {
          CDataControl dcontrol; ///< Class created to manage the variables input.
          CReservoir reservoir(&dcontrol); ///< Reservoir Constructor
          reservoir.Run(); ///< Running the simulation. This is the main code of the program.
    }
    
    cout << "End of Execution" << endl;
    //cout << "Pedro Henrique Linhares" << endl;
    //cout << "Wagner Queiroz Barros" << endl;
    //cout << "Petroleum Engineer" << endl;
    cout << "UENF - LENEP"  << endl;
    cin.ignore();
    return 0;
}

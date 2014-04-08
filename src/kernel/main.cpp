//** @file main.cpp */
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
#include <iostream>
#include <ctime>

#include "CReservoirSimulator.h"

void onExit() {
  std::cout << "End of Execution" << std::endl;
  std::cout << "UENF - LENEP"  << std::endl;
  #ifdef _WIN32
  	std::cin.ignore();
  #endif
  
}

/* ///
	TO Do List:
	
	OK! - URGENTE: Implementar uma rotina para o usuário escolher o tempo que será salva a simulação;
	
	1 - O polimorfismo do grid não está legal. REVER.
	
	2 - Retirar o fluid type do poço e o solver type do model.
		
	3 - Every cell needs to have left and right transmissibility function, but only the right
	    will be implemented. The left case is the access of the left cell and the right transmissibility calculation.
	    Again, it will help in the future cases.
	
	4 - Implementar a Boundary Condition de Vazão prescrita no caso 1D;
	
	5 - Implementar todas as Boundary Conditions no caso 2D;    
	
	(REVIEW) - Fix all de implicit derivative functions, it can be working but it is not easy to understand the derivatives relationship.
		
*/ /// 

int main() {
  clock_t timer; ///< Timer used to calculate the processing time.
  timer = clock(); ///< Getting the current time.
  std::atexit(onExit);

  CReservoirSimulator simulation; ///< Simulator Constructor
  simulation.Run(); ///< Running the simulation. This is the main code of the program.
  
  timer = clock() - timer; ///< Updating timer;
  std::cout << "Processing time in seconds: " <<((float) timer)/1000 << std::endl; ///< Display the processing time.
  return 0;
}

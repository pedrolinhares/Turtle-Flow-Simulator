//** @file CSinglePhase2d.cpp */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz Barros.
 *  
 *  Class Author: Wagner Queiroz Barros.
 *  Last Update: 08/04/2014
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

#include "CSISinglePhase2d.h"

using namespace std;

CSISinglePhase2d::CSISinglePhase2d(CGrid2d1p *_grid, CSolverMatrix *_solver, int _maxni, double _erroni) {
	/// Class Constructor
	
	grid = _grid;
	solver = _solver;
	cpoints = grid->CellNumber();
	maxni = _maxni;
	erroni = _erroni;
	
	elem_numb = MatrixElementsNumber();
	
	/// Allocating the Matrix A ///
	Acol = new int[elem_numb]; 
	Arow = new int[cpoints + 1]; 
	Aval = new double[elem_numb];
	
	/// Starting the Aval ///
	for (int j = 0; j < elem_numb; j++) { Aval[j] = 0; }
	
	/// Starting Acol and Arow ///
	/// For this is needed to access all cells in domain and verify their neighbours
	FillAMatrix();	
	
	
	
	/// Constructing the Free Vector
	b = new double[cpoints]; 
	
	/// Constructing the Solution Vector
    Xni = new double[cpoints]; 
		  
}

CSISinglePhase2d::~CSISinglePhase2d()
{
	/// Class destructor.
	delete [] Acol;
	Acol = NULL;
	
	delete [] Arow;
	Arow = NULL;
	
	delete [] Aval;
	Aval = NULL;
	
}

int CSISinglePhase2d::MatrixElementsNumber() {
 /// This function run over all cells in problem and returns the number of elements
 ///that will be created in matrix A. It is used for pre-allocate memory for UMFPack matrix
 /// The elements un matrix A is the number of connections in domain;
 
 return (2*grid->ConnectionsNumber() + grid->CellNumber());  ///<The matrix number is the the cell number + the connections of each cell, so 2*connections.
 
}

void CSISinglePhase2d::BuildMatrix(double deltat)
{
	/// This function creates the coefficient matrix "A", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.

    double Ri, Ci, Li, Bi, Fi;
	double deltap;
	int elemcount = 0; ///< Counter to control the number of elements inserted in matrix A.
	

	/// Filling the middle A Elements
//    for (int i = 0 ; i < cpoints ; i++) {
//		
//		Bi = grid->BackTrasmY(i);	///< Calculating the back matrix element;
//		Li = grid->LeftTrasmX(i); ///< Calculating the west matrix element;
//		Ri = grid->RightTrasmX(i);	///< Calculating the east matrix element;
//		Fi = grid->FrontTrasmY(i); 	///< Calculating the front matrix element;	
//		
//    	Ci = - grid->Gamma(i)/deltat - Ri - Li - Bi - Fi;	///< Calculating the central matrix element;
//    	
//    	if (grid->Cell(i)->BackCell() != NULL ) {
//    		if (grid->Cell(i)->BackCell()->CellId() != grid->Cell(i)->CellId()) {
//    			Aval[elemcount] = Bi;
//	        	elemcount++;
//    		}
//    	}
//    	
//    	if (grid->Cell(i)->LeftCell() != NULL ) {
//    		if (grid->Cell(i)->LeftCell()->CellId() != grid->Cell(i)->CellId()) {
//    			Aval[elemcount] = Li;
//	        	elemcount++;
//    		}
//    	}
//    	
//    	Aval[elemcount] = Ci;
//	    elemcount++;
//	    
//	    if (grid->Cell(i)->RightCell() != NULL ) {
//    		if (grid->Cell(i)->RightCell()->CellId() != grid->Cell(i)->CellId()) {
//    			Aval[elemcount] = Ri;
//	        	elemcount++;
//    		}
//    	}
//    	
//    	if (grid->Cell(i)->FrontCell() != NULL ) {
//    		if (grid->Cell(i)->FrontCell()->CellId() != grid->Cell(i)->CellId()) {
//    			Aval[elemcount] = Fi;
//	        	elemcount++;
//    		}
//    	}
//    		       
//    }
    
    /// Filling the last line of matrix A
//    Wi = grid->LeftTrasmX(cpoints - 1); ///< Calculating the west matrix element;
//    Ei = grid->RightTrasmX(cpoints - 1);	///< There is no east matrix element;
//	Ci = - grid->Gamma(cpoints - 1)/deltat - Wi - Ei;	///< Calculating the central matrix element;
//	
//		Aval[elemcount] = Wi;
//        elemcount++;
//        Aval[elemcount] = Ci;
//        elemcount++;	

}

void CSISinglePhase2d::BuildCoefVector(double deltat){
	/// This function creates the free vector "b", using the grid data.
	///	It is used a Single-Phase Compressible-Flow model, described in chapter 8 of
	/// Ertekin, T., Abou-Kassem, J. & King, G., "Basic Reservoir Simulation", 2001.

	double Eig, Wig, Cig, Qg;
    double gama_dt, q;
  

	for (int i = 0 ; i < (cpoints) ; i++) {

		Wig = grid->LeftGravityTransmX(i);  ///< Calculating the west transmissibility;

    	Eig = grid->RightGravityTransmX(i);   ///< Calculating the east transmissibility;

    	Cig = - Eig - Wig;  ///< Calculating the central transmissibility;

		Qg =Wig*grid->LeftDeepth(i) + Cig*grid->Deepth(i) + Eig*grid->RightDeepth(i); ///< Rate term;

    	gama_dt = grid->Gamma(i)/deltat;

    	q = grid->WellRate(i);  ///< Getting the well rate for cell i;

    	b[i] = Qg - (gama_dt*grid->BackPressure(i)) - q;  ///< Filling the b vector;

    	/// Left Boundary Condition ///
    	if (i == 0) {
    		b[i]  = b[i] - grid->LeftTrasmX(0)*grid->LeftPressure(0);
    	}

    	/// Right Boundary Condition ///
    	if (i == (cpoints - 1)) {
    		b[i]  = b[i] - grid->RightTrasmX(cpoints - 1)*grid->RightPressure(cpoints - 1);
    	}

    }

}

void CSISinglePhase2d::BuildInitialSolution() {
	 /// This function builds the initial solution for the first problem iteration.
	 /// It is used to initiate the first solution.

	 for (int i = 0 ; i < (cpoints) ; i++) {

        Xni[i] =  grid->Pressure(i);

    }

}

void CSISinglePhase2d::Iterationt(double deltat) {
	/// This function makes a time iteration in all cells of domain
	/// using the semi-implicit linearization model.
	
	//////////  Iteration used for linearizate the problem  /////////
       double er1, er1max;
       int h = 0;

       do {

         Print();
		 BuildMatrix(deltat);  ///< Constructing the coeficient matrix, according to the grid data.        
         //BuildCoefVector(grid, deltat); ///< Constructing the free vector, according to the grid data.
         
         Print();

         solver->UMFPack( Acol, Arow, Aval, b, Xni, cpoints ); ///< Calling the solver used in this problem

        	 /////////  Error Analyzing  /////////

	         for (int j=0 ; j<cpoints; j++) {
		          er1 = abs(Xni[j] - grid->Pressure(j));
		          if (j == 0) {
		            	er1max = er1;
		          } else {
		            	if (er1 > er1max) { er1max = er1; }
		          }
	         }

         grid->Iterationni(Xni);  ///< Updating the atual pressure in reservoir

         h++;

       } while ((h < maxni) && (er1max > erroni));

	grid->Iterationt(deltat);  ///< Updating the back pressure in all reservoir;

    cout.precision(4);
    cout << "     Linear Iterations - " << h;
    cout << "     Linear Error - " << er1max << "\n";

}

void CSISinglePhase2d::Print() {
	///This function prints on screen all the matrix. It is used to debug the code.
	
	cout << "\nCumulative Row Array (Arow):\n";
	for (int i = 0; i < (cpoints + 1) ; i++ ) { cout << Arow[i] << endl; }
	
	cout << "\nColumn index for all elements (Acol):\n";
	for (int i = 0; i < elem_numb ; i++ ) { cout << Acol[i] << endl; }
	
	cout << "\nValue for all elements (Aval):\n";
	for (int i = 0; i < elem_numb ; i++ ) { cout << Aval[i] << endl; }
	
	cout << "\nValue of free vector (b):\n";
	for (int i = 0; i < (cpoints) ; i++ ) { cout << b[i] << endl; }
	
	cout << "\nValue of solution x (Xni):\n";
	for (int i = 0; i < (cpoints) ; i++ ) { cout << Xni[i] << endl; }
	
}

void CSISinglePhase2d::FillAMatrix(){
	/// Starting Acol and Arow ///
	/// For this is needed to access all cells in domain and verify their neighbours
	/// For 2d case, the cells are accessed from left to right and from top to down.
	
	/// First Cell
	Arow[0] = 0;
	
	int colcount = 0; ///< Counter used to fill the Acol;
	
	int xpos, max_x, ypos, max_y, cellID, row_number, auxpos;
	
	max_x = grid->XCells(); ///< Max elements in X direction;
	max_y = grid->YCells(); ///< Max elements in Y direction;
	row_number = 0;
		
	for (int i=0; i<cpoints; i++)	{
		
		
		cellID = grid->CellId(i);
		xpos = grid->CellXPosition(cellID);
		ypos = grid->CellYPosition(cellID);
		
		if ((ypos-1) >= 0) {
			auxpos = grid->GridPosition((ypos-1),xpos);
			if (auxpos != -1) {	
				Acol[colcount] = auxpos;
				row_number++;
				colcount++;
			}
		}
		
		if ((xpos-1) >=0) {
			auxpos = grid->GridPosition(ypos,(xpos-1));
			if (auxpos != -1) {	
				Acol[colcount] = auxpos;
				row_number++;
				colcount++;
			}
		}
		
		Acol[colcount] = i;
		row_number++;
		colcount++;
		
		if ((xpos+1) < max_x) {
			auxpos = grid->GridPosition(ypos,(xpos+1));
			if (auxpos != -1) {	
				Acol[colcount] = auxpos;
				row_number++;
				colcount++;
			}
		}
		
		if ((ypos+1) < max_y) {
			auxpos = grid->GridPosition((ypos+1),xpos);
			if (auxpos != -1) {
				Acol[colcount] = auxpos;
				row_number++;
				colcount++;
			}			
		}
		
	Arow[i+1] = row_number;
	row_number = 0;
	}
	
	/// Cumulating the Arow array
	for (int g = 0; g < cpoints ; g++) {
		Arow[g+1] = Arow[g] + Arow[g+1] ;
	}
}

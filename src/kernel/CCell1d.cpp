//** @file CCell1d.cpp */
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

#include "CCell1d.h"

using namespace std;

CCell1d::CCell1d()
{
	/// CCell1d default constructor.

	cellid = 0;
	thickness = 0;
	deepth = 0;
	pressure = 0;
	backpressure = 0;
	gtransmx = 0;

	well = NULL;
	rightcell = NULL;
	leftcell = NULL;

}

CCell1d::CCell1d(double *data, CBlock *blk, CFluid *fld)
{

	/// Overloaded CCell1d constructor.
	/// This cell is created with data from reservoir, and with pointers to the
	/// block and fluid related to this cell.

	cellid = (int) data[0];
	thickness = data[1];
	deepth = data[2];

	block = blk;
	fluid = fld;
	well = NULL;

	pressure = fluid->AveragePVTPressure(); ///< It is only starting the cell pressure, this value will be changed according to simulation
	gtransmx = 0; ///< This value will be calculated after;

	leftcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
	rightcell = NULL; ///< The Reservoir is responsible to conect all the cells in domain.
}

CCell1d::CCell1d(CCell1d & _cell) {
	/// CCell1d copy constructor.

	cellid = _cell.CellId();
	thickness = _cell.Thickness();
	deepth = _cell.Deepth();
	pressure = _cell.Pressure();
	backpressure = _cell.BackPressure();
	gtransmx = _cell.GTransmx();
	block = _cell.Block();
	fluid = _cell.Fluid();
	well = _cell.Well();
	leftcell = _cell.LeftCell();
	rightcell = _cell.RightCell();

}

CCell1d::~CCell1d()
{
	/// Cell1d destructor.

}

void CCell1d::Print()
{
	/// This function prints all the cell data on screen. It is used to debuge the code, and it is not
	/// necessary in the final program.

	cout << "Cell ID - " << cellid << "\n";
	cout << "Cell Thickness - " << thickness << "\n";
	cout << "Cell Deepth - " << deepth << "\n";
	cout << "Cell Conected to Block - " << block->Blockid() << "\n";
	cout << "Cell Pressure - " << pressure << "\n";
	cout << "Cell Back Pressure - " << backpressure << "\n";
	cout << "Cell Geometric Transmissibility - " << gtransmx << "\n";
	cout << "Inicial Cell Porosity - " << Porosity() << "\n";
	cout << "Atual Cell Porosity - " << Porosity(backpressure) << "\n";

	if (rightcell != NULL) {

		cout << "Right ID - " << rightcell->CellId() << "\n" ;

	}

	if (leftcell != NULL) {

		cout << "Left ID - " << leftcell->CellId() << "\n" ;

	}

	cout << "Right Transmissibility - " << RightTransmx() << "\n";
	if (well != NULL) {
		cout << "Well Rate - " << well->Rate() << "\n";
	}

}

double CCell1d::RightTransmx() {
	/// This function calculates the right transmissibility between adjacent cells in domain.
	/// the transmissibility is calculated as a product between the geometric transmissibility and
	/// the fluid properties inside the cell.

	if (gtransmx == 0) { return 0; }; ///< geometric transmissibility NULL means that the right block is NULL.

	double pright, pmed;

	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	double visc, fvf;

	visc = fluid->Viscosity(pmed); ///< Average viscosity between cells;
	fvf = fluid->FVF(pmed); ///< Average FVF between cells;

	return gtransmx/(visc*fvf);
}

double CCell1d::RightGravityTransmx() {
	/// This function calculates the right gravitational transmissibility between adjacent cells in domain.
	/// the gravitational transmissibility is calculated as a product between the transmissibility and
	/// the specific weight of the fluid inside the cell.

	double rtransmx;

	rtransmx = RightTransmx(); ///< Calculating the transmissibility between adjacent cells in domain;
	if (rtransmx == 0 ) { return 0; } ///< Right Block is NULL.
	double pright, pmed, spcweight;

	pright = rightcell->Pressure(); ///< Pressure in the adjacent cell;
	pmed = (pright + pressure) / 2.;  ///< Average pressure calculated as arithmetic average.

	spcweight = fluid->Weight(pmed); ///< Average specific weight of fluid between cells;

	return spcweight*rtransmx;
}

int CCell1d::WellId() {
	///This function returns the Id of the well inside the cell.
	///If there is no well inside the cell, return 0;
	if (well == NULL) {
		return 0;
	}
	else{
		return well->Id();
	}

}

void CCell1d::WellRate(double _rate) {
	/// This function sets the well flow rate of the well inside the cell.
	/// If there is no well inside the cell, the function creates a well,
	/// else the funtion only sets the value of the flow rate.

	if (well == NULL) {
		well = new CWell1d(_rate);
	}
	else{
		well->Rate(_rate);
	}
}

double CCell1d::WellCumulative_Phase1() {
	/// This function returns the cumulative volume of the phase 1, produced or injected by the well inside the cell.
	/// If there is no well inside the cell, the function returns 0.

	if (well == NULL) {
		return 0;
	}
	else{
		return well->Cumulative_Phase1();
	}
}
void CCell1d::WellRate(double _rate, int _id) {
	/// This function sets the well flow rate and the well Id of the well inside the cell.
	/// If there is no well inside the cell, the function creates a well,
	/// else the funtion only sets the value of the flow rate.

	if (well == NULL) {
		well = new CWell1d(_rate, _id);
	}
	else{
		well->Rate(_rate, _id);
	}
}


double CCell1d::WellRate() {
	/// This function returns the well flow rate of the well inside the cell.
	/// If there is no well inside the cell, the function returns 0.

	if (well == NULL) { return 0; }
	else { return well->Rate();	}
}

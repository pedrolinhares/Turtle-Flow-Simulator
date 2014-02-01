//** @file CGrid1d.h */

#ifndef CGrid1d_h
#define CGrid1d_h

#include <cmath>

#include "CGrid.h"
#include "CCell1d.h"

/**
 * This class represents a One-Dimensional Grid. It inherits from CGrid.h that is a abstract class.
 * This class has a array with one-dimensional cells.
 */

class CGrid1d : public CGrid
{

    private:

        int cellnumber; ///< Number of cells in domain
		double *lenght; ///< Vector representing the lenght of each cell in domain
        double width;   ///< Width of all cells in domain. (Used only in one-dimensional simulation)
        CCell1d *cells; ///< Array with all cells of domain

	public:

		CGrid1d(CDataControl *_dcontrol); ///< One-Dimensional Grid Constructor
		virtual ~CGrid1d(); ///< One-Dimensional Grid Destructor

		virtual void PrintData(); ///< Function used to print all the reservoir data on screen.
		virtual void SaveGridSolution(std::ofstream *fout, double time); ///< Function used to save the grid solution in disk.
		virtual void SaveWellSolution(std::ofstream *fout, int welln, double time);///< Function used to save the well solution in disk.

		//////////  Numerical Functions  //////////
		virtual void InitiateSolution(); ///< Initiate the solution in all reservoir;
		virtual void Iterationni(double *Xni); ///< Makes the linear iteration "ni" in all cells;
		virtual void Iterationt(double deltat); ///< Makes the time iteration in all cells.

		//////////  Fluid Functions  /////////
		double FVF( int celln ) { return cells[celln].FVF(); }; ///< Return the FVF of a specific cell in domain;
		double BackFVF( int celln ) { return cells[celln].BackFVF(); }; ///< Return the back FVF of a specific cell in domain.

		//////////  Rock Functions  //////////
		double RockComp( int celln ) { return cells[celln].RockComp(); }; ///< Return the rock compressibility of a specific cell in domain;
		double Por0( int celln ) { return cells[celln].Porosity(); }; ///< Return the initial porosity of a specific cell in domain;
		double Porosity( int celln, double pressure) { return cells[celln].Porosity(pressure); }; ///< Return the atual porosity of a specific cell in domain.

		//////////  Cell Functions  //////////
		virtual int CellNumber() { return cellnumber; }; ///< Return the cell ID of a specific cell in domain;
		int CellId( int celln ) { return cells[celln].CellId(); }; ///< Return the cell ID of a specific cell in domain;
		//double Pressure( int celln ) { return cells[celln].Pressure(); }; ///< Return the atual pressure of a specific cell in domain;
		double Pressure( int celln ); ///< Return the atual pressure of a specific cell in domain;
		double BackPressure( int celln ) { return cells[celln].BackPressure(); }; ///< Return the back pressure of a specific cell in domain;
		double Volume( int celln ); ///< Return the volume of a specific cell in domain;
		//double Deepth( int celln ) { return cells[celln].Deepth(); }; ///< Return the Deepth of a specific cell in domain.
		double Deepth( int celln ); ///< Return the Deepth of a specific cell in domain.

		//////////  Transmissibility Functions //////////
		virtual void SetGTransmx(); ///< Sets the Geometric transmissibility in all cells;
		double RightTrasmx( int celln ); ///< Return the right transmissibility of a specific cell in ddomain;
		double RightGravityTransmx( int celln ); ///< Return the right gravitational transmissibility of a specif cell.

		//////////  Well Functions //////////
		double WellRate( int celln ) { return cells[celln].WellRate(); }; ///< Return the flow rate of a well in a specific cell in domain.
		virtual int WellNumbers(); ///< Return the number of wells in domain.

		////////// Boundary Conditions //////////
		void SetBoundConditions(); ///< Sets the boundary condition for the problem.

};

#endif // CGrid1d_h

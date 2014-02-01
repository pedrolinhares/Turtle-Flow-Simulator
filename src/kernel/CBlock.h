//** @file CBlock.h */

#ifndef CBlock_h
#define CBlock_h

#include <iostream>
#include <fstream>

#include "CRock.h"

/**
 * This Class is used to describe a block in reservoir.
 * A Block is defined as a group of cells having the same rock proprieties.
 * It is used to save data storing, in homogeneous simulations.
 */

class CBlock
{
    private:

        int blockid; ///< Id of Block;
        CRock rock; ///< Rock object stored in this block;

	public:

		CBlock(); ///< Block constructor;
		CBlock(double *data); ///< Overloaded Block constructor;
		~CBlock(); ///< Block destructor;

		///////////  Block Functions  //////////
		inline int Blockid() {return blockid;}; ///< Returns the Block Id;
		void PrintBlock(); ///< Prints the Block proprieties on screen.

		///////////  Rock Functions  //////////
		inline double Permeability() {	return rock.Permeability();	}; ///< Returns the Rock permeability;
		inline double Porosity() { return rock.Porosity(); }; ///< Returns the initial Rock porosity;
		inline double Porosity(double pressure) { return rock.Porosity(pressure); }; ///< Returns the atual Rock porosity;
		inline double RockComp() { return rock.Rockcomp(); }; ///< Returns the Rock compressibility;

};

#endif // CBlock_h

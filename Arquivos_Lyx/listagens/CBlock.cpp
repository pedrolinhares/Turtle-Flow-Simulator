//** @file CBlock.cpp */

#include "CBlock.h" // class's header file

using namespace std;

CBlock::CBlock() : blockid(0)
{
	/// Class constructor
	
}
CBlock::CBlock(double *data) : blockid((int) data[0])
{
	/// Overloaded Class constructor
	    
	rock.Rockcomp(data[1]);
    rock.Permeability(data[2]);
	rock.Por0(data[3]);
	rock.RefPressure(data[4]);      
}

CBlock::~CBlock()
{
	/// class destructor
	
}

void CBlock::PrintBlock() {
	/// This function prints all block parameters on screen. It is used to debug the code,
	/// during programing, but it won't be used when the final code is ready.
        
        cout << "Block ID - " << blockid << endl;
		cout << "Rock Compressibility - " << rock.Rockcomp() << "\n";
        cout << "Rock Permeability - " << rock.Permeability() << "\n";
		cout << "Rock Porosity - " << rock.Porosity() << "\n";
  }
  

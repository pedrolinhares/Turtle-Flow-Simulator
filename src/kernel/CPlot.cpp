/** @file CPlot.cpp */
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

#include "CPlot.h"

using namespace std;

/// Constructor of CPlot;
CPlot::CPlot() {
  // Gnuplot::Terminal("wxt");

  time = 0.;  ///< time that will be plotted (only for pressure in cells);

  pstyle = "linespoints"; ///< Gnuplot style;
  xlabel = "x"; ///< Xlabel
  ylabel = "y";  ///< Ylabels;
  plabel = "";  ///< Plot Label;
  ptitle = "Graph1"; ///< Plot title;
  marksize = 1.2; ///< Size of markers;

}

CPlot::~CPlot()
{
}

int CPlot::PlotWellPressure(int welln) {
    ///This function opens the Well "welln" output file,
    ///and plots the data in GnuPlot grapher.
    ///The well data contains a vector for time, pwf and for cumulative production.

    ifstream wellf;

    ostringstream wdn;
  wdn << "reservoir_data/Out_Well_" << welln;
  plabel = wdn.str();  ///< Plot label;
  wdn << ".out";

  wellf.open(wdn.str().c_str()); ///< Opning the well data
  if (wellf.fail())
       {
            cerr << "There is no well data." << endl;
            // cin.ignore();
            return 1;
       }

    /// Getting data
    double xvalue, yvalue;

    //clears vectors
    x.clear();
    y.clear();

    wellf.ignore(256,'\n');
    while (!wellf.eof()) {
        wellf >> xvalue;
        wellf >> yvalue;
        wellf.ignore(256,'\n');
        x.push_back(xvalue);
        y.push_back(yvalue);
    }

   /// Setting plot
   ptitle = "Well Pwf";
   pstyle = "lines";
   xlabel = "Time [days]";
   ylabel = "Pressure [psia]";

   PlotGraph();

   return 0;
 }

int CPlot::PlotWellProduction(int welln) {
    ///This function opens the Well "welln" output file,
    ///and plots the data in GnuPlot grapher.
    ///The well data contains a vector for time, pwf and for cumulative production.

    ifstream wellf;

    ostringstream wdn;
  wdn << "reservoir_data/Out_Well_" << welln;
  plabel = wdn.str();  ///< Plot label;
  wdn << ".out";

  wellf.open(wdn.str().c_str()); ///< Opning the well data
  if (wellf.fail())
       {
            cerr << "There is no well data." << endl;
            // cin.ignore();
            return 1;
       }

    /// Getting data
    double xvalue, yvalue, trash;

     //clears vectors
    x.clear();
    y.clear();

    wellf.ignore(256,'\n');
    while (!wellf.eof()) {
        wellf >> xvalue;
        wellf >> trash;
        wellf >> yvalue;

        x.push_back(xvalue);
        y.push_back(yvalue);
    }

   /// Setting plot
   ptitle = "Well Cumulative Production/Injection";
   pstyle = "lines";
   xlabel = "Time [days]";
   ylabel = "Cumulative Flow [STB]";

   PlotGraph();

   return 0;
}

int CPlot::PlotGridPressure(double time, int ncells){
  /// This function plots the reservoir pressure for a specified time.
  ///This function opens the grid output file,
    ///and plots the data in GnuPlot grapher.

  ifstream gridf;

  gridf.open("reservoir_data/Out_GridPressure.out"); ///< Opning the grid data
  if (gridf.fail())
       {
            cerr << "There is no grid data." << endl;
            // cin.ignore();
            return 1;
       }

  /// Getting data
    double tvalue, yvalue, count;
    tvalue = 0;
    count = 1;

     //clears vectors
    x.clear();
    y.clear();

    gridf.ignore(256,'\n');
    while ((!gridf.eof()) && (tvalue < time)) {

        gridf >> tvalue;
        if (gridf.eof()) { return 0; } ///Time is out of simulated time;

        if (tvalue < time) { gridf.ignore(256,'\n'); }
        else {
          gridf >> yvalue;
          while ( count <= ncells) {
            x.push_back(count);
            y.push_back(yvalue);
            count++;
            gridf >> yvalue;
          }
        }

    }

  /// Setting plot
   xlabel = "Cell Id";
   ylabel = "Pressure [psia]";
   ptitle = "Reservoir Pressure";
   pstyle = "lines";

   PlotGraph();

   return 0;
}

int CPlot::PlotCellPressure(int celln) {
  /// This function plot the pressure profile for a specific cell in time.
  ///This function opens the grid output file,
    ///and plots the data in GnuPlot grapher.

    ifstream gridf;

  gridf.open("reservoir_data/Out_GridPressure.out"); ///< Opning the grid data
  if (gridf.fail())
       {
            cerr << "There is no grid data." << endl;
            // cin.ignore();
            return 1;
       }

  /// Getting data
    double xvalue, yvalue, trash;
    int count;

    //clears vectors
    x.clear();
    y.clear();

    gridf.ignore(256,'\n');
    while (!gridf.eof()) {
        gridf >> xvalue;
        count = 1;
        while (count < celln) {
          gridf >> trash;
          count++;
        }
        gridf >> yvalue;
        gridf.ignore(256,'\n');
        x.push_back(xvalue);
        y.push_back(yvalue);
    }

   /// Setting plot
   xlabel = "Time [days]";
   ylabel = "Pressure [psia]";
   ptitle = "Pressure Profile for a single cell";
   pstyle = "lines";

   PlotGraph();

   return 0;
}

void CPlot::PlotGraph(){
    /// Plots a graph using the class information;
    if (plot != nullptr)
      delete plot;
    plot = new Gnuplot;

    plot->ResetAll();
    plot->set_style(pstyle);
    plot->set_grid();
    plot->set_xlabel(xlabel);
    plot->set_ylabel(ylabel);
    plot->set_pointsize(marksize);
    plot->set_title(ptitle);

    plot->plot_xy(x, y, plabel);
}


/** @file CPlot.h */
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

#ifndef CPLOT_H
#define CPLOT_H

#include "CGnuplot.h"

#include <vector>
#include <string>

#include <fstream>
#include <sstream>
#include <iostream>

class CPlot {
protected:

  double time; ///< time that will be plotted;

  std::vector <double> x; ///< X axis data;
  std::vector <double> y; ///< Y axis data;

  /// Plot Properties
  std::string pstyle; ///< Gnuplot style;
  std::string xlabel, ylabel;  ///< Plot labels;
  std::string ptitle; ///< Plot title;
  std::string plabel; ///< Plot label;

  double marksize; ///< Size of markers;

  Gnuplot *plot;

public:
  CPlot();
  ~CPlot();
  int PlotWellPressure(int welln); ///< Plot the pressure data for well n;
  int PlotWellProduction(int welln);  ///< Plot the cumulative production data for well n;
  int PlotGridPressure(double time, int ncells); ///< Plot the reservoir pressure for a specific time.
  int PlotCellPressure(int celln); ///< Plot the pressure profile for a specific cell in time.

  void PlotGraph(); ///< Plots a graph using the class parameters;
};

#endif

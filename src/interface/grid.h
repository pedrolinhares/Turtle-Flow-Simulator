/** \file grid.h */
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

#ifndef GRID_H
#define GRID_H

#include <QTableWidget>

/** \class Grid
** Class that represents a basic table grid.
*/
class Grid: public QTableWidget {
  Q_OBJECT
public:
  explicit Grid(QWidget *parent = 0) : QTableWidget(parent){};
  Grid(int row, int column, QWidget* parent = 0);
  ///Destructor
  ~Grid(){};
};

#endif // GRID_H
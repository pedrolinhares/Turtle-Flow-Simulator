/** \file grid.h */

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
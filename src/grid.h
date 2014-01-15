#ifndef GRID_H
#define GRID_H

#include <QTableWidget>

class Grid: public QTableWidget {
  Q_OBJECT
public:
  explicit Grid(QWidget *parent = 0) : QTableWidget(parent){};
  Grid(int row, int column, QWidget* parent = 0);
  ~Grid(){};
  bool okToContinue();

private:
  bool isBeingEdited();
  bool saveGrid();
};


#endif
/** @file fluid_dialog.h */
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

#ifndef FLUID_DIALOG_H
#define FLUID_DIALOG_H

#include <QDialog>

class QSpinBox;
class QTableWidget;

/**************************************************************************//**
** \class FluidDialog
** Creates a table that represents the fluid's specifics properties.
******************************************************************************/
class FluidDialog : public QDialog {
  Q_OBJECT

  public:
    /// Constructor that takes the parent pointer.
    FluidDialog(QWidget *parent = 0);
    /// Destructor.
    ~FluidDialog() {};

    /**********************************************************************//**
    ** \brief Get the inner QTableWidget*
    ** \return Pointer to a QTableWidget*
    **************************************************************************/
    QTableWidget* getTable() const { return pvtTableWidget; };

  private slots:
  void insertOrRemoveRows(int);

  private:
    QSpinBox *pvtSpinBox;
    QTableWidget *pvtTableWidget;
};

#endif // FLUID_DIALOG_H
/** @file start_dialog.h */
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

#ifndef START_DIALOG_H
#define START_DIALOG_H

#include <QMainWindow>
#include <QDialog>
#include <string>
#include <map>
#include "fluid_definitions.h"

using namespace fluid_definitions;

class QGroupBox;
class QRadioButton;
class QComboBox;
class QSpinBox;

/**************************************************************************//**
** \class StartDialog
** Initial dialog presented to the user to first created the grids and tabs.
******************************************************************************/
class StartDialog : public QDialog
{
  Q_OBJECT

public:
  explicit StartDialog(QWidget *parent = 0);
  ~StartDialog() {};

  void show();

private slots:
  void allowTwoDiminsional(bool);
  void emitSignal();

signals:
  /************************************************************************//**
  ** Signal emited when the dialog gets closed.
  ** \param dimension One dimensional, Two dimensional or Three dimensional
  ** \param nPhases Number of phases
  ** \param _typeOfPhases map containing the phase and its type (Water, Oil, Gas)
  ** \param nRows Number of the Grid Rows
  ** \param nColumns Number of the Grid Columns
  ****************************************************************************/
  void dialogFinished(std::string, std::string, std::map<std::string, FluidType>,
                      int nRows, int nColumns);

private:
  QGroupBox* createGridModels();
  QGroupBox* createPhaseModels();
  QGroupBox* createPhasesBox();
  QGroupBox* createGridLayoutBox();

  std::string getGridModelChosen();
  std::string getPhaseModelChosen();
  std::map<std::string, FluidType> getPhaseTypeChosen();
  FluidType convertStringToFluidType(QComboBox*);

  QRadioButton *oneDimensionalRadio;
  QRadioButton *twoDimensionalRadio;
  QRadioButton *threeDimensionalRadio;
  QRadioButton *singlePhaseRadio;
  QRadioButton *twoPhaseRadio;
  QRadioButton *threePhaseRadio;

  QComboBox* phaseOne;
  QComboBox* phaseTwo;
  QComboBox* phaseThree;

  QSpinBox* rows;
  QSpinBox* columns;
};

#endif // START_DIALOG_H
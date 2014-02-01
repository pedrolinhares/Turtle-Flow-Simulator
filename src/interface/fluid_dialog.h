/** @file fluid_dialog.h */

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
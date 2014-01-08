#ifndef FLUID_DIALOG_H
#define FLUID_DIALOG_H

#include <QDialog>

class QSpinBox;
class QTableWidget;

class FluidDialog : public QDialog {
  Q_OBJECT

  public:
    FluidDialog(QWidget *parent = 0);
    ~FluidDialog() {};
    
  private slots:
  void insertRows(int);
  
  private:
    QSpinBox *pvtSpinBox;
    QTableWidget *pvtTableWidget;
};

#endif
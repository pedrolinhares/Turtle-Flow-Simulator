////////////////////////////////////////////////////////////////////////////////////////
//               Classe de Interface em C++ para o programa gnuplot.                  //
////////////////////////////////////////////////////////////////////////////////////////
// Esta interface usa pipes e nao ira funcionar em sistemas que nao suportam
// o padrao POSIX pipe. 
// O mesmo foi testado em sistemas Windows (MinGW e Visual C++) e Linux(GCC/G++)
// Este programa foi originalmente escrito por:
// Historico de versoes:
// 0. Interface para linguagem C
//    por N. Devillard (27/01/03)
// 1. Interface para C++: tradução direta da versao em C
//    por Rajarshi Guha (07/03/03)
// 2. Correcoes para compatibilidadde com Win32 
//    por V. Chyzhdzenka (20/05/03)
// 3. Novos métodos membros, correcoes para compatibilidade com Win32 e Linux 
//    por M. Burgis (10/03/08)
// 4. Traducao para Portugues, documentacao - javadoc/doxygen, 
//    e modificacoes na interface (adicao de interface alternativa)
//    por Bueno.A.D. (30/07/08)
//   Tarefas: 
//   (v1)
//   Documentar toda classe
//   Adicionar novos métodos, criando atributos adicionais se necessario.
//   Adotar padrao C++, isto e, usar sobrecarga nas chamadas.
//   (v2)
//   Criar classe herdeira CGnuplot, que inclui somente a nova interface.
//   como e herdeira, o usuario vai poder usar nome antigos.
//   Vantagem: preserva classe original, cria nova interface, fica a critério do usuário
//   qual interface utilizar.
////////////////////////////////////////////////////////////////////////////////////////
// Requisitos:
// - O programa gnuplot deve estar instalado (veja http://www.gnuplot.info/download.html)
// - No Windows: setar a Path do Gnuplot (i.e. C:/program files/gnuplot/bin)
//             ou setar a path usando: Gnuplot::set_GNUPlotPath(const std::string &path);
// - Para um melhor uso, consulte o manual do gnuplot,
//   no GNU/Linux digite: man gnuplot ou info gnuplot.
//   
// - Veja aula em http://www.lenep.uenf.br/~bueno/DisciplinaSL/  
//   
////////////////////////////////////////////////////////////////////////////////////////
#ifndef CGnuplot_h
#define CGnuplot_h
#include <iostream>             // Para teste
#include <string>
#include <vector>
#include <stdexcept>		// Heranca da classe std::runtime_error em GnuplotException
#include <cstdio>		// Para acesso a arquivos FILE

/**
@brief Erros em tempo de execucao
@class GnuplotException
@file  GnuplotException.h
*/
class GnuplotException : public std::runtime_error
{
public:
  /// Construtor
  GnuplotException (const std::string & msg):std::runtime_error (msg) {}
};

/**
@brief Classe de interface para acesso ao programa gnuplot.
@class Gnuplot
@file  gnuplot_i.hpp
*/
class Gnuplot
{
private:
  //----------------------------------------------------------------------------------- Atributos
  FILE *  gnucmd;	///< Ponteiro para stream que escreve no pipe.
  bool    valid;	///< Flag que indica se a sessao do gnuplot esta valida.
  bool    two_dim;	///< true = verdadeiro = 2d, false = falso = 3d.
  int     nplots;	///< Numero de graficos (plots) na sessao.
  std::string pstyle;	///< Estilo utilizado para visualizacao das funcoes e dados.
  std::string smooth;	///< interpolate and approximate data in defined styles (e.g. spline).
  std::vector <std::string> tmpfile_list; ///< Lista com nome dos arquivos temporarios.

  //----------------------------------------------------------------------------------------flags
  bool fgrid;           ///< 0 sem grid,   	1 com grid
  bool fhidden3d;       ///< 0 nao oculta, 	1 oculta
  bool fcontour;	///< 0 sem contorno, 	1 com contorno
  bool fsurface;	///< 0 sem superficie, 	1 com superficie
  bool flegend;		///< 0 sem legendad, 	1 com legenda
  bool ftitle;		///< 0 sem titulo, 	1 com titulo
  bool fxlogscale;	///< 0 desativa escala log, 1 ativa escala log
  bool fylogscale;	///< 0 desativa escala log, 1 ativa escala log
  bool fzlogscale;	///< 0 desativa escala log, 1 ativa escala log
  bool fsmooth;         ///< 0 desativa,        1 ativa 

  //---------------------------------------------------------------------------------------------
  // Atributos estaticos (compartilhados por todos os objetos)
  static int tmpfile_num;               ///< Numero total de arquivos temporarios (numero restrito).
  static std::string m_sGNUPlotFileName;///< Nome do arquivo executavel do gnuplot. 
  static std::string m_sGNUPlotPath;	///< Caminho para executavel do gnuplot.
  static std::string terminal_std;	///< Terminal padrao (standart), usado para visualizacoes.
  
  //------------------------------------------------------------------------------------- Metodos
  // Funcoes membro (métodos membro) (funcoes auxiliares)
  /// @brief Cria arquivo temporario e retorna seu nome.
  /// Usa get_program_path(); e popen();
  void  init ();		        

  /// @brief Cria arquivo temporario e retorna seu nome.
  /// Usa get_program_path(); e popen();
  void Init() { init(); }

  /// @brief Cria arquivo temporario.
  std::string  create_tmpfile (std::ofstream & tmp); 

  /// @brief Cria arquivo temporario.
  std::string  CreateTmpFile (std::ofstream & tmp) { return  create_tmpfile(tmp); }
 
  //---------------------------------------------------------------------------------------------
  // Funcoes estaticas (static functions)
  /// @brief Retorna verdadeiro se a path esta presente.
  static bool  get_program_path ();	

  /// @brief Retorna verdadeiro se a path esta presente.
  static bool  Path() { get_program_path(); }

  /// @brief Checa se o arquivo existe.
  static bool  file_exists (const std::string & filename, int mode = 0); 

  /// @brief Checa se o arquivo existe.
  static bool  FileExists  (const std::string & filename, int mode = 0) 
			    { return file_exists( filename, mode ); }

  //---------------------------------------------------------------------------------------------
public:
  // Opcional: Seta path do gnuplot manualmente
  // No windows: a path (caminho) deve ser dada usando '/' e nao backslash '\'
  /// @brief Seta caminho para path do gnuplot.
  static bool set_GNUPlotPath (const std::string & path);

  /// @brief Seta caminho para path do gnuplot.
  static bool Path(const std::string & path) { return set_GNUPlotPath(path); }

  /// @brief Opcional: Seta terminal padrao (standart), usado para visualizacao dos graficos.
  /// Valores padroes (default): Windows - win, Linux - x11, Mac - aqua
  static void set_terminal_std (const std::string & type);

  /// @brief Opcional: Seta terminal padrao (standart), usado para visualizacao dos graficos.
  /// Valores padroes (default): Windows - win, Linux - x11 ou wxt (fedora9), Mac - aqua
  static void Terminal (const std::string & type) { set_terminal_std(type); }

 //---------------------------------------------------------------------------------Construtores
  /// @brief Construtor, seta o estilo do grafico na construcao.
  Gnuplot (const std::string & style = "points");

  /// @brief Construtor, plota um grafico a partir de um vector, diretamente na construcao.
  Gnuplot (const std::vector < double >&x,
	   const std::string & title = "",
	   const std::string & style = "points",
	   const std::string & labelx = "x",
	   const std::string & labely = "y");

  /// @brief Construtor, plota um grafico do tipo x_y a partir de vetores, diretamente na construcao.
  Gnuplot (const std::vector < double >&x,
	   const std::vector < double >&y,
	   const std::string & title = "",
	   const std::string & style = "points",
	   const std::string & labelx = "x",
	   const std::string & labely = "y");

  /// @brief Construtor, plota um grafico de x_y_z a partir de vetores, diretamente na construcao.
  Gnuplot (const std::vector < double >&x,
	   const std::vector < double >&y,
	   const std::vector < double >&z,
	   const std::string & title = "",
	   const std::string & style = "points",
	   const std::string & labelx = "x",
	   const std::string & labely = "y",
	   const std::string & labelz = "z");

  /// @brief Destrutor, necessario para deletar arquivos temporarios.
   ~Gnuplot ();

  //---------------------------------------------------------------------------------------------
  /// @brief Envia comando para o gnuplot.
  Gnuplot &  cmd (const std::string & cmdstr);

  /// @brief Envia comando para o gnuplot.
  Gnuplot &  Cmd (const std::string & cmdstr)     { return cmd(cmdstr); }

  /// @brief Envia comando para o gnuplot.
  Gnuplot &  Command (const std::string & cmdstr) { return cmd(cmdstr); }

  /// @brief Sobrecarga operador <<, funciona como Comando.
  Gnuplot &  operator<< (const std::string & cmdstr);

  //---------------------------------------------------------------------------------------------
  /// @brief Mostrar na tela ou escrever no arquivo, seta o tipo de terminal para terminal_std.
  Gnuplot &  showonscreen ();		// Janela de saida e setada como default (win/x11/aqua)

  /// @brief Mostrar na tela ou escrever no arquivo, seta o tipo de terminal para terminal_std.
  Gnuplot &  ShowOnScreen ()                      { return showonscreen();  };

  /// @brief Salva sessao do gnuplot para um arquivo postscript, nome do arquivo sem extensao 
  Gnuplot &  savetops (const std::string & filename = "gnuplot_output");

  /// @brief Salva sessao do gnuplot para um arquivo postscript, nome do arquivo sem extensao 
  Gnuplot &  SaveTops (const std::string & filename = "gnuplot_output") 	
			                          { return savetops(filename); }

  //--------------------------------------------------------------------------------- set e unset
  /// @brief  Seta estilos de linhas (em alguns casos sao necessarias informacoes adicionais).
  /// lines, points, linespoints, impulses, dots, steps, fsteps, histeps,
  /// boxes, histograms, filledcurves
  Gnuplot &  set_style (const std::string & stylestr = "points");

  /// @brief  Seta estilos de linhas (em alguns casos sao necessarias informacoes adicionais).
  /// lines, points, linespoints, impulses, dots, steps, fsteps, histeps,
  /// boxes, histograms, filledcurves
  Gnuplot &  Style (const std::string & stylestr = "points") 
						 { return set_style(stylestr); }

  /// @brief  Ativa suavizacao.
  /// Argumentos para interpolacoes e aproximacoes.
  /// csplines, bezier, acsplines (para dados com valor > 0), sbezier, unique, 
  /// frequency (funciona somente com plot_x, plot_xy, plotfile_x, 
  /// plotfile_xy (se a suavizacao esta ativa, set_style nao tem efeito na plotagem dos graficos)
  Gnuplot &  set_smooth (const std::string & stylestr = "csplines");

  /// @brief  Desativa suavizacao.
  Gnuplot &  unset_smooth ();		// A suavizacao nao e setada por padrao (default)

  /// @brief  Ativa suavizacao.
  /// Argumentos para interpolacoes e aproximacoes.
  /// csplines, bezier, acsplines (para dados com valor > 0), sbezier, unique, 
  /// frequency (funciona somente com plot_x, plot_xy, plotfile_x, 
  /// plotfile_xy (se a suavizacao esta ativa, set_style nao tem efeito na plotagem dos graficos)
  Gnuplot &  Smooth(const std::string & stylestr = "csplines") 	
						{ return set_smooth(stylestr); }

  Gnuplot &  Smooth( int _fsmooth ) 
                                                { if( fsmooth = _fsmooth )
						      return set_contour(); 
						  else 
						      return unset_contour();
                                                }
  /// @brief  Desativa suavizacao.
  //Gnuplot &  UnsetSmooth()		        { return unset_smooth (); }

  /// @brief Escala o tamanho do ponto usado na plotagem.
  Gnuplot &  set_pointsize (const double pointsize = 1.0);

  /// @brief Escala o tamanho do ponto usado na plotagem.
  Gnuplot &  PointSize (const double pointsize = 1.0)
						{ return set_pointsize(pointsize); }

  /// @brief Ativa o grid (padrao = desativado).
  Gnuplot &  set_grid ();

  /// @brief Desativa o grid (padrao = desativado).
  Gnuplot &  unset_grid ();	

  /// @brief Ativa/Desativa o grid (padrao = desativado).
  Gnuplot &  Grid(bool _fgrid = 1) 
						{ if(fgrid = _fgrid) 
						    return set_grid(); 
						  else 
						    return unset_grid(); }

  /// @brief Seta taxa de amostragem das funcoes, ou dos dados de interpolacao.
  Gnuplot &  set_samples (const int samples = 100);

  /// @brief Seta taxa de amostragem das funcoes, ou dos dados de interpolacao.
  Gnuplot &  Samples(const int samples = 100)	{ return set_samples(samples); }

  /// @brief Seta densidade de isolinhas para plotagem de funcoes como superficies (para plotagen 3d).
  Gnuplot &  set_isosamples (const int isolines = 10);

  /// @brief Seta densidade de isolinhas para plotagem de funcoes como superficies (para plotagen 3d).
  Gnuplot &  IsoSamples (const int isolines = 10){ return set_isosamples(isolines); }

  /// @brief Ativa remocao de linhas ocultas na plotagem de superficies (para plotagen 3d).
  Gnuplot &  set_hidden3d ();

  /// @brief Desativa remocao de linhas ocultas na plotagem de superficies (para plotagen 3d).
  Gnuplot &  unset_hidden3d ();		// hidden3d nao e setado por padrao (default)

  /// @brief Ativa/Desativa remocao de linhas ocultas na plotagem de superficies (para plotagen 3d).
  Gnuplot &  Hidden3d(bool _fhidden3d = 1) 
						{ if(fhidden3d = _fhidden3d) 
						      return set_hidden3d(); 
						  else 
						      return unset_hidden3d();
						}

  /// @brief Ativa desenho do contorno em superficies (para plotagen 3d).
  /// @param base, surface, both.
  Gnuplot &  set_contour (const std::string & position = "base");

  /// @brief Desativa desenho do contorno em superficies (para plotagen 3d).
  Gnuplot &  unset_contour ();		// contour nao e setado por default

  /// @brief Ativa/Desativa desenho do contorno em superficies (para plotagen 3d).
  /// @param base, surface, both.
  Gnuplot &  Contour(const std::string & position = "base") 
                                                { return set_contour(position); } 
					
  Gnuplot &  Contour( int _fcontour ) 
						{ if( fcontour = _fcontour )
						      return set_contour(); 
						  else 
						      return unset_contour();
                                                }  
  /// @brief  Ativa a visualizacao da superficie (para plotagen 3d).
  Gnuplot &  set_surface ();		// surface e setado por padrao (default)

  /// @brief  Desativa a visualizacao da superficie (para plotagen 3d).
  Gnuplot &  unset_surface ();

  /// @brief  Ativa/Desativa a visualizacao da superficie (para plotagen 3d).
  Gnuplot &  Surface( int _fsurface = 1 ) 
						{ if(fsurface = _fsurface) 
						      return set_surface(); 
						  else 
						      return unset_surface();
						}
  /// @brief Ativa a legenda (a legenda é setada por padrao).
  /// Posicao: inside/outside, left/center/right, top/center/bottom, nobox/box
  Gnuplot &  set_legend (const std::string & position = "default");	

  /// @brief Desativa a legenda (a legenda é setada por padrao).
  Gnuplot &  unset_legend ();

  /// @brief Ativa/Desativa a legenda (a legenda é setada por padrao).
  Gnuplot &  Legend(const std::string & position = "default") 
                                                { return set_legend(position); }

  /// @brief Ativa/Desativa a legenda (a legenda é setada por padrao).
  Gnuplot &  Legend(int _flegend) 
						{ if(flegend = _flegend) 
						      return set_legend(); 
						  else 
						      return unset_legend();
						}

  /// @brief Ativa o titulo da secao do gnuplot.
  Gnuplot &  set_title (const std::string & title = "");

  /// @brief Desativa o titulo da secao do gnuplot.
  Gnuplot &  unset_title ();		// O title nao e setado por padrao (default)

  /// @brief Ativa/Desativa o titulo da secao do gnuplot.
  Gnuplot &  Title(const std::string & title = "") 
                                                { 
						 return set_title(title); 
						}
  Gnuplot &  Title(int _ftitle) 
                                                { 
						 if(ftitle = _ftitle)  
						   return set_title();
						 else
						   return unset_title(); 
						}
    
  /// @brief Seta o rotulo (nome) do eixo y.
  Gnuplot &  set_ylabel (const std::string & label = "y");

  /// @brief Seta o rotulo (nome) do eixo y.
  Gnuplot &  YLabel(const std::string & label = "y")
						{ return set_ylabel(label); }

  /// @brief Seta o rotulo (nome) do eixo x.
  Gnuplot &  set_xlabel (const std::string & label = "x");

  /// @brief Seta o rotulo (nome) do eixo x.
  Gnuplot &  XLabel(const std::string & label = "x")
						{ return set_xlabel(label); }

  /// @brief Seta o rotulo (nome) do eixo z.
  Gnuplot &  set_zlabel (const std::string & label = "z");

  /// @brief Seta o rotulo (nome) do eixo z.
  Gnuplot &  ZLabel(const std::string & label = "z")
						{ return set_zlabel(label); }
  
  /// @brief Seta intervalo do eixo x.
  Gnuplot &  set_xrange (const int iFrom, const int iTo);

  /// @brief Seta intervalo do eixo x.
  Gnuplot &  XRange (const int iFrom, const int iTo) 
						{ return set_xrange(iFrom,iTo); }
  
  /// @brief Seta intervalo do eixo y.
  Gnuplot &  set_yrange (const int iFrom, const int iTo);

  /// @brief Seta intervalo do eixo y.
  Gnuplot &  YRange (const int iFrom, const int iTo) 
						{ return set_yrange(iFrom,iTo); }

  /// @brief Seta intervalo do eixo z.
  Gnuplot &  set_zrange (const int iFrom, const int iTo);

  /// @brief Seta intervalo do eixo z.
  Gnuplot &  ZRange (const int iFrom, const int iTo) 
						{ return set_zrange(iFrom,iTo); }

  /// @brief Seta escalonamento automatico do eixo x (default).
  Gnuplot &  set_xautoscale ();

  /// @brief Seta escalonamento automatico do eixo x (default).
  Gnuplot &  XAutoscale()			{ return set_xautoscale (); }

  /// @brief Seta escalonamento automatico do eixo y (default).
  Gnuplot &  set_yautoscale ();

  /// @brief Seta escalonamento automatico do eixo y (default).
  Gnuplot &  YAutoscale()			{ return set_yautoscale (); }

  /// @brief Seta escalonamento automatico do eixo z (default).
  Gnuplot &  set_zautoscale ();

  /// @brief Seta escalonamento automatico do eixo z (default).
  Gnuplot &  ZAutoscale()			{ return set_zautoscale (); }

  /// @brief Ativa escala logaritma do eixo x (logscale nao e setado por default).
  Gnuplot &  set_xlogscale (const double base = 10);

  /// @brief Desativa escala logaritma do eixo x (logscale nao e setado por default).
  Gnuplot &  unset_xlogscale ();

  /// @brief Ativa escala logaritma do eixo x (logscale nao e setado por default).
  Gnuplot &  XLogscale (const double base = 10)	{ //if(base)
						    return set_xlogscale (base);
						    //else
                                                    //return unset_xlogscale ();
                                                }

  /// @brief Ativa/Desativa escala logaritma do eixo x (logscale nao e setado por default).
  Gnuplot &  XLogscale(bool _fxlogscale) 
  					        { if(fxlogscale = _fxlogscale) 
  					            return set_xlogscale(); 
  					          else 
  					            return unset_xlogscale();
  					        }

  /// @brief Ativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  set_ylogscale (const double base = 10);

  /// @brief Ativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  YLogscale (const double base = 10)	{ return set_ylogscale (base); }

  /// @brief Desativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  unset_ylogscale ();

  /// @brief Ativa/Desativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  YLogscale(bool _fylogscale) 
						{ if(fylogscale = _fylogscale) 
						      return set_ylogscale(); 
						  else 
						      return unset_ylogscale();
						}

  /// @brief Ativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  set_zlogscale (const double base = 10);

  /// @brief Ativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  ZLogscale (const double base = 10)	{ return set_zlogscale (base); }

  /// @brief Desativa escala logaritma do eixo z (logscale nao e setado por default).
  Gnuplot &  unset_zlogscale ();

  /// @brief Ativa/Desativa escala logaritma do eixo y (logscale nao e setado por default).
  Gnuplot &  ZLogscale(bool _fzlogscale) 
						{ if(fzlogscale = _fzlogscale) 
						      return set_zlogscale(); 
						  else 
						      return unset_zlogscale();
						}

  
  /// @brief Seta intervalo da palette (autoscale por padrao).
  Gnuplot &  set_cbrange (const int iFrom, const int iTo);

  /// @brief Seta intervalo da palette (autoscale por padrao).
  Gnuplot &  CBRange(const int iFrom, const int iTo)
						{ return set_cbrange(iFrom, iTo); }

  //----------------------------------------------------------------------------------
  /// @brief Plota dados de um arquivo de disco.
  Gnuplot &  plotfile_x (const std::string & filename,
	      const int column = 1, const std::string & title = "");

  /// @brief Plota dados de um arquivo de disco.
  Gnuplot &  PlotFile (const std::string & filename,
	      const int column = 1, const std::string & title = "")
						{ return plotfile_x(filename, column, title);	}

  /// @brief Plota dados de um vector.
  Gnuplot &  plot_x (const std::vector < double >&x, const std::string & title = "");

  /// @brief Plota dados de um vector.
  Gnuplot &  PlotVector (const std::vector < double >&x, const std::string & title = "")
						{ return plot_x( x, title ); } 

  /// @brief Plota pares x,y a partir de um arquivo de disco.
  Gnuplot &  plotfile_xy (const std::string & filename,
	       const int column_x = 1,
	       const int column_y = 2, const std::string & title = "");
  /// @brief Plota pares x,y a partir de um arquivo de disco.
  Gnuplot &  PlotFile (const std::string & filename,
	       const int column_x = 1,
	       const int column_y = 2, const std::string & title = "")
						{ 
						return plotfile_xy(filename, column_x, column_y, title );
						} 

  /// @brief Plota pares x,y a partir de vetores.
  Gnuplot &  plot_xy (const std::vector < double >&x,
	   const std::vector < double >&y, const std::string & title = "");

  /// @brief Plota pares x,y a partir de vetores.
  Gnuplot &  PlotVector (const std::vector < double >&x,
	   const std::vector < double >&y, const std::string & title = "")
						{ return plot_xy ( x, y,title ); }

  /// @brief Plota pares x,y com barra de erro dy a partir de um arquivo.
  Gnuplot &  plotfile_xy_err (const std::string & filename,
		   const int column_x = 1,
		   const int column_y = 2,
		   const int column_dy = 3, const std::string & title = "");

  /// @brief Plota pares x,y com barra de erro dy a partir de um arquivo.
  Gnuplot &  PlotFileXYErrorBar(const std::string & filename,
		   const int column_x = 1,
		   const int column_y = 2,
		   const int column_dy = 3, const std::string & title = "")
						  { return plotfile_xy_err(filename,
						    column_x, column_y, column_dy, title ); } 

  /// @brief Plota pares x,y com barra de erro dy a partir de vetores.
  Gnuplot &  plot_xy_err (const std::vector < double >&x,
	       const std::vector < double >&y,
	       const std::vector < double >&dy,
	       const std::string & title = "");

  /// @brief Plota pares x,y com barra de erro dy a partir de vetores.
  Gnuplot &  PlotVectorXYErrorBar(const std::vector < double >&x,
	       const std::vector < double >&y,
	       const std::vector < double >&dy,
	       const std::string & title = "")
						    { return plot_xy_err(x, y, dy, title); }

  /// @brief  Plota valores de x,y,z a partir de um arquivo de disco.
  Gnuplot &  plotfile_xyz (const std::string & filename,
		const int column_x = 1,
		const int column_y = 2,
		const int column_z = 3, const std::string & title = "");
  /// @brief  Plota valores de x,y,z a partir de um arquivo de disco.
  Gnuplot &  PlotFile (const std::string & filename,
		const int column_x = 1,
		const int column_y = 2,
		const int column_z = 3, const std::string & title = "")
						    { return plotfile_xyz(filename, column_x,
						      column_y,column_z); }

  /// @brief  Plota valores de x,y,z a partir de vetores.
  Gnuplot &  plot_xyz (const std::vector < double >&x,
	    const std::vector < double >&y,
	    const std::vector < double >&z, const std::string & title = "");

  /// @brief  Plota valores de x,y,z a partir de vetores.
  Gnuplot &  PlotVector(const std::vector < double >&x,
	    const std::vector < double >&y,
	    const std::vector < double >&z, const std::string & title = "")
						    { return plot_xyz(x, y, z, title); }

  /// @brief Plota uma equacao da forma y = ax + b, voce fornece os coeficientes a e b.
  Gnuplot &  plot_slope (const double a, const double b, const std::string & title = "");

  /// @brief Plota uma equacao da forma y = ax + b, voce fornece os coeficientes a e b.
  Gnuplot &  PlotSlope  (const double a, const double b, const std::string & title = "")
						    { return plot_slope(a,b,title); }

  /// @brief Plota uma  equacao fornecida como uma std::string y=f(x).
  /// Escrever somente a funcao f(x) e nao y= 
  /// A variavel independente deve ser x
  /// Os operadores binarios aceitos sao: 
  /// ** exponenciacao, 
  ///  * multiplicacao, 
  /// / divisao, 
  /// + adicao, 
  /// - subtracao, 
  /// % modulo
  /// Os operadores unarios aceitos sao: 
  /// - menos, 
  /// ! fatorial
  /// Funcoes elementares: 
  /// rand(x), abs(x), sgn(x), ceil(x), floor(x), int(x), imag(x), real(x), arg(x),
  /// sqrt(x), exp(x), log(x), log10(x), sin(x), cos(x), tan(x), asin(x), acos(x), 
  /// atan(x), atan2(y,x), sinh(x), cosh(x), tanh(x), asinh(x), acosh(x), atanh(x)
  /// Funcoes especiais: 
  /// erf(x), erfc(x), inverf(x), gamma(x), igamma(a,x), lgamma(x), ibeta(p,q,x),
  /// besj0(x), besj1(x), besy0(x), besy1(x), lambertw(x)
  /// Funcoes estatisticas: 
  /// norm(x), invnorm(x)
  Gnuplot &  plot_equation (const std::string & equation,
		 const std::string & title = "");

  /// @brief Plota uma  equacao fornecida como uma std::string y=f(x).
  /// Escrever somente a funcao f(x) e nao y= 
  /// A variavel independente deve ser x.
  /// Exemplo: gnuplot->PlotEquation(CFuncao& obj); 
  // Deve receber um CFuncao, que tem cast para string.
  Gnuplot &  PlotEquation(const std::string & equation,
		 const std::string & title = "")
					      { return plot_equation( equation, title ); }

  /// @brief Plota uma equacao fornecida na forma de uma std::string z=f(x,y).
  /// Escrever somente a funcao f(x,y) e nao z=, as variaveis independentes sao x e y.
  Gnuplot &  plot_equation3d (const std::string & equation, const std::string & title = "");

  /// @brief Plota uma equacao fornecida na forma de uma std::string z=f(x,y).
  /// Escrever somente a funcao f(x,y) e nao z=, as vaiaveis independentes sao x e y.
  // gnuplot->PlotEquation3d(CPolinomio());
  Gnuplot &  PlotEquation3d (const std::string & equation,
		   const std::string & title = "")
					      { return plot_equation3d( equation, title ); }

  /// @brief Plota uma imagem.
  Gnuplot &  plot_image (const unsigned char *ucPicBuf,
	      const int iWidth, const int iHeight, const std::string & title = "");

  /// @brief Plota uma imagem.
  Gnuplot &  PlotImage (const unsigned char *ucPicBuf,
			const int iWidth, const int iHeight, const std::string & title = "")
                                              { return plot_image (ucPicBuf, iWidth, iHeight, title); }

  //----------------------------------------------------------------------------------
  // Repete o ultimo comando de plotagem, seja plot (2D) ou splot (3D)
  // Usado para visualizar plotagens, após mudar algumas opcoes de plotagem
  // ou quando gerando o mesmo grafico para diferentes dispositivos (showonscreen, savetops)
  Gnuplot &  replot ();

  // Repete o ultimo comando de plotagem, seja plot (2D) ou splot (3D)
  // Usado para visualizar plotagens, após mudar algumas opcoes de plotagem
  // ou quando gerando o mesmo grafico para diferentes dispositivos (showonscreen, savetops)
  Gnuplot &  Replot() 				{ return replot(); }

  // Reseta uma sessao do gnuplot (próxima plotagem apaga definicoes previas)
  Gnuplot &  reset_plot ();

  // Reseta uma sessao do gnuplot (próxima plotagem apaga definicoes previas)
  Gnuplot &  ResetPlot() 			{ return reset_plot(); }
  // Reseta uma sessao do gnuplot (próxima plotagem apaga definicoes previas)
  Gnuplot &  Reset()        			{ return reset_plot(); }

  // Reseta uma sessao do gnuplot e seta todas as variaveis para o default
  Gnuplot &  reset_all ();

  // Reseta uma sessao do gnuplot e seta todas as variaveis para o default
  Gnuplot &  ResetAll () 			{ return reset_all(); }

  // Verifica se a sessao esta valida
  bool  is_valid ();

  // Verifica se a sessao esta valida
  bool  IsValid ()				{ return is_valid (); };

};
typedef Gnuplot CGnuplot;
#endif


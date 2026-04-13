import 'dart:io';
import 'dart:math';

class Buscaminas {
  // variables
  static const int numFilas = 6;
  static const int numColumnas = 10;
  static const int totalMinas = 8;

  //matrices tablero
  late List<List<String>> celdas;
  late List<List<bool>> tieneMina;
  late List<List<bool>> estaRevelada;
  late List<List<bool>> tieneBandera;

  // flags
  bool perdio = false;
  bool gano = false;
  int intentos = 0;
  bool modoTrampa = false;
  Random azar = Random();

  Buscaminas() {
    inicializar();
  }

  void inicializar() {
    // casillas + mina
    celdas = List.generate(numFilas, (i) => List.filled(numColumnas, '·'));
    tieneMina = List.generate(
      numFilas,
      (i) => List.filled(numColumnas, false),
    ); // matriz de bools, false = no hay mina
    estaRevelada = List.generate(
      numFilas,
      (i) => List.filled(numColumnas, false),
    ); // estado de las casillas, false = no reveladas
    tieneBandera = List.generate(
      numFilas,
      (i) => List.filled(numColumnas, false),
    );

    perdio = false;
    gano = false;
    intentos = 0;
    modoTrampa = false;

    generarMinas();
    forzarMinasPorCuadrante(); // al menos 2 minas en cada cuadrante
  }

  void generarMinas() {
    int minasColocadas = 0;

    while (minasColocadas < totalMinas) {
      // 8 total minas
      int fila = azar.nextInt(numFilas);
      int columna = azar.nextInt(numColumnas);

      if (!tieneMina[fila][columna]) {
        tieneMina[fila][columna] = true;
        minasColocadas++;
      }
    }
  }

  void forzarMinasPorCuadrante() {
    // divide el tablero en 4 zonas (2 minas por zona)

    // cuadrante 1 [0,2] filas y [0,4] columnas
    // cuadrante 2 [0,2] filas y [5,9] columnas
    // cuadrante 3 [3,5] filas y [0,4] columnas
    // cuadrante 4 [3,5] filas y [5,9] columnas

    Map<int, int> minasPorCuadrante = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
    }; // contador minas

    // recorre tablero
    for (int fila = 0; fila < numFilas; fila++) {
      for (int columna = 0; columna < numColumnas; columna++) {
        if (tieneMina[fila][columna]) {
          int cuadrante = obtenerCuadrante(fila, columna);
          minasPorCuadrante[cuadrante] =
              (minasPorCuadrante[cuadrante] ?? 0) + 1; // suma mina encontrada
        }
      }
    }

    // 2 minas minim
    for (int cuadrante = 1; cuadrante <= 4; cuadrante++) {
      while ((minasPorCuadrante[cuadrante] ?? 0) < 2) {
        var posicion = obtenerPosicionEnCuadrante(
          cuadrante,
        ); // posicion aleatoria en el cuadrante
        int fila = posicion[0], columna = posicion[1];

        if (!tieneMina[fila][columna]) {
          // si un cuadrante tiene + de 2 minas, quitar
          for (int otroCuadrante = 1; otroCuadrante <= 4; otroCuadrante++) {
            if (otroCuadrante != cuadrante &&
                (minasPorCuadrante[otroCuadrante] ?? 0) > 2) {
              for (int filaAux = 0; filaAux < numFilas; filaAux++) {
                for (
                  int columnaAux = 0;
                  columnaAux < numColumnas;
                  columnaAux++
                ) {
                  if (tieneMina[filaAux][columnaAux] &&
                      obtenerCuadrante(filaAux, columnaAux) == otroCuadrante) {
                    tieneMina[filaAux][columnaAux] = false;
                    minasPorCuadrante[otroCuadrante] =
                        (minasPorCuadrante[otroCuadrante] ?? 0) - 1;

                    tieneMina[fila][columna] = true;
                    minasPorCuadrante[cuadrante] =
                        (minasPorCuadrante[cuadrante] ?? 0) + 1;

                    break;
                  }
                }
                if (tieneMina[fila][columna]) break;
              }
              break;
            }
          }

          if (!tieneMina[fila][columna]) {
            // si no se pudo quitar de otro agregar 1 nueva
            tieneMina[fila][columna] = true;
            minasPorCuadrante[cuadrante] =
                (minasPorCuadrante[cuadrante] ?? 0) + 1;
          }
        }
      }
    }
  }

  int obtenerCuadrante(int fila, int columna) {
    bool mitadSuperior = fila <= 2; // 0-2
    bool mitadIzquierda = columna <= 4; // 0-4

    if (mitadSuperior && mitadIzquierda) return 1;
    if (mitadSuperior && !mitadIzquierda) return 2;
    if (!mitadSuperior && mitadIzquierda) return 3;
    return 4; // !mitadSuperior && !mitadIzquierda
  }

  List<int> obtenerPosicionEnCuadrante(int cuadrante) {
    switch (cuadrante) {
      case 1:
        return [azar.nextInt(3), azar.nextInt(5)];
      case 2:
        return [azar.nextInt(3), azar.nextInt(5) + 5];
      case 3:
        return [azar.nextInt(3) + 3, azar.nextInt(5)];
      case 4:
        return [azar.nextInt(3) + 3, azar.nextInt(5) + 5];
      default:
        return [0, 0];
    }
  }

  int contarMinasCercanas(int fila, int columna) {
    // cercania minas
    int cantidad = 0;

    // recorre las 8 casillas y cuenta num de minas
    for (
      int desplazamientoFila = -1;
      desplazamientoFila <= 1;
      desplazamientoFila++
    ) {
      for (
        int desplazamientoColumna = -1;
        desplazamientoColumna <= 1;
        desplazamientoColumna++
      ) {
        if (desplazamientoFila == 0 && desplazamientoColumna == 0) continue;

        int filaVecina = fila + desplazamientoFila;
        int columnaVecina = columna + desplazamientoColumna;

        if (filaVecina >= 0 &&
            filaVecina < numFilas &&
            columnaVecina >= 0 &&
            columnaVecina < numColumnas) {
          if (tieneMina[filaVecina][columnaVecina]) {
            cantidad++;
          }
        }
      }
    }

    return cantidad;
  }

  bool destaparCasilla(
    int fila,
    int columna,
    bool esPrimeraJugada,
    bool esJugadaUsuario,
  ) {
    // limites tablero check
    if (fila < 0 || fila >= numFilas || columna < 0 || columna >= numColumnas) {
      return false;
    }

    // descubierta o con flag check
    if (estaRevelada[fila][columna] || tieneBandera[fila][columna]) {
      return false;
    }

    // es mina?
    if (tieneMina[fila][columna]) {
      if (esPrimeraJugada) {
        moverMina(
          fila,
          columna,
        ); // si hay mina en primera jugada, mover a otra casilla
        return destaparCasilla(fila, columna, false, false);
      } else if (esJugadaUsuario) {
        return true; // boom
      } else {
        return false; // no boom
      }
    }

    // minas
    int minasAlrededor = contarMinasCercanas(fila, columna);
    estaRevelada[fila][columna] = true;

    // tablero reload
    if (minasAlrededor == 0) {
      celdas[fila][columna] = ' ';
    } else {
      celdas[fila][columna] = minasAlrededor.toString();
    }

    // si no hay minas al rededor de la casilla destapada, liberar las de alrededor
    if (minasAlrededor == 0) {
      for (
        int desplazamientoFila = -1;
        desplazamientoFila <= 1;
        desplazamientoFila++
      ) {
        for (
          int desplazamientoColumna = -1;
          desplazamientoColumna <= 1;
          desplazamientoColumna++
        ) {
          if (desplazamientoFila == 0 && desplazamientoColumna == 0)
            continue; // evita posicion casilla

          int filaVecina = fila + desplazamientoFila; // nueva fila
          int columnaVecina = columna + desplazamientoColumna; // nueva columna

          destaparCasilla(filaVecina, columnaVecina, false, false);
        }
      }
    }

    return false;
  }

  // mover mina por primera jugada
  void moverMina(int filaOriginal, int columnaOriginal) {
    tieneMina[filaOriginal][columnaOriginal] = false;

    while (true) {
      // buscador pos vacia
      int fila = azar.nextInt(numFilas);
      int columna = azar.nextInt(numColumnas);

      if (!tieneMina[fila][columna] &&
          (fila != filaOriginal || columna != columnaOriginal)) {
        tieneMina[fila][columna] = true;
        break;
      }
    }
  }

  // tablero print
  void mostrarTablero() {
    print('\n 0123456789');

    for (int fila = 0; fila < numFilas; fila++) {
      String lineaFila = String.fromCharCode('A'.codeUnitAt(0) + fila);

      for (int columna = 0; columna < numColumnas; columna++) {
        if (tieneBandera[fila][columna]) {
          lineaFila += '#';
        } else if (!estaRevelada[fila][columna]) {
          lineaFila += '·';
        } else {
          lineaFila += celdas[fila][columna];
        }
      }

      print(lineaFila);
    }
  }

  // tablero trampas?
  void mostrarTableroCompleto() {
    print('\n 0123456789');

    for (int fila = 0; fila < numFilas; fila++) {
      String lineaFila = String.fromCharCode('A'.codeUnitAt(0) + fila);

      for (int columna = 0; columna < numColumnas; columna++) {
        if (tieneMina[fila][columna]) {
          lineaFila += '*';
        } else if (tieneBandera[fila][columna]) {
          lineaFila += '#';
        } else if (!estaRevelada[fila][columna]) {
          lineaFila += '·';
        } else {
          lineaFila += celdas[fila][columna];
        }
      }

      print(lineaFila);
    }
  }

  void mostrarAmbosTableros() {
    print(' 0123456789     0123456789');

    for (int fila = 0; fila < numFilas; fila++) {
      String lineaJuego = String.fromCharCode('A'.codeUnitAt(0) + fila);
      String lineaMinas = String.fromCharCode('A'.codeUnitAt(0) + fila);

      for (int columna = 0; columna < numColumnas; columna++) {
        // tab de juego
        if (tieneBandera[fila][columna]) {
          lineaJuego += '#';
        } else if (!estaRevelada[fila][columna]) {
          lineaJuego += '·';
        } else {
          lineaJuego += celdas[fila][columna];
        }

        // tab de minas
        if (tieneMina[fila][columna]) {
          lineaMinas += '*';
        } else if (tieneBandera[fila][columna]) {
          lineaMinas += '#';
        } else if (!estaRevelada[fila][columna]) {
          lineaMinas += '·';
        } else {
          lineaMinas += celdas[fila][columna];
        }
      }

      print('$lineaJuego    $lineaMinas');
    }
  }

  void toggleBandera(int fila, int columna) {
    if (estaRevelada[fila][columna]) {
      print('No se puede poner bandera en casilla descubierta');
      return;
    }

    tieneBandera[fila][columna] = !tieneBandera[fila][columna];
  }

  bool verificarVictoria() {
    for (int fila = 0; fila < numFilas; fila++) {
      for (int columna = 0; columna < numColumnas; columna++) {
        // si hay una mina sin bandera o una casilla sin mina sin descubrir
        if ((tieneMina[fila][columna] && !tieneBandera[fila][columna]) ||
            (!tieneMina[fila][columna] && !estaRevelada[fila][columna])) {
          return false;
        }
      }
    }
    return true;
  }

  void procesarComando(String comando) {
    comando = comando.trim();

    if (comando.isEmpty) {
      return;
    }

    // comandos ayuda
    if (comando.toLowerCase() == 'ayuda') {
      print('\n------ COMANDOS DISPONIBLES ------\n');
      print('- Seleccionar casilla: Letra + Número (ej: B2, D5)');
      print(
        '- Poner/Quitar bandera: Casilla + "flag" o "bandera" (ej: E1 flag)',
      );
      print('- Mostrar trucos: "cheat" o "trampas"');
      print('- Ayuda: "ayuda"');
      return;
    }

    // trampas
    if (comando.toLowerCase() == 'cheat' ||
        comando.toLowerCase() == 'trampas') {
      modoTrampa = !modoTrampa;
      if (modoTrampa) {
        mostrarAmbosTableros();
      } else {
        mostrarTablero();
      }
      return;
    }

    // casilla con bandera check
    var partes = comando.split(' ');
    if (partes.length == 2) {
      String posicion = partes[0];
      String accion = partes[1].toLowerCase();

      if (posicion.length >= 2) {
        String letraFila = posicion[0].toUpperCase();
        String numColumna = posicion.substring(1);

        int fila = letraFila.codeUnitAt(0) - 'A'.codeUnitAt(0);

        if (int.tryParse(numColumna) != null) {
          int columna = int.parse(numColumna);

          if (fila >= 0 &&
              fila < numFilas &&
              columna >= 0 &&
              columna < numColumnas) {
            if (accion == 'flag' || accion == 'bandera') {
              toggleBandera(fila, columna);
              if (modoTrampa) {
                mostrarAmbosTableros();
              } else {
                mostrarTablero();
              }
              return;
            }
          }
        }
      }
    }

    // Si es solo una posición, destapar
    if (partes.length == 1 && partes[0].length >= 2) {
      String posicion = partes[0];
      String letraFila = posicion[0].toUpperCase();
      String numColumna = posicion.substring(1);

      int fila = letraFila.codeUnitAt(0) - 'A'.codeUnitAt(0);

      if (int.tryParse(numColumna) != null) {
        int columna = int.parse(numColumna);

        if (fila >= 0 &&
            fila < numFilas &&
            columna >= 0 &&
            columna < numColumnas) {
          // Verificar si es bandera
          if (tieneBandera[fila][columna]) {
            // Si es bandera, destapar (quitar bandera y destapar)
            tieneBandera[fila][columna] = false;
            intentos++;
            bool explosion = destaparCasilla(
              fila,
              columna,
              intentos == 1,
              true,
            );

            if (explosion) {
              perdio = true;
              mostrarTableroCompleto();
              print('\nHas perdido');
              print('Número de tiradas: $intentos');
            } else {
              if (verificarVictoria()) {
                gano = true;
                mostrarTablero();
                print('\nHas ganado');
                print('Número de tiradas: $intentos');
              } else if (modoTrampa) {
                mostrarAmbosTableros();
              } else {
                mostrarTablero();
              }
            }
          } else {
            // destapar normal
            intentos++;
            bool explosion = destaparCasilla(
              fila,
              columna,
              intentos == 1,
              true,
            );

            if (explosion) {
              perdio = true;
              mostrarTableroCompleto();
              print('\nHas perdido');
              print('Número de tiradas: $intentos');
            } else {
              if (verificarVictoria()) {
                gano = true;
                mostrarTablero();
                print('\nHas ganado');
                print('Número de tiradas: $intentos');
              } else if (modoTrampa) {
                mostrarAmbosTableros();
              } else {
                mostrarTablero();
              }
            }
          }
          return;
        }
      }
    }

    print(
      'Comando no reconocido. Escribe "ayuda" para ver los comandos disponibles.',
    );
  }

  void jugar() {
    print('------ BUSCAMINAS ------');
    print('Tablero: 6 filas x 10 columnas');
    print('8 minas colocadas aleatoriamente');
    print('Escribe "ayuda" para ver los comandos\n');

    mostrarTablero();

    while (!perdio && !gano) {
      stdout.write('\Escribe un comando: ');
      String comando = stdin.readLineSync() ?? '';
      procesarComando(comando);
    }
  }
}

void main() {
  Buscaminas juego = Buscaminas();
  juego.jugar();
}

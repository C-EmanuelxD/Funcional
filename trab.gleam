import gleam/int
import gleam/order
import gleam/string
import sgleam/check

pub type Resultado {
  //Estrutura para o resultado do jogo, com times e gols
  Resultado(time_um: String, gol_um: Gol, time_dois: String, gol_dois: Gol)
}

pub type Desempenho {
  //Estrutura para O desmpenho completo do time, com o time, pontos, vitorias e saldo de gol respectivamente.
  Desempenho(time: String, pontos: Int, vitorias: Int, saldo_gol: Int)
}

pub opaque type Gol {
  //Tipo para criar um gol inteiro e positivo.
  Gol(gol: Int)
}

//Construtor do tipo Gol, que deve ser um inteiro positivo
pub fn new_gol(gol: Int) -> Result(Gol, Erros) {
  case gol >= 0 {
    True -> Ok(Gol(gol))
    False -> Error(PlacarInvalido)
  }
}

//"Desencapsula" o valor inteiro de dentro do tipo gol
pub fn valor_gol(x: Gol) -> Int {
  x.gol
}

//Tipo de erros que podem acontecer durante a execução do código
pub type Erros {
  //Quando dois times iguais jogam o mesmo jogo ex.: Goiás 0 Goiás 0
  TimeDuplicado
  //Quando existem dois jogos iguais ex.: Flamengo 1 Palmeiras 0, Flamengo 1 Palmeiras 1
  JogoDuplicado
  //Quando o placar tem valores inválidos de gols ex.: Goiás -3 Santos -7
  PlacarInvalido
  //Caso de string vazia/haver apenas um único time
  CamposIncompletos
  //Caso a string possua mais campos que o esperado
  MaxCamposExcedidos
  //Caso a lista de jogos inicial esteja vazia
  ListaVazia
}

//Função que transforma uma lista de jogos do campeonato brasileiro e transforma ela em uma
//tabela de pontuações dos times, contendo Pontuação, saldo de gols e número de vitórias.
//A função recebe uma lista de strings de *Jogo*, com cada jogo contendo os *times* e *gols*,
//ao final ela deve devolver uma lista de Strings com uma tabela exibindo as pontuações
//dos time no campeonato:  o saldo de gols (gols sofridos - gols feitos), a pontuação total (Empate: 1 ponto, 
//Vitória: 3 pontos, Derrota: 0 Pontos) dos times e o número de vitórias totais de cada time.
//Essa lista deve ser ordenada com prioridades sendo: Pontuação, número e vitórias, Saldo de gols e 
//por fim Ordem alfabética dos nomes dos times.
pub fn main_brasileirao(lst_jogos: List(String)) -> Result(List(String), Erros) {
  case lst_jogos == [] {
    True -> Error(ListaVazia)
    False -> {
      case cria_resultado(lst_jogos) {
        Ok(lst) ->
          Ok(
            desempenho_to_string(
              ordena_lista_desempenhos(
                mescla_desempenho(cria_lista_desempenho(lst)),
              ),
            ),
          )
        Error(a) -> Error(a)
      }
    }
  }
}

pub fn main_examples() {
  check.eq(
    main_brasileirao([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Ok([
      "Flamengo 6 2 2", "Atletico-MG 3 1 0", "Palmeiras 1 0 -1",
      "Sao-Paulo 1 0 -1",
    ]),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo 2", "Palmeiras 4 Botafogo 0",
      "Flamengo 2 Palmeiras 4", "Fortaleza 2 Palmeiras 1",
      "Internacional 2 Botafogo 0", "Sao-Paulo 0 Internacional 3",
      "Corinthians 4 Fortaleza 3", "Bahia 3 Flamengo 2",
      "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0", "Vitoria 1 Vasco 2",
      "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2", "Gremio 0 Corinthians 3",
      "Juventude 1 Sao-Paulo 3", "Bragantino 2 Internacional 1",
      "Athletico 2 Fortaleza 3", "Criciuma 2 Flamengo 3",
      "Atletico-Go 2 Palmeiras 4", "Cuiaba 2 Botafogo 3",
    ]),
    Ok([
      "Palmeiras 9 3 6", "Corinthians 6 2 4", "Internacional 6 2 4",
      "Bahia 6 2 3", "Vasco 6 2 3", "Fortaleza 6 2 1", "Flamengo 6 2 -1",
      "Atletico 3 1 1", "Bragantino 3 1 1", "Cruzeiro 3 1 0", "Sao-Paulo 3 1 -1",
      "Botafogo 3 1 -8", "Athletico 0 0 -1", "Criciuma 0 0 -1", "Cuiaba 0 0 -1",
      "Vitoria 0 0 -1", "Atletico-Go 0 0 -2", "Fluminense 0 0 -2",
      "Juventude 0 0 -2", "Gremio 0 0 -3",
    ]),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo2", "Palmeiras 4 Botafogo 0", "Flamengo 2 Palmeiras 4",
      "Fortaleza 2 Palmeiras 1", "Internacional 2 Botafogo 0",
      "Sao-Paulo 0 Internacional 3", "Corinthians 4 Fortaleza 3",
      "Bahia 3 Flamengo 2", "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0",
      "Vitoria 1 Vasco 2", "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2",
      "Gremio 0 Corinthians 3", "Juventude 1 Sao-Paulo 3",
      "Bragantino 2 Internacional 1", "Athletico 2 Fortaleza 3",
      "Criciuma 2 Flamengo 3", "Atletico-Go 2 Palmeiras 4",
      "Cuiaba 2 Botafogo 3",
    ]),
    Error(CamposIncompletos),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Botafogo 2", "Palmeiras 4 Botafogo 0",
      "Flamengo 2 Palmeiras 4", "Fortaleza 2 Palmeiras 1",
      "Internacional 2 Botafogo 0", "Sao-Paulo 0 Internacional 3",
      "Corinthians 4 Fortaleza 3", "Bahia 3 Flamengo 2",
      "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0", "Vitoria 1 Vasco 2",
      "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2", "Gremio 0 Corinthians 3",
      "Juventude 1 Sao-Paulo 3", "Bragantino 2 Internacional 1",
      "Athletico 2 Fortaleza 3", "Criciuma 2 Flamengo 3",
      "Atletico-Go 2 Palmeiras 4", "Cuiaba 2 Botafogo 3",
    ]),
    Error(TimeDuplicado),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo ", " ", "Palmeiras 4 Botafogo 0",
      "Flamengo 2 Palmeiras 4", "Fortaleza 2 Palmeiras 1",
      "Internacional 2 Botafogo 0", "Sao-Paulo 0 Internacional 3",
      "Corinthians 4 Fortaleza 3", "Bahia 3 Flamengo 2",
      "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0", "Vitoria 1 Vasco 2",
      "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2", "Gremio 0 Corinthians 3",
      "Juventude 1 Sao-Paulo 3", "Bragantino 2 Internacional 1",
      "Athletico 2 Fortaleza 3", "Criciuma 2 Flamengo 3",
      "Atletico-Go 2 Palmeiras 4", "Cuiaba 2 Botafogo 3",
    ]),
    Error(CamposIncompletos),
  )
  check.eq(
    main_brasileirao(["Corinthia", "", "Cortina", "0"]),
    Error(CamposIncompletos),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo ", "Palmeiras 4 Botafogo 0", "Flamengo 2 Palmeiras 4",
      "Fortaleza 2 Palmeiras 1", "Internacional 2 Botafogo 0",
      "Sao-Paulo 0 Internacional 3", "Corinthians 4 Fortaleza 3",
      "Bahia 3 Flamengo 2", "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0",
      "Vitoria 1 Vasco 2", "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2",
      "Gremio 0 Corinthians 3", "Juventude 1 Sao-Paulo 3",
      "Bragantino 2 Internacional 1", "Athletico 2 Fortaleza 3",
      "Criciuma 2 Flamengo 3", "Atletico-Go 2 Palmeiras 4",
      "Cuiaba 2 Botafogo 3  ",
    ]),
    Error(MaxCamposExcedidos),
  )
  check.eq(main_brasileirao([]), Error(ListaVazia))
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo 2", "Botafogo 1 Flamengo 2", "Flamengo 2 Palmeiras 4",
      "Fortaleza 2 Palmeiras 1", "Internacional 2 Botafogo 0",
      "Sao-Paulo 0 Internacional 3", "Corinthians 4 Fortaleza 3",
      "Bahia 3 Flamengo 2", "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0",
      "Vitoria 1 Vasco 2", "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2",
      "Gremio 0 Corinthians 3", "Juventude 1 Sao-Paulo 3",
      "Bragantino 2 Internacional 1", "Athletico 2 Fortaleza 3",
      "Criciuma 2 Flamengo 3", "Atletico-Go 2 Palmeiras 4",
      "Cuiaba 2 Botafogo 3",
    ]),
    Error(JogoDuplicado),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo 2", "Palmeiras 4 Botafogo 0",
      "Flamengo 2 Palmeiras 4", "Fortaleza 2 Palmeiras 1",
      "Internacional 2 Botafogo 0", "Sao-Paulo 0 Internacional 3",
      "Corinthians 4 Fortaleza 3", "Bahia 3 Flamengo 2",
      "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0", "Vitoria 1 Vasco 2",
      "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2", "Gremio 0 Corinthians 3",
      "Juventude 1 Sao-Paulo 3", "Bragantino 2 Internacional 1",
      "Athletico 2 Fortaleza 3", "Botafogo 1 Flamengo 2",
      "Atletico-Go 2 Palmeiras 4", "Cuiaba 2 Botafogo 3",
    ]),
    Error(JogoDuplicado),
  )
  check.eq(
    main_brasileirao([
      "Botafogo 1 Flamengo 2", "Palmeiras 4 Botafogo 0",
      "Flamengo 2 Palmeiras 4", "Fortaleza 2 Palmeiras 1",
      "Internacional 2 Botafogo 0", "Vasco 2 Botafogo 0",
      "Corinthians 4 Fortaleza 3", "Bahia 3 Flamengo 2",
      "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0", "Vitoria 1 Vasco 2",
      "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2", "Gremio 0 Corinthians 3",
      "Juventude 1 Sao-Paulo 3", "Bragantino 2 Internacional 1",
      "Athletico 2 Fortaleza 3", "Criciuma 2 Flamengo 3",
      "Atletico-Go 2 Palmeiras 4", "Cuiaba 2 Botafogo 3",
    ]),
    Error(JogoDuplicado),
  )
}

/// Função que convete uma *lista de desempenhos* ordenada em uma lista de *strings* 
/// converte cada elemento de *desemepenho* em string e depois concatena tudo em uma só string e retorna
pub fn desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  case desempenho {
    [] -> []
    [primeiro, ..resto] -> [
      primeiro.time
        <> " "
        <> int.to_string(primeiro.pontos)
        <> " "
        <> int.to_string(primeiro.vitorias)
        <> " "
        <> int.to_string(primeiro.saldo_gol),
      ..desempenho_to_string(resto)
    ]
  }
}

pub fn desempenho_to_string_examples() {
  check.eq(
    desempenho_to_string([
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Athletico", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ]),
    [
      "Abruzeiro 17 7 11", "Athletico 17 7 11", "Santos 17 5 10",
      "Internacional 14 1 22", "Vitória 14 1 2", "Flamengo 0 1 0",
      "Botafogo 0 0 0",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Botafogo", 0, 0, 0),
      Desempenho("Flamengo", 0, 1, 0),
    ]),
    [
      "Abruzeiro 17 7 11", "Palmeiras 17 7 11", "Santos 17 5 10",
      "Internacional 14 1 22", "Vitória 14 1 2", "Botafogo 0 0 0",
      "Flamengo 0 1 0",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Botafogo", 0, 0, 0),
      Desempenho("Flamengo", 0, 1, 0),
    ]),
    [
      "Abruzeiro 17 7 11", "Palmeiras 17 7 11", "Santos 17 5 10",
      "Internacional 14 1 22", "Vitória 14 1 2", "Botafogo 0 0 0",
      "Flamengo 0 1 0",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Abruzeiro", 14, 7, 12),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      "Palmeiras 17 7 11", "Santos 17 5 10", "Abruzeiro 14 7 12",
      "Internacional 14 1 22", "Vitória 14 1 2", "Botafogo 9 0 2",
      "Flamengo 5 1 2",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Santos", 20, 5, 10),
      Desempenho("Abruzeiro", 14, 7, 12),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Palmeiras", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
      Desempenho("Internacional", 3, 1, 22),
    ]),
    [
      "Santos 20 5 10", "Abruzeiro 14 7 12", "Vitória 12 1 2", "Botafogo 9 0 2",
      "Palmeiras 5 7 1", "Flamengo 5 1 2", "Internacional 3 1 22",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Santos", 12, 5, 10),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Palmeiras", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
      Desempenho("Internacional", 3, 1, 22),
      Desempenho("Abruzeiro", 1, 7, 3),
    ]),
    [
      "Santos 12 5 10", "Vitória 12 1 2", "Botafogo 9 0 2", "Palmeiras 5 7 1",
      "Flamengo 5 1 2", "Internacional 3 1 22", "Abruzeiro 1 7 3",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Santos", 12, 5, 10),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Fortaleza", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
      Desempenho("Gremio", 3, 1, 22),
      Desempenho("Criciuma", 1, 7, 3),
    ]),
    [
      "Santos 12 5 10", "Vitória 12 1 2", "Botafogo 9 0 2", "Fortaleza 5 7 1",
      "Flamengo 5 1 2", "Gremio 3 1 22", "Criciuma 1 7 3",
    ],
  )
  check.eq(
    desempenho_to_string([
      Desempenho("Gremio", 30, 1, 1),
      Desempenho("Santos", 14, 5, 10),
      Desempenho("Botafogo", 13, 0, 2),
      Desempenho("Criciuma", 12, 7, 3),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Fortaleza", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      "Gremio 30 1 1", "Santos 14 5 10", "Botafogo 13 0 2", "Criciuma 12 7 3",
      "Vitória 12 1 2", "Fortaleza 5 7 1", "Flamengo 5 1 2",
    ],
  )
}

//Função que ordena a lista de desempenhos para a formação de uma tabela
//de resultados. Os valores serão ordenados, em sequencia de importância:
//Pontos, Vitórias, Saldo de gols, Ordem alfabética.
pub fn ordena_lista_desempenhos(lst: List(Desempenho)) -> List(Desempenho) {
  case lst {
    [] -> []
    [primeiro, ..resto] ->
      inserir_lista(ordena_lista_desempenhos(resto), primeiro)
  }
}

pub fn ordena_lista_desempenhos_examples() {
  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Athletico", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ]),
    [
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Athletico", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ],
  )
  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Botafogo", 0, 0, 0),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
    ]),
    [
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Botafogo", 0, 0, 0),
      Desempenho("Flamengo", 0, 1, 0),
    ],
  )
  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Abruzeiro", 14, 7, 12),
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      Desempenho("Palmeiras", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Abruzeiro", 14, 7, 12),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ],
  )
  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Abruzeiro", 14, 7, 12),
      Desempenho("Palmeiras", 5, 7, 1),
      Desempenho("Santos", 20, 5, 10),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Internacional", 3, 1, 22),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      Desempenho("Santos", 20, 5, 10),
      Desempenho("Abruzeiro", 14, 7, 12),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Palmeiras", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
      Desempenho("Internacional", 3, 1, 22),
    ],
  )
  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Abruzeiro", 1, 7, 3),
      Desempenho("Palmeiras", 5, 7, 1),
      Desempenho("Santos", 12, 5, 10),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Internacional", 3, 1, 22),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      Desempenho("Santos", 12, 5, 10),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Palmeiras", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
      Desempenho("Internacional", 3, 1, 22),
      Desempenho("Abruzeiro", 1, 7, 3),
    ],
  )
  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Criciuma", 1, 7, 3),
      Desempenho("Fortaleza", 5, 7, 1),
      Desempenho("Santos", 12, 5, 10),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Gremio", 3, 1, 22),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      Desempenho("Santos", 12, 5, 10),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Botafogo", 9, 0, 2),
      Desempenho("Fortaleza", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
      Desempenho("Gremio", 3, 1, 22),
      Desempenho("Criciuma", 1, 7, 3),
    ],
  )

  check.eq(
    ordena_lista_desempenhos([
      Desempenho("Criciuma", 12, 7, 3),
      Desempenho("Fortaleza", 5, 7, 1),
      Desempenho("Santos", 14, 5, 10),
      Desempenho("Botafogo", 13, 0, 2),
      Desempenho("Gremio", 30, 1, 1),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Flamengo", 5, 1, 2),
    ]),
    [
      Desempenho("Gremio", 30, 1, 1),
      Desempenho("Santos", 14, 5, 10),
      Desempenho("Botafogo", 13, 0, 2),
      Desempenho("Criciuma", 12, 7, 3),
      Desempenho("Vitória", 12, 1, 2),
      Desempenho("Fortaleza", 5, 7, 1),
      Desempenho("Flamengo", 5, 1, 2),
    ],
  )
}

pub fn inserir_lista(
  lst: List(Desempenho),
  desem: Desempenho,
) -> List(Desempenho) {
  case lst {
    [] -> [desem]
    [primeiro, ..resto] -> {
      case
        { desem.pontos > primeiro.pontos },
        { desem.pontos == primeiro.pontos },
        { desem.vitorias > primeiro.vitorias },
        { desem.saldo_gol > primeiro.saldo_gol },
        { desem.saldo_gol == primeiro.saldo_gol },
        { string.compare(desem.time, primeiro.time) }
      {
        True, _, _, _, _, _ -> [desem, primeiro, ..resto]
        False, True, True, _, _, _ -> [desem, primeiro, ..resto]
        False, True, False, True, _, _ -> [desem, primeiro, ..resto]
        False, True, False, False, True, order.Lt -> [desem, primeiro, ..resto]
        False, True, False, False, True, order.Eq -> [
          primeiro,
          ..inserir_lista(resto, desem)
        ]
        False, True, False, False, True, order.Gt -> [
          primeiro,
          ..inserir_lista(resto, desem)
        ]
        _, _, _, _, _, _ -> [primeiro, ..inserir_lista(resto, desem)]
      }
    }
  }
}

//Cria uma lsita de desempenho dos times, com base na lista de resultados dos jogos. Essa lista contém 
//os desempenhos de todos os times, que podem estar repetidos.
//Percorre recursivamente a *lista de resultados* analisando cada *resultado* e os processando
//ao final retorna uma lista com os *desempenhos* de cada time.
pub fn cria_lista_desempenho(lst: List(Resultado)) -> List(Desempenho) {
  case lst {
    [] -> []
    [primeiro, ..resto] -> {
      case cria_desempenho(primeiro) {
        [] -> []
        [primeiro, segundo] -> [
          primeiro,
          segundo,
          ..cria_lista_desempenho(resto)
        ]
        _ -> cria_lista_desempenho(resto)
      }
    }
  }
}

pub fn cria_lista_desempenho_examples() {
  let assert Ok(gol1) = new_gol(4)
  let assert Ok(gol2) = new_gol(3)
  let assert Ok(gol3) = new_gol(2)
  let assert Ok(gol4) = new_gol(1)
  let assert Ok(gol5) = new_gol(5)
  let assert Ok(gol6) = new_gol(2)
  let assert Ok(gol7) = new_gol(6)
  let assert Ok(gol8) = new_gol(9)
  check.eq(
    cria_lista_desempenho([
      Resultado("Flamengo", gol2, "Santos", gol1),
      Resultado("Flamengo", gol3, "Botafogo", gol4),
      Resultado("Atletico-MG", gol1, "Athletico", gol1),
    ]),
    [
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 0, 0, -1),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Athletico", 1, 0, 0),
    ],
  )
  check.eq(
    cria_lista_desempenho([
      Resultado("Flamengo", gol6, "Santos", gol3),
      Resultado("Flamengo", gol8, "Botafogo", gol1),
      Resultado("Atletico-MG", gol3, "Athletico", gol4),
    ]),
    [
      Desempenho("Flamengo", 1, 0, 0),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Flamengo", 3, 1, 5),
      Desempenho("Botafogo", 0, 0, -5),
      Desempenho("Atletico-MG", 3, 1, 1),
      Desempenho("Athletico", 0, 0, -1),
    ],
  )
  check.eq(
    cria_lista_desempenho([
      Resultado("Corinthians", gol8, "Santos", gol3),
      Resultado("Flamengo", gol3, "Botafogo", gol1),
      Resultado("Atletico-MG", gol1, "Corinthians", gol2),
    ]),
    [
      Desempenho("Corinthians", 3, 1, 7),
      Desempenho("Santos", 0, 0, -7),
      Desempenho("Flamengo", 0, 0, -2),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Atletico-MG", 3, 1, 1),
      Desempenho("Corinthians", 0, 0, -1),
    ],
  )
  check.eq(
    cria_lista_desempenho([
      Resultado("Corinthians", gol8, "Santos", gol3),
      Resultado("Flamengo", gol3, "Botafogo", gol1),
      Resultado("Atletico-MG", gol1, "Corinthians", gol2),
      Resultado("Gremio", gol3, "Cuiaba", gol1),
      Resultado("Fluminense", gol3, "Vasco", gol1),
    ]),
    [
      Desempenho("Corinthians", 3, 1, 7),
      Desempenho("Santos", 0, 0, -7),
      Desempenho("Flamengo", 0, 0, -2),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Atletico-MG", 3, 1, 1),
      Desempenho("Corinthians", 0, 0, -1),
      Desempenho("Gremio", 0, 0, -2),
      Desempenho("Cuiaba", 3, 1, 2),
      Desempenho("Fluminense", 0, 0, -2),
      Desempenho("Vasco", 3, 1, 2),
    ],
  )
  check.eq(
    cria_lista_desempenho([
      Resultado("Sao-Paulo", gol4, "Bragantino", gol6),
      Resultado("Fluminense", gol1, "Juventude", gol1),
      Resultado("Criciuma", gol1, "Corinthians", gol5),
      Resultado("Bahia", gol5, "Palmeiras", gol7),
      Resultado("Fortaleza", gol2, "Vitoria", gol7),
    ]),
    [
      Desempenho("Sao-Paulo", 0, 0, -1),
      Desempenho("Bragantino", 3, 1, 1),
      Desempenho("Fluminense", 1, 0, 0),
      Desempenho("Juventude", 1, 0, 0),
      Desempenho("Criciuma", 0, 0, -1),
      Desempenho("Corinthians", 3, 1, 1),
      Desempenho("Bahia", 0, 0, -1),
      Desempenho("Palmeiras", 3, 1, 1),
      Desempenho("Fortaleza", 0, 0, -3),
      Desempenho("Vitoria", 3, 1, 3),
    ],
  )
  check.eq(
    cria_lista_desempenho([
      Resultado("Sao-Paulo", gol4, "Bragantino", gol6),
      Resultado("Fluminense", gol1, "Juventude", gol1),
      Resultado("Criciuma", gol1, "Corinthians", gol5),
      Resultado("Bahia", gol5, "Palmeiras", gol7),
      Resultado("Fortaleza", gol2, "Vitoria", gol7),
      Resultado("Atletico-Go", gol5, "Palmeiras", gol3),
      Resultado("Internacional", gol6, "Botafogo", gol7),
    ]),
    [
      Desempenho("Sao-Paulo", 0, 0, -1),
      Desempenho("Bragantino", 3, 1, 1),
      Desempenho("Fluminense", 1, 0, 0),
      Desempenho("Juventude", 1, 0, 0),
      Desempenho("Criciuma", 0, 0, -1),
      Desempenho("Corinthians", 3, 1, 1),
      Desempenho("Bahia", 0, 0, -1),
      Desempenho("Palmeiras", 3, 1, 1),
      Desempenho("Fortaleza", 0, 0, -3),
      Desempenho("Vitoria", 3, 1, 3),
      Desempenho("Atletico-Go", 3, 1, 3),
      Desempenho("Palmeiras", 0, 0, -3),
      Desempenho("Internacional", 0, 0, -4),
      Desempenho("Botafogo", 3, 1, 4),
    ],
  )
  check.eq(
    cria_lista_desempenho([
      Resultado("Criciuma", gol6, "Corinthians", gol5),
      Resultado("Sao-Paulo", gol1, "Bragantino", gol3),
      Resultado("Internacional", gol6, "Botafogo", gol1),
      Resultado("Fluminense", gol2, "Juventude", gol1),
      Resultado("Atletico-Go", gol5, "Palmeiras", gol7),
      Resultado("Bahia", gol5, "Palmeiras", gol7),
      Resultado("Fortaleza", gol5, "Vitoria", gol6),
    ]),
    [
      Desempenho("Criciuma", 0, 0, -3),
      Desempenho("Corinthians", 3, 1, 3),
      Desempenho("Sao-Paulo", 3, 1, 2),
      Desempenho("Bragantino", 0, 0, -2),
      Desempenho("Internacional", 0, 0, -2),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Fluminense", 0, 0, -1),
      Desempenho("Juventude", 3, 1, 1),
      Desempenho("Atletico-Go", 0, 0, -1),
      Desempenho("Palmeiras", 3, 1, 1),
      Desempenho("Bahia", 0, 0, -1),
      Desempenho("Palmeiras", 3, 1, 1),
      Desempenho("Fortaleza", 3, 1, 3),
      Desempenho("Vitoria", 0, 0, -3),
    ],
  )
}

//Cria uma lista com os *desempenhos* de cada time a partir de um *resultado*.
//Vão existir os casos de vitória do time um, vitória do time dois e empate
//para cada caso, respectivamente: 
// - Time um leva tres *pontos*, 1 *vitoria* e *saldo de gols* positivo, Time dois leva 0 *pontos*, 0 *vitoria*, *saldo de gols* negativo
// - Time dois leva tres *pontos*, 1 *vitoria* e *saldo de gols* positivo, Time um leva 0 *pontos*, 0 *vitoria*, *saldo de gols* negativo
// - Time um e dois levam 1 *ponto*, 0 *vitorias* e 0 de *saldo de gols*.
//A *vitória* para um time acontece se o *numero de gols* desse time é maior o que o *numero de gols* do outro, a diferença entre esses gols
//é o *saldo de gols* para os times, o *empate* acontece se os *números de gols* de ambos os times são iguais. 
pub fn cria_desempenho(result: Resultado) -> List(Desempenho) {
  let gol1 = valor_gol(result.gol_um)
  let gol2 = valor_gol(result.gol_dois)

  case gol1 > gol2 {
    True -> [
      Desempenho(result.time_um, 3, 1, { gol1 - gol2 }),
      Desempenho(result.time_dois, 0, 0, { gol2 - gol1 }),
    ]
    False -> {
      case gol1 < gol2 {
        True -> [
          Desempenho(result.time_um, 0, 0, { gol1 - gol2 }),
          Desempenho(result.time_dois, 3, 1, { gol2 - gol1 }),
        ]
        False -> [
          Desempenho(result.time_um, 1, 0, 0),
          Desempenho(result.time_dois, 1, 0, 0),
        ]
      }
    }
  }
}

pub fn cria_desempenho_examples() {
  let assert Ok(gol1) = new_gol(4)
  let assert Ok(gol2) = new_gol(3)
  let assert Ok(gol3) = new_gol(2)
  let assert Ok(gol4) = new_gol(1)
  let assert Ok(gol5) = new_gol(5)
  let assert Ok(gol6) = new_gol(2)
  let assert Ok(gol7) = new_gol(6)
  let assert Ok(gol8) = new_gol(9)
  check.eq(cria_desempenho(Resultado("Santos", gol1, "Flamengo", gol4)), [
    Desempenho("Santos", 3, 1, 3),
    Desempenho("Flamengo", 0, 0, -3),
  ])
  check.eq(cria_desempenho(Resultado("Flamengo", gol1, "Botafogo", gol1)), [
    Desempenho("Flamengo", 1, 0, 0),
    Desempenho("Botafogo", 1, 0, 0),
  ])
  check.eq(cria_desempenho(Resultado("Flamengo", gol4, "Botafogo", gol3)), [
    Desempenho("Flamengo", 0, 0, -1),
    Desempenho("Botafogo", 3, 1, 1),
  ])
  check.eq(cria_desempenho(Resultado("Gremio", gol4, "Internacional", gol8)), [
    Desempenho("Gremio", 0, 0, -8),
    Desempenho("Internacional", 3, 1, 8),
  ])
  check.eq(cria_desempenho(Resultado("Palmeiras", gol5, "Cuiaba", gol2)), [
    Desempenho("Palmeiras", 3, 1, 2),
    Desempenho("Cuiaba", 0, 0, -2),
  ])
  check.eq(cria_desempenho(Resultado("Flamengo", gol6, "Fluminense", gol4)), [
    Desempenho("Flamengo", 3, 1, 1),
    Desempenho("Fluminense", 0, 0, -1),
  ])
  check.eq(cria_desempenho(Resultado("Coritnhians", gol8, "Sao-Paulo", gol7)), [
    Desempenho("Coritnhians", 3, 1, 3),
    Desempenho("Sao-Paulo", 0, 0, -3),
  ])
}

//Função que mescla os *desempenhos* dentro de uma *lista de desempenhos*, somando os valores necessários
//para cada time repetido dentro da lista. A função analisará o nome dos *times* e para cada time repetido
//dentro da lista, será somado os *pontos*, *vitórias* e saldo de gols*, ao final todos estarão reunidos
//dentro de um único *desempenho*, para cada time, dentro da lista, que conterá todos as pontuações finais do time.
pub fn mescla_desempenho(lst: List(Desempenho)) -> List(Desempenho) {
  case lst {
    [] -> []
    [primeiro, ..resto] -> {
      elimina_repeticao_desempenho([
        primeiro,
        ..mescla_desempenho(mescla_desempenho_unico(resto, primeiro))
      ])
    }
  }
}

pub fn mescla_desempenho_examples() {
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Botafogo", 3, 1, 2),
    ]),
    [
      Desempenho("Flamengo", 3, 1, 0),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 4, 1, 1),
      Desempenho("Botafogo", 6, 2, 6),
    ],
  )

  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
    ]),
    [
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 5, 2, 2),
    ],
  )
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 4, 5, 6),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
    ]),
    [
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 9, 7, 8),
    ],
  )
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Internacional", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 4, 5, 6),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
    ]),
    [
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Internacional", 7, 2, 9),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 9, 7, 8),
    ],
  )
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 4, 5, 6),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
    ]),
    [
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 9, 7, 8),
    ],
  )
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 4, 5, 6),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
    ]),
    [
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 9, 7, 8),
    ],
  )
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Cuiaba", 3, 1, 4),
      Desempenho("Santos", 4, 5, 6),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
      Desempenho("Cuiaba", 4, 1, 5),
    ]),
    [
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Cuiaba", 7, 2, 9),
    ],
  )
  check.eq(
    mescla_desempenho([
      Desempenho("Flamengo", 0, 0, -1),
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Mirassol", 3, 1, 4),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Cuiaba", 3, 1, 4),
      Desempenho("Santos", 4, 5, 6),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 3, 1, 4),
      Desempenho("Santos", 1, 1, 1),
      Desempenho("Cuiaba", 4, 1, 5),
    ]),
    [
      Desempenho("Mirassol", 3, 1, 4),
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Cuiaba", 7, 2, 9),
    ],
  )
}

//Função que, a partir de um desempenho unico, procura o time relativo a esse
//desempenho dentro de uma lista, soma seus valores e retorna a lista nova de valores
//mesclados. A função busca um *Desempenho* com nome de times compatível a outro
//desempenho já passado, dentro de uma lista, soma o desempenho com o compatível
//e retorna a lista somada. Um desempenho é compatível se os os times dentro do desempenho
//são iguais.
pub fn mescla_desempenho_unico(
  lst: List(Desempenho),
  desempenho: Desempenho,
) -> List(Desempenho) {
  case lst {
    [] -> []
    [primeiro, ..resto] -> {
      case primeiro.time == desempenho.time {
        True -> {
          let desem =
            Desempenho(
              primeiro.time,
              primeiro.pontos + desempenho.pontos,
              primeiro.vitorias + desempenho.vitorias,
              primeiro.saldo_gol + desempenho.saldo_gol,
            )
          [desem, ..resto]
          //se achou compatível, soma os valores no compativel da cauda e não continua com o primeiro que está sendo processado
        }
        False -> [primeiro, ..mescla_desempenho_unico(resto, desempenho)]
      }
    }
  }
}

pub fn mescla_desempenho_unico_examples() {
  check.eq(
    mescla_desempenho_unico(
      [
        Desempenho("Santos", 3, 1, 1),
        Desempenho("Flamengo", 3, 1, 1),
        Desempenho("Botafogo", 3, 1, 4),
        Desempenho("Atletico-MG", 1, 0, 0),
        Desempenho("Santos", 1, 0, 0),
        Desempenho("Botafogo", 3, 1, 2),
      ],
      Desempenho("Flamengo", 0, 0, -1),
    ),
    [
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 0),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Botafogo", 3, 1, 2),
    ],
  )
  check.eq(
    mescla_desempenho_unico(
      [
        Desempenho("Santos", 3, 1, 1),
        Desempenho("Flamengo", 3, 1, 1),
        Desempenho("Botafogo", 3, 1, 4),
        Desempenho("Atletico-MG", 1, 0, 0),
        Desempenho("Santos", 1, 0, 0),
        Desempenho("Botafogo", 3, 1, 2),
      ],
      Desempenho("Atletico-MG", 3, 2, 4),
    ),
    [
      Desempenho("Santos", 3, 1, 1),
      Desempenho("Flamengo", 3, 1, 1),
      Desempenho("Botafogo", 3, 1, 4),
      Desempenho("Atletico-MG", 4, 2, 4),
      Desempenho("Santos", 1, 0, 0),
      Desempenho("Botafogo", 3, 1, 2),
    ],
  )
}

//Função para eliminação de repetições dentro de uma lista de desempenhos, deixando apenas os 
//valores finais com os pontos acumulados.
pub fn elimina_repeticao_desempenho(a: List(Desempenho)) -> List(Desempenho) {
  case a {
    [] -> []
    [primeiro, ..resto] -> {
      case compara_desempenho(resto, primeiro) {
        True -> elimina_repeticao_desempenho(resto)
        False -> [primeiro, ..elimina_repeticao_desempenho(resto)]
      }
    }
  }
}

//Verifica se um desempenho existe dentro de uma lista de desempenhos.
pub fn compara_desempenho(lst: List(Desempenho), des: Desempenho) -> Bool {
  case lst {
    [] -> False
    [primeiro, ..resto] -> {
      case des.time == primeiro.time {
        True -> True
        False -> compara_desempenho(resto, des)
      }
    }
  }
}

///Função que baseado em uma lista de Strings dos *Jogos*, cria uma lista de *Resultados*.
///A função recebe uma lista de strings que são os resultados, as strings são divididas
/// por uma função *cria_resultado* onde cada campo é inserido dentro de um *Resultado*, esses tipos são inseridos
/// dentro de uma lista de *Resultados* que é o retorno final da função. Em caso de erro
/// se existir algum jogo duplicado dentro da lista, o erro de time duplicado é retornado.
pub fn cria_resultado(lst: List(String)) -> Result(List(Resultado), Erros) {
  case lst {
    [] -> Ok([])
    [primeiro, ..resto] -> {
      case cria_resultado(resto) {
        Ok(a) ->
          case string_to_resultado(string.split(primeiro, " ")) {
            Ok(b) ->
              case compara_com_resto(a, b) {
                True -> Error(JogoDuplicado)
                False -> Ok([b, ..a])
              }
            Error(c) -> Error(c)
          }
        Error(a) -> Error(a)
      }
    }
  }
}

pub fn cria_resultado_examples() {
  check.eq(
    cria_resultado(["Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1"]),
    Ok([
      Resultado("Sao-Paulo", Gol(1), "Atletico-MG", Gol(2)),
      Resultado("Flamengo", Gol(2), "Palmeiras", Gol(1)),
    ]),
  )

  check.eq(
    cria_resultado(["Sao-Paulo -1 Atletico-MG 2", "Flamengo 2 Palmeiras 1"]),
    Error(PlacarInvalido),
  )
  check.eq(
    cria_resultado(["Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Flamengo 1"]),
    Error(TimeDuplicado),
  )
  check.eq(
    cria_resultado(["Flamengo 2 Palmeiras 1", "Flamengo 2 Palmeiras 1"]),
    Error(JogoDuplicado),
  )
  check.eq(cria_resultado(["2 1", " 2 1"]), Error(CamposIncompletos))
  check.eq(cria_resultado(["", ""]), Error(CamposIncompletos))

  check.eq(
    cria_resultado(["Sao-Paulo 6 Atletico-MG 2", "Flamengo 2 Palmeiras 9"]),
    Ok([
      Resultado("Sao-Paulo", Gol(6), "Atletico-MG", Gol(2)),
      Resultado("Flamengo", Gol(2), "Palmeiras", Gol(9)),
    ]),
  )
  check.eq(
    cria_resultado(["Sao-Paulo  Atletico-MG 2", "Flamengo 2 Palmeiras 9"]),
    Error(PlacarInvalido),
  )
  check.eq(
    cria_resultado(["", "Flamengo 2 Palmeiras 9"]),
    Error(CamposIncompletos),
  )
}

//Função que compara um elemento de uma lista de resultados com os outros elementos da lista
//para identificar erros de repetição, caso exista uma repetição retorna True, caso não retorna False.
pub fn compara_com_resto(lst: List(Resultado), res: Resultado) -> Bool {
  case lst {
    [] -> False
    [primeiro, ..resto] -> {
      case
        res.time_um == primeiro.time_um && res.time_dois == primeiro.time_dois
      {
        True -> True
        False -> compara_com_resto(resto, res)
      }
    }
  }
}

pub fn compara_com_resto_examples() {
  let assert Ok(gol1) = new_gol(4)
  let assert Ok(gol2) = new_gol(3)
  let assert Ok(gol3) = new_gol(5)
  let assert Ok(gol4) = new_gol(7)

  check.eq(
    compara_com_resto(
      [
        Resultado("Flamengo", gol2, "Santos", gol1),
        Resultado("Flamengo", gol3, "Botafogo", gol4),
      ],
      Resultado("Flamengo", gol2, "Santos", gol1),
    ),
    True,
  )
  check.eq(
    compara_com_resto(
      [
        Resultado("Flamengo", gol2, "Santos", gol1),
        Resultado("Flamengo", gol3, "Botafogo", gol4),
      ],
      Resultado("Flamengo", gol2, "Gremio", gol4),
    ),
    False,
  )
  check.eq(
    compara_com_resto(
      [
        Resultado("Flamengo", gol2, "Santos", gol1),
        Resultado("Flamengo", gol3, "Botafogo", gol4),
      ],
      Resultado("Flamengo", gol2, "Botafogo", gol4),
    ),
    True,
  )
  check.eq(
    compara_com_resto(
      [
        Resultado("Flamengo", gol2, "Santos", gol1),
        Resultado("Flamengo", gol3, "Botafogo", gol4),
      ],
      Resultado("Santos", gol1, "Botafogo", gol4),
    ),
    False,
  )
  check.eq(
    compara_com_resto(
      [
        Resultado("Flamengo", gol1, "Santos", gol1),
        Resultado("Santos", gol3, "Botafogo", gol4),
      ],
      Resultado("Flamengo", gol1, "Santos", gol2),
    ),
    True,
  )
}

//Função que recebe uma *lista de string* com o resultado de um jogo, ao final ele é
//transformado para um *Resultado* com seus campos corretos e sem erros.
//A entrada é uma lista de String contendo primeiro time, gol, segundo time, gol.
//Esses valores são trasnformados em valores usáveis e são testados para cada tipo de erro:
/// - Para erro no valor gol: PlacarInvalido
/// - Para times duplicados se retorna: TimeDuplicado
/// - Para campos faltando: Campos Incompletos
/// - Caso a quantidade de campos exceda o limite de 4: MaxCamposExcedido
/// - Caso a quantidade de campos seja menor que o limite: Campos Incompletos
/// Ao final da função seu retorno é um erro, ou um Ok com o Tipo resultado como conteúdo.
pub fn string_to_resultado(str: List(String)) -> Result(Resultado, Erros) {
  case str {
    [] -> Error(CamposIncompletos)
    [primeiro, segundo, terceiro, quarto] -> {
      case int.parse(segundo), int.parse(quarto) {
        Ok(a), Ok(d) ->
          case
            { primeiro != "" && terceiro != "" },
            new_gol(a),
            new_gol(d),
            { primeiro == terceiro }
          {
            True, Ok(a), Ok(d), False -> Ok(Resultado(primeiro, a, terceiro, d))
            _, Error(e), Error(_), _ -> Error(e)
            _, _, _, True -> Error(TimeDuplicado)
            False, _, _, _ -> Error(CamposIncompletos)
            _, _, _, _ -> Error(PlacarInvalido)
          }
        _, _ -> Error(PlacarInvalido)
      }
    }

    [_, _, _, _, _, ..] -> Error(MaxCamposExcedidos)
    [_, ..] -> Error(CamposIncompletos)
  }
}

pub fn string_to_resultado_examples() {
  check.eq(
    string_to_resultado(["Corinthia", "1", "Cortina", "0"]),
    Ok(Resultado("Corinthia", Gol(1), "Cortina", Gol(0))),
  )
  check.eq(
    string_to_resultado(["Cortina", "1", "Cortina", "0"]),
    Error(TimeDuplicado),
  )
  check.eq(
    string_to_resultado(["Corinthia", "1", "Cortina"]),
    Error(CamposIncompletos),
  )
  check.eq(
    string_to_resultado(["Corinthia", "", "Cortina", "0"]),
    Error(PlacarInvalido),
  )
  check.eq(
    string_to_resultado(["Corinthia", "", "Cortina", "0", "Matheus"]),
    Error(MaxCamposExcedidos),
  )
  check.eq(
    string_to_resultado(["Flamengo", "0", "Fluminense", "0"]),
    Ok(Resultado("Flamengo", Gol(0), "Fluminense", Gol(0))),
  )
  check.eq(
    string_to_resultado(["Flamengo", "0", "Fluminense", "0", ""]),
    Error(MaxCamposExcedidos),
  )
  check.eq(
    string_to_resultado(["Divinity", "8", "Baldurs", "45"]),
    Ok(Resultado("Divinity", Gol(8), "Baldurs", Gol(45))),
  )
  check.eq(
    string_to_resultado(["Divinity", "", "Baldurs", "45"]),
    Error(PlacarInvalido),
  )
}

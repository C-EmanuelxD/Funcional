import gleam/int
import gleam/list.{Continue, Stop}
import gleam/order
import gleam/result
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
  use lst <- result.try(cria_resultado(lst_jogos))
  Ok(
    cria_lista_desempenho(lst)
    |> mescla_desempenho
    |> ordena_lista_desempenhos
    |> desempenho_to_string,
  )
}

pub fn main_examples() {
  check.eq(main_brasileirao([]), Error(ListaVazia))
  check.eq(
    main_brasileirao([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Ok([
      "Flamengo     6  2    2", "Atletico-MG  3  1    0",
      "Palmeiras    1  0   -1", "Sao-Paulo    1  0   -1",
    ]),
  )
  check.eq(
    main_brasileirao(["Sao-Paulo 2 Atletico-MG 2"]),
    Ok(["Atletico-MG  1  0    0", "Sao-Paulo    1  0    0"]),
  )
  check.eq(
    main_brasileirao(["Santos 1 Botafogo 0", "Botafogo 0 Santos 1"]),
    Ok(["Santos    6  2    2", "Botafogo  0  0   -2"]),
  )

  check.eq(
    main_brasileirao([
      "Botafogo 2 SaoPaulo 1", "Palmeiras 0 Fluminense 1",
      "Bragantino 5 Criciuma 1", "Atletico-MG 1 Athletico-PR 0",
      "Flamengo 2 Corinthians 0", "Fortaleza 1 Botafogo 1",
      "Atlético-GO 0 Cruzeiro 1", "Bahia 1 Bragantino 0", "Vasco 2 Vitória 1",
      "Fluminense 2 Atletico-MG 2", "Juventude 1 Athletico-PR 1",
      "Cuiaba 0 Palmeiras 2", "Vasco 0 Criciuma 4",
      "Internacional 1 Atletico-GO 1", "Bahia 1 Gremio 0",
      "Palmeiras 0 Athletico-PR 2",
    ]),
    Ok([
      "Bahia          6  2    2", "Athletico-PR   4  1    1",
      "Atletico-MG    4  1    1", "Botafogo       4  1    1",
      "Fluminense     4  1    1", "Bragantino     3  1    3",
      "Flamengo       3  1    2", "Cruzeiro       3  1    1",
      "Criciuma       3  1    0", "Palmeiras      3  1   -1",
      "Vasco          3  1   -3", "Atletico-GO    1  0    0",
      "Fortaleza      1  0    0", "Internacional  1  0    0",
      "Juventude      1  0    0", "Atlético-GO    0  0   -1",
      "Gremio         0  0   -1", "SaoPaulo       0  0   -1",
      "Vitória        0  0   -1", "Corinthians    0  0   -2",
      "Cuiaba         0  0   -2",
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
      "Palmeiras      9  3    6", "Corinthians    6  2    4",
      "Internacional  6  2    4", "Bahia          6  2    3",
      "Vasco          6  2    3", "Fortaleza      6  2    1",
      "Flamengo       6  2   -1", "Atletico       3  1    1",
      "Bragantino     3  1    1", "Cruzeiro       3  1    0",
      "Sao-Paulo      3  1   -1", "Botafogo       3  1   -8",
      "Athletico      0  0   -1", "Criciuma       0  0   -1",
      "Cuiaba         0  0   -1", "Vitoria        0  0   -1",
      "Atletico-Go    0  0   -2", "Fluminense     0  0   -2",
      "Juventude      0  0   -2", "Gremio         0  0   -3",
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
      "Palmeiras      9  3    6", "Corinthians    6  2    4",
      "Internacional  6  2    4", "Bahia          6  2    3",
      "Vasco          6  2    3", "Fortaleza      6  2    1",
      "Flamengo       6  2   -1", "Atletico       3  1    1",
      "Bragantino     3  1    1", "Cruzeiro       3  1    0",
      "Sao-Paulo      3  1   -1", "Botafogo       3  1   -8",
      "Athletico      0  0   -1", "Criciuma       0  0   -1",
      "Cuiaba         0  0   -1", "Vitoria        0  0   -1",
      "Atletico-Go    0  0   -2", "Fluminense     0  0   -2",
      "Juventude      0  0   -2", "Gremio         0  0   -3",
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
      "Botafogo 1 Flamengo 3 vasco", "Palmeiras 4 Botafogo 0",
      "Flamengo 2 Palmeiras 4", "Fortaleza 2 Palmeiras 1",
      "Internacional 2 Botafogo 0", "Sao-Paulo 0 Internacional 3",
      "Corinthians 4 Fortaleza 3", "Bahia 3 Flamengo 2",
      "Cruzeiro 1 Palmeiras 0", "Vasco 2 Botafogo 0", "Vitoria 1 Vasco 2",
      "Atletico 3 Cruzeiro 2", "Fluminense 0 Bahia 2", "Gremio 0 Corinthians 3",
      "Juventude 1 Sao-Paulo 3", "Bragantino 2 Internacional 1",
      "Athletico 2 Fortaleza 3", "Criciuma 2 Flamengo 3",
      "Atletico-Go 2 Palmeiras 4", "Cuiaba 2 Botafogo 3",
    ]),
    Error(MaxCamposExcedidos),
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
    Error(PlacarInvalido),
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
    Error(PlacarInvalido),
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
/// tabelado
fn desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  let nomes = time_desempenho_to_string(desempenho)
  let max_nomes = tamanho_maximo(nomes)
  let pontoss = pontos_desempenho_to_string(desempenho)
  let max_pontos = tamanho_maximo(pontoss)
  let vitoriass = vitorias_desempenho_to_string(desempenho)
  let max_vitorias = tamanho_maximo(vitoriass)
  list.map(desempenho, fn(d: Desempenho) {
    let espacos = string.repeat(" ", max_nomes - string.length(d.time))
    let varn = case d.saldo_gol < 0 {
      True -> "  "
      False -> "   "
    }
    let con =
      string.repeat(" ", max_pontos - string.length(int.to_string(d.pontos)))
    let diss =
      string.repeat(
        " ",
        max_vitorias - string.length(int.to_string(d.vitorias)),
      )
    string.concat([
      d.time,
      espacos,
      "  ",
      int.to_string(d.pontos),
      con,
      "  ",
      int.to_string(d.vitorias),
      diss,
      " ",
      varn,
      int.to_string(d.saldo_gol),
    ])
  })
}

pub fn desempenho_to_string_examples() {
  check.eq(
    desempenho_to_string([
      Desempenho("Abruzeiro", 13_457, 7, 11),
      Desempenho("Athletico", 17, 7, -1),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ]),
    [
      "Abruzeiro      13457  7    11", "Athletico      17     7   -1",
      "Santos         17     5    10", "Internacional  14     1    22",
      "Vitória        14     1    2", "Flamengo       0      1    0",
      "Botafogo       0      0    0",
    ],
  )

  check.eq(
    desempenho_to_string([
      Desempenho("Abruzeiro", 13_457, 7, 11),
      Desempenho("Athletico", 17, 7, 465_814),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ]),
    [
      "Abruzeiro      13457  7    11", "Athletico      17     7    465814",
      "Santos         17     5    10", "Internacional  14     1    22",
      "Vitória        14     1    2", "Flamengo       0      1    0",
      "Botafogo       0      0    0",
    ],
  )
}

/// Devolve o tamanho máximo entre todas as strings de *lst*.
pub fn tamanho_maximo(lst: List(String)) -> Int {
  list.fold(list.map(lst, string.length), 0, int.max)
}

pub fn tamanho_maximo_examples() {
  check.eq(
    tamanho_maximo([
      "Abruzeiro", "Athletico", "Santos", "Internacional", "Vitória",
      "Flamengo", "Botafogo",
    ]),
    13,
  )
}

/// Devolve uma lista com os times convertendo *time* para *string*
pub fn time_desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  list.map(desempenho, fn(d: Desempenho) { d.time })
}

/// Devolve uma lista com os pontos convertendo *pontos* para *string*
pub fn pontos_desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  list.map(desempenho, fn(d: Desempenho) { int.to_string(d.pontos) })
}

/// Devolve uma lista com as vitorias convertendo *vitorias* para *string*
pub fn vitorias_desempenho_to_string(
  desempenho: List(Desempenho),
) -> List(String) {
  list.map(desempenho, fn(d: Desempenho) { int.to_string(d.vitorias) })
}

/// Devolve uma lista com os saldos de gols convertendo *saldo_gols* para *string*
pub fn gols_desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  list.map(desempenho, fn(d: Desempenho) { int.to_string(d.saldo_gol) })
}

pub fn time_desempenho_to_string_examples() {
  check.eq(
    time_desempenho_to_string([
      Desempenho("Abruzeiro", 17, 7, 11),
      Desempenho("Athletico", 17, 7, 11),
      Desempenho("Santos", 17, 5, 10),
      Desempenho("Internacional", 14, 1, 22),
      Desempenho("Vitória", 14, 1, 2),
      Desempenho("Flamengo", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ]),
    [
      "Abruzeiro", "Athletico", "Santos", "Internacional", "Vitória",
      "Flamengo", "Botafogo",
    ],
  )

  check.eq(
    time_desempenho_to_string([
      Desempenho("Manchester City", 17, 7, 11),
      Desempenho("G2Esports", 17, 7, 11),
      Desempenho("Flamengo", 17, 5, 10),
      Desempenho("G3X", 14, 1, 22),
      Desempenho("Porto-Belo", 14, 1, 2),
      Desempenho("Jardim-Alegre", 0, 1, 0),
      Desempenho("Botafogo", 0, 0, 0),
    ]),
    [
      "Manchester City", "G2Esports", "Flamengo", "G3X", "Porto-Belo",
      "Jardim-Alegre", "Botafogo",
    ],
  )
}

/// ordena um *list* de *desempenho* usando a funcao ordena
pub fn ordena_lista_desempenhos(lst: List(Desempenho)) -> List(Desempenho) {
  list.fold(lst, [], ordena)
}

/// insere um elemento em uma lista seguindo a ordem da funcao inserir_lista
/// entrada e *lst* de desempehno e um desempenho a ser ordenado
/// a saida e uma nova lista de desempenho com o desempenho inserido
/// se a lista estiver vazia a lista apenas com o novo desempenho
pub fn ordena(lst: List(Desempenho), n: Desempenho) -> List(Desempenho) {
  list.fold_until(lst, [], fn(acc, e) {
    case inserir_lista(n, e) == n {
      True ->
        list.Stop(
          list.concat([acc, [n], [e], list.drop(lst, list.length(acc) + 1)]),
        )
      False -> list.Continue(list.append(acc, [e]))
    }
  })
  |> fn(result) {
    case result {
      [] -> [n]
      acc ->
        case list.length(acc) == list.length(lst) {
          True -> list.append(acc, [n])
          False -> acc
        }
    }
  }
}

/// compara desemepenho entre dois times pela ordem: pontos, vitorias, saldo de gols e 
/// como criterio desempate utiliza a ordem alfaetica
pub fn inserir_lista(desem1: Desempenho, desem2: Desempenho) -> Desempenho {
  case
    { desem1.pontos > desem2.pontos },
    { desem1.pontos == desem2.pontos },
    { desem1.vitorias > desem2.vitorias },
    { desem1.vitorias == desem2.vitorias },
    { desem1.saldo_gol > desem2.saldo_gol },
    { desem1.saldo_gol == desem2.saldo_gol },
    { string.compare(desem1.time, desem2.time) }
  {
    True, _, _, _, _, _, _ -> desem1
    False, False, _, _, _, _, _ -> desem2
    False, True, True, _, _, _, _ -> desem1
    False, True, False, False, _, _, _ -> desem2
    False, True, False, True, True, _, _ -> desem1
    False, True, False, True, False, False, _ -> desem2
    False, True, False, True, False, True, order.Lt -> desem1
    False, True, False, True, False, True, _ -> desem2
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
      Desempenho("Flamengo", 5, 0, 1),
      Desempenho("City", 8495, 9, 13),
      Desempenho("Real Madrid", 8495, 9, 11),
      Desempenho("Ibis", 0, 0, 1),
      Desempenho("Vitoria", 0, 0, 2),
      Desempenho("Snatos", 7, 0, 4),
      Desempenho("Botafofo", 13, 0, 7),
    ]),
    [
      Desempenho("City", 8495, 9, 13),
      Desempenho("Real Madrid", 8495, 9, 11),
      Desempenho("Botafofo", 13, 0, 7),
      Desempenho("Snatos", 7, 0, 4),
      Desempenho("Flamengo", 5, 0, 1),
      Desempenho("Vitoria", 0, 0, 2),
      Desempenho("Ibis", 0, 0, 1),
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

/// combina desemepnho de um mesmo time em  um unico desempenho
/// a entrada eh um *list* de *desemepnho* e devolve uma lista com cada 
/// time aparecendo somente uma vez, a mescla do desempenho e feito pela funcao mesclar_times
pub fn mescla_desempenho(lst: List(Desempenho)) -> List(Desempenho) {
  list.fold(lst, [], fn(acc: List(Desempenho), atual: Desempenho) {
    case list.find(acc, fn(d: Desempenho) { d.time == atual.time }) {
      Ok(time_existente) -> {
        let nova_lista =
          list.filter(acc, fn(d: Desempenho) { d.time != atual.time })
        [mesclar_times(time_existente, atual), ..nova_lista]
      }
      Error(_) -> [atual, ..acc]
    }
  })
}

/// soma desempenho entre dois desempenhos de um mesmo time
pub fn mesclar_times(existente: Desempenho, novo: Desempenho) -> Desempenho {
  Desempenho(
    existente.time,
    existente.pontos + novo.pontos,
    existente.vitorias + novo.vitorias,
    existente.saldo_gol + novo.saldo_gol,
  )
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
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Santos", 4, 1, 1),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Flamengo", 3, 1, 0),
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
      Desempenho("Santos", 5, 2, 2),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Atletico-MG", 1, 0, 0),
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
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Atletico-MG", 1, 0, 0),
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
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Internacional", 7, 2, 9),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Atletico-MG", 1, 0, 0),
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
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
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
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
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
      Desempenho("Cuiaba", 7, 2, 9),
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Botafogo", 6, 2, 6),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
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
      Desempenho("Cuiaba", 7, 2, 9),
      Desempenho("Santos", 9, 7, 8),
      Desempenho("Flamengo", 6, 2, 4),
      Desempenho("Internacional", 4, 1, 5),
      Desempenho("Botafogo", 3, 1, 2),
      Desempenho("Atletico-MG", 1, 0, 0),
      Desempenho("Gremio", 3, 1, 4),
      Desempenho("Mirassol", 3, 1, 4),
    ],
  )
}

pub fn cria_lista_desempenho(lst: List(Resultado)) -> List(Desempenho) {
  list.flat_map(lst, cria_desempenho)
}

/// flat map pq tava vindo uma lista de listas e isso resolvia '-'
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
      Resultado("Vasco", gol8, "CRB", gol7),
      Resultado("Ceara", gol3, "Ribeirao-Preto", gol5),
      Resultado("Cruzeiro", gol4, "Goias", gol8),
    ]),
    [
      Desempenho("Vasco", 3, 1, 3),
      Desempenho("CRB", 0, 0, -3),
      Desempenho("Ceara", 0, 0, -3),
      Desempenho("Ribeirao-Preto", 3, 1, 3),
      Desempenho("Cruzeiro", 0, 0, -8),
      Desempenho("Goias", 3, 1, 8),
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

//Cria uma lista de *resultados* baseado nas strings *jogos* de entrada, ao mesmo tempo
//detecta possíveis erros dentro dentro dos jogos. Cada campo de *times* e *gols* serão
//inseridos dentro dos campos respectivos do tipo *resultado* e então serão colocados dentro
//da lista de *resultados*, com seus próprios resultados por jogo.
pub fn cria_resultado(lst: List(String)) -> Result(List(Resultado), Erros) {
  use lista <- result.try({
    list.map(lst, string_to_resultado)
    |> result.all
  })

  case verifica_repeticao(lista), lst == [] {
    _, True -> Error(ListaVazia)
    True, False -> Error(JogoDuplicado)
    False, False -> Ok(lista)
  }
}

pub fn cria_resultado_examples() {
  check.eq(cria_resultado([]), Error(ListaVazia))
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

//Dada uma lista de *resultados*, verifica se existem repetições entre os *times*,
//ou seja, se para todos os *resultados* dentro da lista, existem dois *jogos* onde
//*time1* = *time2*, assim que isso acontecer ele retorna True, caso contrário retorna False.
pub fn verifica_repeticao(lst: List(Resultado)) -> Bool {
  list.fold_until(lst, False, fn(_, elem: Resultado) {
    case
      list.count(lst, fn(elem_under: Resultado) {
        elem.time_um == elem_under.time_um
        && elem.time_dois == elem_under.time_dois
      })
      > 1
    {
      True -> Stop(True)
      False -> Continue(False)
    }
  })
}

pub fn verifica_repeticao_examples() {
  check.eq(
    verifica_repeticao([
      Resultado("Flamengo", Gol(4), "Vasco", Gol(1)),
      Resultado("Vasco", Gol(4), "Flamengo", Gol(1)),
    ]),
    False,
  )
  check.eq(
    verifica_repeticao([
      Resultado("Flamengo", Gol(4), "Vasco", Gol(1)),
      Resultado("Flamengo", Gol(4), "Vasco", Gol(1)),
    ]),
    True,
  )

  check.eq(
    verifica_repeticao([
      Resultado("Flamengo", Gol(4), "Vasco", Gol(1)),
      Resultado("Vasco", Gol(4), "Flamengo", Gol(1)),
      Resultado("Santos", Gol(5), "Corinthians", Gol(2)),
      Resultado("Goias", Gol(7), "Arruda-Do-Norte", Gol(10)),
      Resultado("Arruda-Do-Norte", Gol(7), "Goias", Gol(10)),
    ]),
    False,
  )

  check.eq(
    verifica_repeticao([
      Resultado("Flamengo", Gol(4), "Vasco", Gol(1)),
      Resultado("Vasco", Gol(4), "Flamengo", Gol(1)),
      Resultado("Santos", Gol(5), "Corinthians", Gol(2)),
      Resultado("Goias", Gol(7), "Arruda-Do-Norte", Gol(10)),
      Resultado("Flamengo", Gol(7), "Vasco", Gol(10)),
    ]),
    True,
  )
}

//FFunção que dada uma String que representa um *jogo*, pega essa string e 
//transforma em um tipo *resultado*, adicionando os gols em formato aceitável
//e verificando possíveis erros de formatação ou de escrita dentro da string.
//ao final ela deve retornar uma string única que representará um *resultado*.
pub fn string_to_resultado(str_pura: String) -> Result(Resultado, Erros) {
  let str = string.split(str_pura, " ")
  case str {
    [] -> Error(CamposIncompletos)
    [primeiro, segundo, terceiro, quarto] -> {
      result.try(verifica_times(primeiro, terceiro), fn(_) {
        use a <- result.try(
          result.map_error(int.parse(segundo), fn(_) { PlacarInvalido }),
        )
        use d <- result.try(
          result.map_error(int.parse(quarto), fn(_) { PlacarInvalido }),
        )

        use gol1 <- result.try(new_gol(a))
        use gol2 <- result.try(new_gol(d))

        Ok(Resultado(primeiro, gol1, terceiro, gol2))
      })
    }
    [_, _, _, _, _, ..] -> Error(MaxCamposExcedidos)
    [_, ..] -> Error(CamposIncompletos)
  }
}

pub fn string_to_resultado_examples() {
  check.eq(string_to_resultado(""), Error(CamposIncompletos))
  check.eq(string_to_resultado("santos "), Error(CamposIncompletos))
  check.eq(
    string_to_resultado("santos 1 corinthians 0 x"),
    Error(MaxCamposExcedidos),
  )
  check.eq(string_to_resultado("santos x corinthians 0"), Error(PlacarInvalido))
  check.eq(string_to_resultado("santos 0 corinthians x"), Error(PlacarInvalido))
  check.eq(
    string_to_resultado("santos -1 corinthians 0"),
    Error(PlacarInvalido),
  )
  check.eq(
    string_to_resultado("Santos 1 Corinthians 0"),
    Ok(Resultado("Santos", Gol(1), "Corinthians", Gol(0))),
  )
  check.eq(
    string_to_resultado("Atletico 7 Athletico 2"),
    Ok(Resultado("Atletico", Gol(7), "Athletico", Gol(2))),
  )
  check.eq(
    string_to_resultado("Juventude 0 Mirassol 0"),
    Ok(Resultado("Juventude", Gol(0), "Mirassol", Gol(0))),
  )
  check.eq(string_to_resultado("santos 1 santos 0"), Error(TimeDuplicado))
}

//Função que verifica se os times estão corretos (sem repetição e não vazios)
pub fn verifica_times(time1: String, time2: String) -> Result(Bool, Erros) {
  case time1 != "" && time2 != "" {
    True ->
      case time1 == time2 {
        True -> Error(TimeDuplicado)
        False -> Ok(True)
      }
    False -> Error(CamposIncompletos)
  }
}

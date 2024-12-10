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

//Tipo de status que pode ocorrer dentro de um jogo.
//Como vitoria não se conta pontos e em geral nada acontece, não se é necessário representar
//VitoriaUm é para vitória do time 1, VitóriaDois é para vitória do time 2 e empate é para nenhum ganha mas nenhum perde
pub type Status {
  VitoriaUm
  VitoriaDois
  Empate
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
    string_to_resultado(["Corinthia", "", "Cortina", "0"]),
    Error(PlacarInvalido),
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
}

/// Função que convete uma *lista de desemepenhos* ordenada em uma lista de *strings* 
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
}

pub fn inserir_lista(
  lst: List(Desempenho),
  desem: Desempenho,
) -> List(Desempenho) {
  case lst {
    [] -> [desem]
    [primeiro, ..resto] -> {
      case desem.pontos > primeiro.pontos {
        True -> [desem, primeiro, ..resto]
        False -> {
          case desem.pontos == primeiro.pontos {
            True ->
              case desem.vitorias > primeiro.vitorias {
                True -> [desem, primeiro, ..resto]
                False ->
                  case desem.saldo_gol > primeiro.saldo_gol {
                    True -> [desem, primeiro, ..resto]
                    False ->
                      case desem.saldo_gol == primeiro.saldo_gol {
                        True ->
                          case string.compare(desem.time, primeiro.time) {
                            order.Eq -> [
                              primeiro,
                              ..inserir_lista(resto, desem)
                            ]
                            order.Lt -> [desem, primeiro, ..resto]
                            order.Gt -> [
                              primeiro,
                              ..inserir_lista(resto, desem)
                            ]
                          }
                        False -> [primeiro, ..inserir_lista(resto, desem)]
                      }
                  }
              }
            False -> [primeiro, ..inserir_lista(resto, desem)]
          }
        }
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
        //Cuidado !!
      }
    }
  }
}

pub fn cria_lista_desempenho_examples() {
  let assert Ok(gol1) = new_gol(4)
  let assert Ok(gol2) = new_gol(3)
  let assert Ok(gol3) = new_gol(2)
  let assert Ok(gol4) = new_gol(1)

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
//valores finais acumulados de pontos
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

//Verifica se um elemento ainda existe dentro de uma certa lista
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
/// e cada campo é inserido dentro de um *Resultado*, esses tipos são inseridos
/// dentro de uma lista de *Resultados* que é o retorno final da função.
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
}

/// REVISA ISSO******************************************************************************************************************************************************************************
///Função auxiliar à cria_resultado que retorna a lista de String dada em forma de Resultados.
///A função recebe uma Lista de strings que foram divididas anteriormente e as coloca dentro
/// de um tipo *Resultado*, fazendo todas as verificações de erros que tangem à resultado único.
/// A saída da função é um Result, em caso de algum erro listado, retorna Error, caso tudo
/// esteja correto retorna o Ok(Result()) com o resultado do jogo.
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
}

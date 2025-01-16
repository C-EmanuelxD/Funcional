import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/option
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

/// Função que convete uma *lista de desempenhos* ordenada em uma lista de *strings* 
/// converte cada elemento de *desemepenho* em string e depois concatena tudo em uma só string e retorna
/// tabelado
fn desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  let nomes = time_desempenho_to_string(desempenho)
  let max = tamanho_maximo(nomes)

  list.map(desempenho, fn(d: Desempenho) {
    let espacos = string.repeat(" ", max - string.length(d.time))
    let varn = case d.saldo_gol < 0 {
      True -> "  "
      False -> "   "
    }
    string.concat([
      d.time,
      espacos,
      "  ",
      int.to_string(d.pontos),
      "  ",
      int.to_string(d.vitorias),
      varn,
      int.to_string(d.saldo_gol),
    ])
  })
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
      "Abruzeiro      17  7   11", "Athletico      17  7   11",
      "Santos         17  5   10", "Internacional  14  1   22",
      "Vitória        14  1   2", "Flamengo       0  1   0",
      "Botafogo       0  0   0",
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

/// Devolve uma lista com os times convertendo *desempenho* para *string*
pub fn time_desempenho_to_string(desempenho: List(Desempenho)) -> List(String) {
  list.map(desempenho, fn(d: Desempenho) { d.time })
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
}

pub fn ordena_lista_desempenhos(
  lst: List(Desempenho),
) -> List(Desempenho) {
  list.fold(lst, [], ordena)
}

pub fn ordena(lst: List(Desempenho), n: Desempenho) -> List(Desempenho) {
  list.fold_until(lst, [], fn(acc, e) {
    case inserir_lista(n, e) == n {
      True -> list.Stop(list.concat([acc, [n], [e], list.drop(lst, list.length(acc) + 1)]))
      False -> list.Continue(list.append(acc, [e]))
    }
  })
  |> fn(result) {
    case result {
      [] -> [n]  
      acc -> case list.length(acc) == list.length(lst) {
        True -> list.append(acc, [n])  
        False -> acc  
      }
    }
  }
}

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
      Desempenho(time: "City", pontos: 8495, vitorias: 9, saldo_gol: 13),
      Desempenho(time: "Real Madrid", pontos: 8495, vitorias: 9, saldo_gol: 11),
      Desempenho(time: "Botafofo", pontos: 13, vitorias: 0, saldo_gol: 7),
      Desempenho(time: "Snatos", pontos: 7, vitorias: 0, saldo_gol: 4),
      Desempenho(time: "Flamengo", pontos: 5, vitorias: 0, saldo_gol: 1),
      Desempenho(time: "Vitoria", pontos: 0, vitorias: 0, saldo_gol: 2),
      Desempenho(time: "Ibis", pontos: 0, vitorias: 0, saldo_gol: 1),
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

pub fn mesclar_times(existente: Desempenho, novo: Desempenho) -> Desempenho {
  Desempenho(
    time: existente.time,
    pontos: existente.pontos + novo.pontos,
    vitorias: existente.vitorias + novo.vitorias,
    saldo_gol: existente.saldo_gol + novo.saldo_gol,
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
      Desempenho(time: "Botafogo", pontos: 6, vitorias: 2, saldo_gol: 6),
      Desempenho(time: "Santos", pontos: 4, vitorias: 1, saldo_gol: 1),
      Desempenho(time: "Atletico-MG", pontos: 1, vitorias: 0, saldo_gol: 0),
      Desempenho(time: "Flamengo", pontos: 3, vitorias: 1, saldo_gol: 0),
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
      Desempenho(time: "Santos", pontos: 5, vitorias: 2, saldo_gol: 2),
      Desempenho(time: "Flamengo", pontos: 6, vitorias: 2, saldo_gol: 4),
      Desempenho(time: "Botafogo", pontos: 6, vitorias: 2, saldo_gol: 6),
      Desempenho(time: "Atletico-MG", pontos: 1, vitorias: 0, saldo_gol: 0),
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

pub fn cria_resultado(lst: List(String)) -> Result(List(Resultado), Erros) {
  //É BOM FAZER MAIS TESTES
  use lista <- result.try({
    list.map(lst, string_to_resultado)
    |> result.all
  })

  case verifica_repeticao(lista) {
    True -> Error(JogoDuplicado)
    False -> Ok(lista)
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

// NECESSITA TESTES
pub fn verifica_repeticao(lst: List(Resultado)) -> Bool {
  //Falecido compara_com_resto
  list.fold_until(lst, False, fn(acc, elem: Resultado) {
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

//FUNÇÃO PARA COLOCAR DESCRIÇÃO DEPOIS E REFAZER EXEMPLOS
pub fn string_to_resultado(str_pura: String) -> Result(Resultado, Erros) {
  let str = string.split(str_pura, " ")
  //REFAZER EXEMPLOS POR CAUSA DISSO
  case str {
    [] -> Error(CamposIncompletos)
    [primeiro, segundo, terceiro, quarto] -> {
      result.try(verifica_times(primeiro, terceiro), fn(_) {
        use a <- result.try(case int.parse(segundo) {
          Ok(x) -> Ok(x)
          Error(Nil) -> Error(PlacarInvalido)
        })
        use d <- result.try(case int.parse(quarto) {
          Ok(x) -> Ok(x)
          Error(Nil) -> Error(PlacarInvalido)
        })

        use gol1 <- result.try(new_gol(a))
        use gol2 <- result.try(new_gol(d))

        Ok(Resultado(primeiro, gol1, terceiro, gol2))
      })
    }
    [_, _, _, _, _, ..] -> Error(MaxCamposExcedidos)
    [_, ..] -> Error(CamposIncompletos)
  }
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

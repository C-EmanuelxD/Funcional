import gleam/int
import gleam/order
import gleam/result
import gleam/string
import gleam/list.{Continue, Stop}
import sgleam/check
import gleam/io

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






pub fn cria_resultado(lst: List(String)) -> Result(List(Resultado), Erros){ //É BOM FAZER MAIS TESTES
  use lista <- result.try(
    {list.map(lst, string_to_resultado)
    |> result.all})

  case verifica_repeticao(lista){
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
pub fn verifica_repeticao(lst: List(Resultado)) -> Bool { //Falecido compara_com_resto
  list.fold_until(lst, False, fn(acc, elem: Resultado){
    case list.count(lst, fn(elem_under: Resultado){elem.time_um == elem_under.time_um && elem.time_dois == elem_under.time_dois}) > 1{
      True -> Stop(True)
      False -> Continue(False)
    }
  })
}




//FUNÇÃO PARA COLOCAR DESCRIÇÃO DEPOIS E REFAZER EXEMPLOS
pub fn string_to_resultado(str_pura: String) -> Result(Resultado, Erros) {
  let str = string.split(str_pura, " ") //REFAZER EXEMPLOS POR CAUSA DISSO
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



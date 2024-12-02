import gleam/int
import gleam/string
import sgleam/check

pub type Resultado {
  //Tipo união para identiicar o jogo, com times e gols
  Resultado(time_um: String, gol_um: Gol, time_dois: String, gol_dois: Gol)
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
  //Caso times 
  SemTimes
}

//Função que transforma uma lista de jogos do campeonato brasileiro e transforma ela em uma
//tabela de pontuações dos times, contendo Pontuação, saldo de gols e número de vitórias.
//A função recebe uma lista de strings de *Jogo*, com cada jogo contendo os *times* e *gols*,
//ao final ela deve devolver uma lista de Strings com uma tabela exibindo as pontuações
//dos time no campeonato:  o saldo de gols (gols sofridos - gols feitos), a pontuação total (Empate: 1 ponto, 
//Vitória: 3 pontos, Derrota: 0 Pontos) dos times e o número de vitórias totais de cada time.
//Essa lista deve ser ordenada com prioridades sendo: Pontuação, número e vitórias, Saldo de gols e 
//por fim Ordem alfabética dos nomes dos times.
pub fn main(lst_jogos: List(String)) -> List(String) {
  todo
}

pub fn main_examples(){
  check.eq(main(["Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1", "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2"]), ["Flamengo 6 2 2","Atletico-MG 3 1 0", 
                                                                                                                                  "Palmeiras 1 0 -1", "Sao-Paulo 1 0 -1"])
}



///Função que baseado em uma lista de Strings dos *Jogos*, cria uma lista de *Resultados*.
///A função recebe uma lista de strings que são os resultados, as strings são divididas
/// e cada campo é inserido dentro de um *Resultado*, esses tipos são inseridos
/// dentro de uma lista de *Resultados* que é o retorno final da função.
pub fn cria_resultado(lst: List(String)) -> Result(List(Resultado), Erros) {
  case lst{
    [] -> Ok([])
    [primeiro, ..resto] -> {
      case cria_resultado(resto){
        Ok(a) -> case string_to_resultado(string.split(primeiro, " ")){
          Ok(b) -> Ok([b, ..a])
          Error(c) -> Error(c)
        }
        Error(a) -> Error(a)
      }
    }
  }
}

pub fn cria_resultado_examples(){
  check.eq(cria_resultado(["Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1"]), Ok([Resultado("Sao-Paulo", Gol(1), "Atletico-MG", Gol(2)), 
                                                                                        Resultado("Flamengo", Gol(2), "Palmeiras", Gol(1))]))

  check.eq(cria_resultado(["Sao-Paulo -1 Atletico-MG 2", "Flamengo 2 Palmeiras 1"]), Error(PlacarInvalido))
  check.eq(cria_resultado(["Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Flamengo 1"]), Error(TimeDuplicado))
  check.eq(cria_resultado(["Flamengo 2 Palmeiras 1", "Flamengo 2 Palmeiras 1"]), Error(JogoDuplicado))
  check.eq(cria_resultado(["2 1", " 2 1"]), Error(CamposIncompletos))
  check.eq(cria_resultado(["", ""]), Error(CamposIncompletos))
}

//Função que compara um elemento de uma lista de resultados com os outros elementos da lista
pub fn compara_com_resto(lst: List(Resultado), res: Resultado) -> Bool{
  case lst{
    [] -> False
    [primeiro, ..resto] -> {
      case res == primeiro{
        True -> True
        False -> compara_com_resto(resto, res)
      }
    }
  }
}


pub fn compara_com_resto_examples(){
  let assert Ok(gol1) = new_gol(4)
  let assert Ok(gol2) = new_gol(3)
  let assert Ok(gol3) = new_gol(5)
  let assert Ok(gol4) = new_gol (7)

  check.eq(compara_com_resto([Resultado("Flamengo", gol2, "Santos", gol1), Resultado("Flamengo", gol3, "Botafogo", gol4)], Resultado("Flamengo", gol1, "Santos", gol1)), True)
}

/// REVISA ISSO******************************************************************************************************************************************************************************
///Função auxiliar à cria_resultado que retorna a lista de String dada em forma de Resultados.
///A função recebe uma Lista de strings que foram divididas anteriormente e as coloca dentro
/// de um tipo *Resultado*, fazendo todas as verificações de erros que tangem à resultado único.
/// A saída da função é um Result, em caso de algum erro listado, retorna Error, caso tudo
/// esteja correto retorna o Ok(Result()) com o resultado do jogo.
pub fn string_to_resultado(str: List(String)) -> Result(Resultado, Erros) {
  case str {
    [] -> Error(SemTimes)
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

    [_, _, _, _, ..] -> Error(MaxCamposExcedidos)
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

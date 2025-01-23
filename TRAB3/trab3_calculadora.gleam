import gleam/list
import gleam/option.{type Option, None, Some}
import sgleam/check

pub type Erros {
  ParentesesInvalidos
  CaractereInvalido
  ExpressaoVazia
}

pub type TipoSimbolo {
  Soma
  Sub
  Mul
  Div
}

pub type TipoValor {
  Operador(simbolo: TipoSimbolo)
  Numero(valor: Int)
}

pub fn get_valor(num: TipoValor) -> Option(Int) {
  case num {
    Numero(valor) -> Some(valor)
    Operador(_) -> None
  }
}

//Função que a partir da pilha em questão faz as operações
//em notação pós-fixa. Para cada *numero* dentro da lista
//a função o empilha, para cada operador, dois valores são desempilhados
//a operação é executada e o resultado é empilhado, então se analisa o proximo operador.
//O retorno da função é um valor inteiro com um resultado.
pub fn calc_pilha(lst: List(TipoValor)) -> Int {
  let assert Ok(result) = list.fold(lst, [], empilha) |> list.first
  get_valor(result)
  |> option.unwrap(0)
}

pub fn calc_pilha_examples() {
  check.eq(
    calc_pilha([Numero(2), Numero(7), Numero(3), Operador(Mul), Operador(Soma)]),
    23,
  )
  check.eq(
    calc_pilha([Numero(-2), Numero(7), Numero(3), Operador(Mul), Operador(Soma)]),
    19,
  )
  check.eq(
    calc_pilha([
      Numero(-2),
      Numero(7),
      Numero(-3),
      Operador(Mul),
      Operador(Soma),
    ]),
    -23,
  )
  check.eq(
    calc_pilha([Numero(2), Numero(7), Numero(3), Operador(Mul), Operador(Div)]),
    0,
  )
  check.eq(
    calc_pilha([
      Numero(5),
      Numero(6),
      Operador(Soma),
      Numero(8),
      Numero(7),
      Operador(Soma),
      Operador(Div),
      Numero(15),
      Operador(Mul),
      Numero(3),
      Operador(Div),
    ]),
    0,
  )
  //Arredondamento do gleam faz ficar 0
  check.eq(
    calc_pilha([
      Numero(2),
      Numero(7),
      Numero(3),
      Operador(Mul),
      Numero(6),
      Operador(Mul),
      Operador(Soma),
    ]),
    128,
  )
}

//Empilha os valores da lista dos valores pós-fixos
//e realiza os calculos se encontrar um operador.
pub fn empilha(acc: List(TipoValor), elem: TipoValor) -> List(TipoValor) {
  case elem {
    Numero(valor) -> list.append(acc, [Numero(valor)])
    Operador(simbolo) ->
      case acc {
        [primeiro, segundo, terceiro] -> [
          primeiro,
          desempilha_calcula(segundo, terceiro, simbolo),
        ]
        [primeiro, segundo] -> [desempilha_calcula(primeiro, segundo, simbolo)]
        _ -> acc
      }
  }
}

// Faz o calculo baseado em dois valores e um operador.
pub fn desempilha_calcula(
  num1: TipoValor,
  num2: TipoValor,
  operador: TipoSimbolo,
) -> TipoValor {
  let assert Some(numer1) = get_valor(num1)
  let assert Some(numer2) = get_valor(num2)
  case operador {
    Soma -> Numero(numer1 + numer2)
    Sub -> Numero(numer1 - numer2)
    Mul -> Numero(numer1 * numer2)
    Div -> Numero(numer1 / numer2)
  }
}

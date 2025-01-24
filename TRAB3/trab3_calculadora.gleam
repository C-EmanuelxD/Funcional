import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import sgleam/check

pub type Erros {
  //Caso de parenteses dispostos de forma incorreta
  ParentesesInvalidos
  //Caso de letras ou outros tipos de simbolos que não são corretos no calculo
  SimboloInvalido
  //Caso não exista nada dentro da expressão
  ExpressaoVazia
}

pub type TipoSimbolo {
  //Simbolo correspondente a soma de valores
  Soma
  //Simbolo correspondente a subtração de valores
  Sub
  //Simbolo correspondente a Multiplicação de valores
  Mul
  //Simbolo correspondente a Divisao de valores
  Div
  //Simbolo correspondente a um parentese esquerdo - )
  ParenteseEsq
  //Simbolo correspondente a um parentese direito - (
  ParenteseDir
}

pub type TipoValor {
  //Operador seria o tipo que carrega o simbolo dentro das listas e processamentos
  Operador(simbolo: TipoSimbolo)
  //Numero seriam os valores numericos carregados dentro da lista
  Numero(valor: Int)
  //Quando nenhum valor é necessário
  NoneTp
}

//Retorna o valor Inteiro dentro do Numero, em formato de option, caso seja
//um operador retorna None.
pub fn get_valor(num: TipoValor) -> Option(Int) {
  case num {
    Numero(valor) -> Some(valor)
    Operador(simbolo) -> None
    NoneTp -> None
  }
}

//Verifica se os parenteses estão dispostos de forma correta,
//verificando a quantidade de parenteses direitos e esquerdos.
pub fn verifica_parenteses(lst: List(String)) -> Result(Bool, Erros) {
  list.fold(lst, Ok(0), fn(acc, elem) {
    use a <- result.try(acc)
    case elem {
      "(" -> Ok(a + 1)
      ")" if a > 0 -> Ok(a - 1)
      ")" -> Error(ParentesesInvalidos)
      _ -> Ok(a)
    }
  })
  |> result.try(fn(final_balance) {
    case final_balance {
      0 -> Ok(True)
      _ -> Error(ParentesesInvalidos)
    }
  })
}

pub fn verifica_parenteses_examples() {
  check.eq(
    verifica_parenteses(["(", ")", ")", "("]),
    Error(ParentesesInvalidos),
  )
  check.eq(verifica_parenteses(["(", ")", ")"]), Error(ParentesesInvalidos))
  check.eq(verifica_parenteses(["(", "(", ")"]), Error(ParentesesInvalidos))
  check.eq(verifica_parenteses(["(", ")"]), Ok(True))
  // Teste com sequência correta
  check.eq(verifica_parenteses(["(", ")", "(", ")"]), Ok(True))

  // Teste com mais parênteses fechados que abertos
  check.eq(verifica_parenteses(["(", ")", ")"]), Error(ParentesesInvalidos))

  // Teste com mais parênteses abertos que fechados
  check.eq(verifica_parenteses(["(", "(", ")"]), Error(ParentesesInvalidos))

  // Teste com sequência vazia
  check.eq(verifica_parenteses([]), Ok(True))

  // Teste com sequência contendo apenas parênteses abertos
  check.eq(verifica_parenteses(["(", "(", "("]), Error(ParentesesInvalidos))

  // Teste com sequência contendo apenas parênteses fechados
  check.eq(verifica_parenteses([")", ")", ")"]), Error(ParentesesInvalidos))

  // Teste com parênteses balanceados em ordem alternada
  check.eq(verifica_parenteses(["(", ")", "(", "(", ")", ")"]), Ok(True))

  // Teste com sequência contendo caracteres não relacionados
  check.eq(verifica_parenteses(["(", "a", ")", "b", "(", ")"]), Ok(True))

  // Teste com parênteses desbalanceados misturados
  check.eq(
    verifica_parenteses(["(", ")", "(", ")", ")"]),
    Error(ParentesesInvalidos),
  )

  // Teste com parênteses balanceados de forma correta
  check.eq(verifica_parenteses(["(", "(", ")", ")"]), Ok(True))
}

//Função que recebe uma *lista* com os *valores* dentro do TipoValor em
//notação infixa e a transforma em notação pós-fixa, organizando
//os valores de acordo com o requerimento da notação.
pub fn organiza_posfixo(lst: List(TipoValor)) -> List(TipoValor) {
  let #(tpl1, tpl2) =
    list.fold(lst, #([], []), fn(acc, elem) {
      case elem {
        Operador(simbolo) ->
          case acc.1 {
            [] -> #(acc.0, list.append(acc.1, [Operador(simbolo)]))
            [primeiro, _] ->
              case
                prioridade(simbolo)
                >= prioridade(case primeiro {
                  Operador(x) -> x
                  _ -> Div
                })
              {
                True -> {
                  let nova_pilha_antes = list.append(acc.1, [Operador(simbolo)])
                  let nova_pilha =
                    list.reverse(
                      list.filter(nova_pilha_antes, fn(a) {
                        a != Operador(ParenteseDir)
                        || a != Operador(ParenteseEsq)
                      }),
                    )
                  #(list.append(acc.0, nova_pilha), [])
                }
                False -> #(acc.0, list.append(acc.1, [Operador(simbolo)]))
              }
            [_, ..] -> #(acc.0, list.append(acc.1, [Operador(simbolo)]))
          }
        Numero(num) -> #(list.append(acc.0, [Numero(num)]), acc.1)
        _ -> #(acc.0, acc.1)
      }
    })

  list.append(tpl1, list.reverse(tpl2))
}

//pub fn organiza_posfixo_examples(){
//  check.eq(organiza_posfixo([Numero(4), Operador(Soma), Numero (6), Operador(Mul), Numero(2)]))
//  check.eq(organiza_posfixo([Operador(ParenteseDir), Numero(4), Operador(Soma), Numero (6), Operador(ParenteseEsq), Operador(Mul), Numero(2)]))
//  check.eq(organiza_posfixo([Operador(ParenteseDir), Numero(4), Operador(Div), Numero(2), Operador(ParenteseEsq), Operador(Soma), Numero(4)]))
//}

//4+6*2
pub fn prioridade(simb: TipoSimbolo) -> Int {
  case simb {
    ParenteseDir | ParenteseEsq -> 3
    Mul | Div -> 2
    Sub | Soma -> 1
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
    _ -> []
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
    _ -> NoneTp
  }
}

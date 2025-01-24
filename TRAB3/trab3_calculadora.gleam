import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import sgleam/check
import gleam/int
import gleam/order
pub type Erros {
  //Caso de parenteses dispostos de forma incorreta
  ParentesesInvalidos
  //Caso de letras ou outros tipos de simbolos que não são corretos no calculo
  SimboloInvalido
  //Caso não exista nada dentro da expressão
  ExpressaoVazia

  PilhaVazia

  EntradaInvalida
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
    Operador(_) -> None
    NoneTp -> None
  }
}

pub fn get_simbolo(simb: TipoValor) -> Result(TipoSimbolo, Erros) {
  case simb {
    Operador(x) -> Ok(x)
    _ -> Error(EntradaInvalida)
  }
}

//Verifica se os parenteses estão dispostos de forma correta,
//verificando a quantidade de parenteses direitos e esquerdos.
pub fn verifica_parenteses(lst: List(String)) -> Result(Nil, Erros) {
  use balanceamento <- result.try(list.fold(lst, Ok(0), conta_parentese))
  case balanceamento {
      0 -> Ok(Nil)
      _ -> Error(ParentesesInvalidos)
  }
}

pub fn verifica_parenteses_examples() {
  check.eq(
    verifica_parenteses(["(", ")", ")", "("]),
    Error(ParentesesInvalidos),
  )
  check.eq(verifica_parenteses(["(", ")", ")"]), Error(ParentesesInvalidos))
  check.eq(verifica_parenteses(["(", "(", ")"]), Error(ParentesesInvalidos))
  check.eq(verifica_parenteses(["(", ")"]), Ok(Nil))
  // Teste com sequência correta
  check.eq(verifica_parenteses(["(", ")", "(", ")"]), Ok(Nil))

  // Teste com mais parênteses fechados que abertos
  check.eq(verifica_parenteses(["(", ")", ")"]), Error(ParentesesInvalidos))

  // Teste com mais parênteses abertos que fechados
  check.eq(verifica_parenteses(["(", "(", ")"]), Error(ParentesesInvalidos))

  // Teste com sequência vazia
  check.eq(verifica_parenteses([]), Ok(Nil))

  // Teste com sequência contendo apenas parênteses abertos
  check.eq(verifica_parenteses(["(", "(", "("]), Error(ParentesesInvalidos))

  // Teste com sequência contendo apenas parênteses fechados
  check.eq(verifica_parenteses([")", ")", ")"]), Error(ParentesesInvalidos))

  // Teste com parênteses balanceados em ordem alternada
  check.eq(verifica_parenteses(["(", ")", "(", "(", ")", ")"]), Ok(Nil))

  // Teste com sequência contendo caracteres não relacionados
  check.eq(verifica_parenteses(["(", "a", ")", "b", "(", ")"]), Ok(Nil))

  // Teste com parênteses desbalanceados misturados
  check.eq(
    verifica_parenteses(["(", ")", "(", ")", ")"]),
    Error(ParentesesInvalidos),
  )

  // Teste com parênteses balanceados de forma correta
  check.eq(verifica_parenteses(["(", "(", ")", ")"]), Ok(Nil))
}

//Função auiliar que conta a quantidade de parenteses e retorna erro caso não estejam
//dispostoss de forma correta.
pub fn conta_parentese(acc: Result(Int, Erros), elem: String) -> Result(Int, Erros){
  use a <- result.try(acc)
  case elem {
    "(" -> Ok(a + 1)
    ")" if a > 0 -> Ok(a - 1)
    ")" -> Error(ParentesesInvalidos)
    _ -> Ok(a)
  }
}


//Função que recebe uma *lista* com os *valores* dentro do TipoValor em
//notação infixa e a transforma em notação pós-fixa, organizando
//os valores de acordo com o requerimento da notação.
pub fn organiza_posfixo(lst: List(TipoValor)) -> Result(List(TipoValor), Erros) {
  use #(saida, pilha) <- result.try(list.fold(lst, Ok(#([], [])), foda_gorda))
  Ok(list.append(saida, pilha))
}

pub fn foda_gorda(acumulador: Result(#(List(TipoValor), List(TipoValor)), Erros), elem: TipoValor) -> Result(#(List(TipoValor), List(TipoValor)), Erros){
    use acc <- result.try(acumulador)
    case elem {
      Numero(num) -> Ok(#(list.append(acc.0, [Numero(num)]), acc.1))
      Operador(simbolo) -> opera_pilha(acc, Operador(simbolo))
      _ -> Ok(acc)
    }
}

//pub fn organiza_posfixo_examples(){
//  check.eq(organiza_posfixo([Numero(4), Operador(Soma), Numero (6), Operador(Mul), Numero(2)]))
//  check.eq(organiza_posfixo([Operador(ParenteseEsq), Numero(4), Operador(Soma), Numero (6), Operador(ParenteseDir), Operador(Mul), Numero(2)]))
//  check.eq(organiza_posfixo([Operador(ParenteseEsq), Numero(4), Operador(Div), Numero(2), Operador(ParenteseDir), Operador(Soma), Numero(4)]))
//  check.eq(organiza_posfixo([Operador(ParenteseEsq),Operador(ParenteseEsq), Numero(4), Operador(Div), Numero(2),  Operador(ParenteseDir), Operador(Soma), Numero(6), Operador(ParenteseDir), Operador(Mul), Numero(-13)])) ((4/2)+6)*-13
//}

// TAD EMPILHA
pub fn empilha(lst: List(a), valor: a) -> List(a){
  [valor, ..lst]
}

//TAD DESEMPILHA
pub fn desempilha(lst: List(TipoValor)) -> Result(#(List(TipoValor), TipoValor), Erros){
  case lst{
    [] -> Error(PilhaVazia)
    [primeiro, ..resto] -> Ok(#(resto, primeiro))
  }
} 

//verifica se a pilha está vazia.
pub fn verifica_pilha_vazia(lst: List(TipoValor)) -> Bool{
  case desempilha(lst){
    Ok(_) -> False
    Error(_) -> True
  }
}

//Verifica o simbolo passado e faz as operações dentro da pilha que são respectivos
//as regras do posfixo. Retorna ao final a tupla com a *lista de saida* e a *pilha de operadores*
pub fn opera_pilha(pilha: #(List(TipoValor), List(TipoValor)), simb: TipoValor) ->  Result(#(List(TipoValor), List(TipoValor)), Erros){
  case simb{
    Operador(ParenteseEsq) -> Ok(#(pilha.0 ,empilha(pilha.1, simb)))
    Operador(ParenteseDir) -> Ok(desempilha_ate_parentese(pilha))
    Operador(x) -> empilha_operadores(pilha, x)
    _ -> Ok(pilha)
  }
}

//Recebe um operador e dependendo da comparação realiza o empilhamento dos operadores ou
//a adição na saida, no final retorna uma tupla com todas as operações realizadas.
pub fn empilha_operadores(pilha: #(List(TipoValor), List(TipoValor)), simb: TipoSimbolo) ->  Result(#(List(TipoValor), List(TipoValor)), Erros){
  case verifica_pilha_vazia(pilha.1){
    True -> Ok(#(pilha.0, empilha(pilha.1, Operador(simb))))
    False -> {
      use #(lista, simbolo_topo) <- result.try(desempilha(pilha.1))
      use simbolo_top <- result.try(get_simbolo(simbolo_topo))
      case int.compare(peso(simb), peso(simbolo_top)){
        order.Gt -> Ok(#(pilha.0, empilha(pilha.1, Operador(simb))))
        order.Eq -> Ok(#(list.append(pilha.0, [Operador(simb)]), pilha.1))
        order.Lt -> Ok(#(list.append(pilha.0, [simbolo_topo]), lista))
      }
    }
  } 
}

//Recebe um simbolo e retorna seu peso ou preferencia.
pub fn peso(simb: TipoSimbolo) -> Int{
  case simb{
    Mul | Div -> 2
    Soma | Sub -> 1
    ParenteseEsq | ParenteseDir -> 0
  }
}

//Desempilha todos os valores da *pilha de operações* até achar um parentese esquerdo - (, ao final
//concatena todos os valores desempilhados na *saida* e retira os parenteses da *pilha de operações*.
pub fn desempilha_ate_parentese(pilha: #(List(TipoValor), List(TipoValor))) ->  #(List(TipoValor), List(TipoValor)){
  let lista_desempilhados = list.take_while(pilha.1, fn(x){x != Operador(ParenteseEsq)})
  let pilha_nova = list.drop(pilha.1, {list.length(lista_desempilhados) + 1})
  #(list.append(pilha.0, lista_desempilhados), pilha_nova)
}


//Função que a partir da pilha em questão faz as operações
//em notação pós-fixa. Para cada *numero* dentro da lista
//a função o empilha, para cada operador, dois valores são desempilhados
//a operação é executada e o resultado é empilhado, então se analisa o proximo operador.
//O retorno da função é um valor inteiro com um resultado.
pub fn calc_pilha(lst: List(TipoValor)) -> Int {
  let assert Ok(result) = list.fold(lst, [], empilha_calc) |> list.first
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
pub fn empilha_calc(acc: List(TipoValor), elem: TipoValor) -> List(TipoValor) {
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

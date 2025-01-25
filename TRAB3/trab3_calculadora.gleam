import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import sgleam/check

pub type Erros {
  //Caso de parenteses dispostos de forma incorreta
  ParentesesInvalidos
  //Caso de letras ou outros tipos de simbolos que não são corretos no calculo
  SimboloInvalido
  //Caso de problemas com pilha vazia dentro das pilhas
  PilhaVazia
  //Caso alguma entrada esteja disposta de forma incorreta
  EntradaInvalida
  //Erro de caso algumas listas estejam vazias
  ListaVazia
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
}

//Retorna o valor Inteiro dentro do Numero, caso algum outro formato
//seja inserido, retorna erro.
pub fn get_valor(num: TipoValor) -> Result(Int, Erros) {
  case num {
    Numero(valor) -> Ok(valor)
    Operador(_) -> Error(EntradaInvalida)
  }
}

//Retorna o *simbolo* dentro do Operador caso outro
//tipo de valor seja inserido retorna erro
pub fn get_simbolo(simb: TipoValor) -> Result(TipoSimbolo, Erros) {
  case simb {
    Operador(x) -> Ok(x)
    _ -> Error(EntradaInvalida)
  }
}


pub fn main_calculadora(entrada: String) -> Result(Int, Erros){
  use str <- result.try(normaliza_lista(entrada))
  use str_org <- result.try(organiza_posfixo(str))
  use resultado <- result.try(calc_pilha(str_org))

  Ok(resultado)
}


pub fn main_calculadora_examples(){
  check.eq(main_calculadora(""), Error(EntradaInvalida))
  check.eq(main_calculadora("7"), Ok(7))
  check.eq(main_calculadora("9+9"), Ok(18))
  check.eq(main_calculadora("9+9*9"), Ok(90))
  check.eq(main_calculadora("(9+9)*9"), Ok(162))
  check.eq(main_calculadora("7+6/3"), Ok(9))
  check.eq(main_calculadora("(7+6)/3"), Ok(4))
  check.eq(main_calculadora("(21+22)/(8+9)"), Ok(2))
  check.eq(main_calculadora("((21+22)/(8+9))*(-1)"), Ok(-2))
  check.eq(main_calculadora("(-8/2)*3+(-4)-6"), Ok(-22))
  check.eq(main_calculadora("4+7+8/"), Error(EntradaInvalida))
  check.eq(main_calculadora("4+a+8"), Error(SimboloInvalido))
  check.eq(main_calculadora("((4+4)+8"), Error(ParentesesInvalidos))
}



pub fn normaliza_lista(entrada: String) -> Result(List(TipoValor), Erros) {
  let separado = string.replace(entrada, " ", "") |> string.split("")
  use _ <- result.try(separado |> verifica_parenteses)
  use resultado <- result.try(list.fold(separado, Ok([]), concatena_valores))
  list.map(list.reverse(resultado), string_to_valores)
  |> result.all
}

pub fn normaliza_lista_examples() {
  check.eq(
    normaliza_lista("(2+21)-1*2"),
    Ok([
      Operador(ParenteseEsq),
      Numero(2),
      Operador(Soma),
      Numero(21),
      Operador(ParenteseDir),
      Operador(Sub),
      Numero(1),
      Operador(Mul),
      Numero(2),
    ]),
  )
  check.eq(
    normaliza_lista("-2+3"),
    Ok([Numero(-2), Operador(Soma), Numero( 3)]),
  )
  check.eq(
    normaliza_lista("12+34"),
    Ok([Numero(12), Operador(Soma), Numero(34)]),
  )
  check.eq(normaliza_lista("(3*/2"), Error(ParentesesInvalidos))
  check.eq(
    normaliza_lista("(2+21)-1*2"),
    Ok([
      Operador(ParenteseEsq),
      Numero(2),
      Operador(Soma),
      Numero(21),
      Operador(ParenteseDir),
      Operador(Sub),
      Numero(1),
      Operador(Mul),
      Numero(2),
    ]),
  )
  check.eq(
    normaliza_lista("-2+3"),
    Ok([Numero( -2), Operador( Soma), Numero( 3)]),
  )
  check.eq(
    normaliza_lista("12+34"),
    Ok([Numero(12), Operador(Soma), Numero(34)]),
  )
  check.eq(normaliza_lista("(3*/2"), Error(ParentesesInvalidos))
  check.eq(
    normaliza_lista("(-2+21)-1*2"),
    Ok([
      Operador( ParenteseEsq),
      Numero(-2),
      Operador(Soma),
      Numero( 21),
      Operador( ParenteseDir),
      Operador( Sub),
      Numero( 1),
      Operador( Mul),
      Numero( 2),
    ]),
  )
  check.eq(
    normaliza_lista("-(-3+4)*2"),
    Ok([
      Operador( Sub),
      Operador( ParenteseEsq),
      Numero( -3),
      Operador( Soma),
      Numero( 4),
      Operador( ParenteseDir),
      Operador( Mul),
      Numero( 2),
    ]),
  )
}

pub fn string_to_valores(elem: String) -> Result(TipoValor, Erros) {
  case elem {
    "-" -> Ok(Operador(Sub))
    "+" -> Ok(Operador(Soma))
    "*" -> Ok(Operador(Mul))
    "/" -> Ok(Operador(Div))
    "(" -> Ok(Operador(ParenteseEsq))
    ")" -> Ok(Operador(ParenteseDir))
    _ -> {
      use valor <- result.try(
        result.map_error(int.parse(elem), fn(_) { SimboloInvalido }),
      )
      Ok(Numero(valor))
    }
  }
}

pub fn concatena_valores(
  acumulador: Result(List(String), Erros),
  elem: String,
) -> Result(List(String), Erros) {
  use acc <- result.try(acumulador)
  case acc {
    [] -> Ok(list.append([elem], acc))
    _ -> agrupa_valores(acc, elem)
  }
}

/// recebe um acumulador e com base do elemento no topo, consegue organizar se concatena numeros, 
/// negativos, ou entao se so faz um append no acumulador e retorna
pub fn agrupa_valores(
  acc: List(String),
  elem: String,
) -> Result(List(String), Erros) {
  let pilha_nova = list.drop(acc, 1)
  use a <- result.try(
    list.take(acc, 2)
    |> list.first
    |> result.map_error(fn(_) { ListaVazia }),
  )
  use b <- result.try(
    list.take(acc, 2)
    |> list.last
    |> result.map_error(fn(_) { ListaVazia }),
  )

  let tam = string.length(a)
  use first <- result.try(
    string.first(a)
    |> result.map_error(fn(_) { ListaVazia }),
  )
  let num = verifica_num(a)
  let num2 = verifica_num(b)
  // se entrar no true e colocar o - no inicio significa que vai ser 
  case elem {
    "-" if a == "(" -> Ok(list.append([elem], acc))
    "-" | "+" | "*" | "/" | "(" | ")" -> Ok(list.append([elem], acc))
    _ if b == ")" && a == "-" -> Ok(list.append([elem], acc))
    _ if num2 && a == "-" -> Ok(list.append([elem], acc))
    _ if tam >= 2 && first == "-" || a == "-" ->
      Ok(list.append([string.append(a, elem)], pilha_nova))
    _ if num -> Ok(list.append([string.append(a, elem)], pilha_nova))
    _ -> Ok(list.append([elem], acc))
  }
}



pub fn verifica_num(elem: String) -> Bool {
  case int.parse(elem) {
    Ok(_) -> True
    Error(_) -> False
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
pub fn conta_parentese(
  acc: Result(Int, Erros),
  elem: String,
) -> Result(Int, Erros) {
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
  use #(saida, pilha) <- result.try(list.fold(
    lst,
    Ok(#([], [])),
    processa_valor,
  ))
  Ok(list.append(saida, pilha))
}

pub fn organiza_posfixo_examples() {
  check.eq(
    organiza_posfixo([
      Numero(4),
      Operador(Soma),
      Numero(6),
      Operador(Mul),
      Numero(2),
    ]),
    Ok([Numero(4), Numero(6), Numero(2), Operador(Mul), Operador(Soma)]),
  )
  check.eq(
    organiza_posfixo([
      Operador(ParenteseEsq),
      Numero(4),
      Operador(Soma),
      Numero(6),
      Operador(ParenteseDir),
      Operador(Mul),
      Numero(2),
    ]),
    Ok([Numero(4), Numero(6), Operador(Soma), Numero(2), Operador(Mul)]),
  )
  check.eq(
    organiza_posfixo([
      Operador(ParenteseEsq),
      Numero(4),
      Operador(Div),
      Numero(2),
      Operador(ParenteseDir),
      Operador(Soma),
      Numero(4),
    ]),
    Ok([Numero(4), Numero(2), Operador(Div), Numero(4), Operador(Soma)]),
  )
  check.eq(
    organiza_posfixo([
      Operador(ParenteseEsq),
      Operador(ParenteseEsq),
      Numero(4),
      Operador(Div),
      Numero(2),
      Operador(ParenteseDir),
      Operador(Soma),
      Numero(6),
      Operador(ParenteseDir),
      Operador(Mul),
      Numero(5),
    ]),
    Ok([
      Numero(4),
      Numero(2),
      Operador(Div),
      Numero(6),
      Operador(Soma),
      Numero(5),
      Operador(Mul),
    ]),
  )
  check.eq(
    organiza_posfixo([
      Operador(ParenteseEsq),
      Operador(ParenteseEsq),
      Numero(4),
      Operador(Div),
      Numero(2),
      Operador(Soma),
      Numero(9),
      Operador(ParenteseDir),
      Operador(Soma),
      Numero(6),
      Operador(ParenteseDir),
      Operador(Mul),
      Numero(5),
    ]),
    Ok([
      Numero(4),
      Numero(2),
      Operador(Div),
      Numero(9),
      Operador(Soma),
      Numero(6),
      Operador(Soma),
      Numero(5),
      Operador(Mul),
    ]),
  )
}

//Verifica o *valor* e a *tupla* a serem processados e empilha ou
//desempilha e adiciona na saida os valores necessários, caso o valor seja um *numero*
//adiciona o numero na saida (primeira tupla), caso seja um operador, deve se verificar
//a pilha e adicionar a saida ou empilhar de acordo com a logica pos-fixa.
pub fn processa_valor(
  acumulador: Result(#(List(TipoValor), List(TipoValor)), Erros),
  elem: TipoValor,
) -> Result(#(List(TipoValor), List(TipoValor)), Erros) {
  use acc <- result.try(acumulador)
  case elem {
    Numero(num) -> Ok(#(list.append(acc.0, [Numero(num)]), acc.1))
    Operador(simbolo) -> opera_pilha(acc, Operador(simbolo))
  }
}

//Empilha um valor dentro de uma pilha
pub fn empilha(lst: List(a), valor: a) -> List(a) {
  [valor, ..lst]
}

//Desempilha um valor de dentro de uma pilha, caso a pilha esteja vazia retorna erro.
pub fn desempilha(
  lst: List(TipoValor),
) -> Result(#(List(TipoValor), TipoValor), Erros) {
  case lst {
    [] -> Error(PilhaVazia)
    [primeiro, ..resto] -> Ok(#(resto, primeiro))
  }
}

//verifica se a pilha está vazia.
pub fn verifica_pilha_vazia(lst: List(TipoValor)) -> Bool {
  case desempilha(lst) {
    Ok(_) -> False
    Error(_) -> True
  }
}

//Verifica o Operador passado e empilha ou desempilha dependendo do operador, também
//adiciona os valores a lista de saida, quando um parenteses foor fechado.
//Caso seja uma abertura de parenteses ele o empilha, caso seja um parenteses
//sendo fechado ele desempilha até o parentese aberto e adiciona os operadores
//dentro da lista de saida. Caso seja um operador, ele analisa o topo da pilha
//e ve se o operador entra na pilha ou entra na saida.
pub fn opera_pilha(
  pilha: #(List(TipoValor), List(TipoValor)),
  simb: TipoValor,
) -> Result(#(List(TipoValor), List(TipoValor)), Erros) {
  case simb {
    Operador(ParenteseEsq) -> Ok(#(pilha.0, empilha(pilha.1, simb)))
    Operador(ParenteseDir) -> Ok(desempilha_ate_parentese(pilha))
    Operador(x) -> empilha_operadores(pilha, x)
    _ -> Ok(pilha)
  }
}

pub fn opera_pilha_examples() {
  check.eq(
    opera_pilha(
      #([Numero(4), Numero(3)], [Operador(Soma), Operador(ParenteseEsq)]),
      Operador(ParenteseDir),
    ),
    Ok(#([Numero(4), Numero(3), Operador(Soma)], [])),
  )

  check.eq(
    opera_pilha(#([Numero(4), Numero(3)], [Operador(Soma)]), Operador(Soma)),
    Ok(#([Numero(4), Numero(3), Operador(Soma)], [Operador(Soma)])),
  )

  check.eq(
    opera_pilha(
      #([Numero(4), Numero(3), Numero(8)], [Operador(Soma)]),
      Operador(Mul),
    ),
    Ok(#([Numero(4), Numero(3), Numero(8)], [Operador(Mul), Operador(Soma)])),
  )

  check.eq(
    opera_pilha(
      #([Numero(4), Numero(3), Numero(8)], [Operador(Div)]),
      Operador(Mul),
    ),
    Ok(#([Numero(4), Numero(3), Numero(8), Operador(Div)], [Operador(Mul)])),
  )
}

//Recebe um operador e dependendo da comparação realiza o empilhamento dos operadores ou
//a adição na saida, no final retorna uma tupla com todas as operações realizadas.
//Caso a pilha esteja vazia, apenas empilha o operador em questão
pub fn empilha_operadores(
  pilha: #(List(TipoValor), List(TipoValor)),
  simb: TipoSimbolo,
) -> Result(#(List(TipoValor), List(TipoValor)), Erros) {
  use <- bool.guard(
    verifica_pilha_vazia(pilha.1),
    Ok(#(pilha.0, empilha(pilha.1, Operador(simb)))),
  )
  use #(lista, simbolo_topo) <- result.try(desempilha(pilha.1))
  use simbolo_top <- result.try(get_simbolo(simbolo_topo))
  case peso(simb) > peso(simbolo_top) {
    True -> Ok(#(pilha.0, empilha(pilha.1, Operador(simb))))
    False ->
      Ok(#(
        list.append(pilha.0, [Operador(simbolo_top)]),
        empilha(lista, Operador(simb)),
      ))
  }
}

//Recebe um simbolo e retorna seu peso ou preferencia.
pub fn peso(simb: TipoSimbolo) -> Int {
  case simb {
    Mul | Div -> 2
    Soma | Sub -> 1
    ParenteseEsq | ParenteseDir -> 0
  }
}

//Desempilha todos os valores da *pilha de operações* até achar um parentese esquerdo - (, ao final
//concatena todos os valores desempilhados na *saida* e retira os parenteses da *pilha de operações*.
pub fn desempilha_ate_parentese(
  pilha: #(List(TipoValor), List(TipoValor)),
) -> #(List(TipoValor), List(TipoValor)) {
  let lista_desempilhados =
    list.take_while(pilha.1, fn(x) { x != Operador(ParenteseEsq) })
  let pilha_nova = list.drop(pilha.1, { list.length(lista_desempilhados) + 1 })
  #(list.append(pilha.0, lista_desempilhados), pilha_nova)
}

//Função que a partir da pilha em questão faz as operações
//em notação pós-fixa. Para cada *numero* dentro da lista
//a função o empilha, para cada *operador*, dois *valores* são desempilhados
//a operação é executada e o *resultado* é empilhado, então se analisa o proximo valor.
//O retorno da função é um valor inteiro com um resultado.
pub fn calc_pilha(lst: List(TipoValor)) -> Result(Int, Erros) {
  use resultado_lista <- result.try(list.fold(lst, Ok([]), empilha_calc))
  use valor <- result.try(
    result.map_error(list.first(resultado_lista), fn(_) { EntradaInvalida }),
  )
  use valor_final <- result.try(get_valor(valor))
  Ok(valor_final)
}

pub fn calc_pilha_examples() {
  check.eq(
    calc_pilha([Numero(2), Numero(7), Numero(3), Operador(Mul), Operador(Soma)]),
    Ok(23),
  )
  check.eq(
    calc_pilha([
      Numero(2),
      Numero(7),
      Numero(3),
      Numero(1),
      Operador(Mul),
      Operador(Soma),
    ]),
    Error(EntradaInvalida),
  )

  check.eq(
    calc_pilha([Numero(-2), Numero(7), Numero(3), Operador(Mul), Operador(Soma)]),
    Ok(19),
  )
  check.eq(
    calc_pilha([
      Numero(-2),
      Numero(7),
      Numero(-3),
      Operador(Mul),
      Operador(Soma),
    ]),
    Ok(-23),
  )
  check.eq(
    calc_pilha([Numero(2), Numero(7), Numero(3), Operador(Mul), Operador(Div)]),
    Ok(0),
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
    Ok(0),
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
    Ok(128),
  )

  check.eq(
    calc_pilha([
      Numero(2),
      Numero(7),
      Numero(3),
      Operador(Mul),
      Numero(6),
      Operador(ParenteseDir),
      Operador(Soma),
    ]),
    Error(EntradaInvalida),
  )
}

//Empilha os valores numericos analisando a lista pos-fixa e quando acha um operador realiza a operação
//nos dois valores logo anteriores do operador.
pub fn empilha_calc(
  acumulador: Result(List(TipoValor), Erros),
  elem: TipoValor,
) -> Result(List(TipoValor), Erros) {
  use acc <- result.try(acumulador)
  case elem {
    Numero(valor) -> Ok(list.append(acc, [Numero(valor)]))
    Operador(simbolo) ->
      case acc {
        [primeiro, segundo, terceiro] -> {
          use desempilhado <- result.try(desempilha_calcula(
            segundo,
            terceiro,
            simbolo,
          ))
          Ok([primeiro, desempilhado])
        }
        [primeiro, segundo] -> {
          use desempilhado <- result.try(desempilha_calcula(
            primeiro,
            segundo,
            simbolo,
          ))
          Ok([desempilhado])
        }
        _ -> Error(EntradaInvalida)
      }
  }
}


// Faz o calculo baseado em dois valores e um operador.
pub fn desempilha_calcula(
  num1: TipoValor,
  num2: TipoValor,
  operador: TipoSimbolo,
) -> Result(TipoValor, Erros) {
  use numer1 <- result.try(get_valor(num1))
  use numer2 <- result.try(get_valor(num2))
  case operador {
    Soma -> Ok(Numero(numer1 + numer2))
    Sub -> Ok(Numero(numer1 - numer2))
    Mul -> Ok(Numero(numer1 * numer2))
    Div -> Ok(Numero(numer1 / numer2))
    _ -> Error(EntradaInvalida)
  }
}

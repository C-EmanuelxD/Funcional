//import gleam/float
import gleam/int
//import gleam/string
import sgleam/check

//Exercicio 6)

//Concatena uma lista de Strings e devolve strings
pub fn concat_lista(lst: List(String)) -> String {
  case lst {
    [] -> ""
    [primeiro, ..resto] -> {
      primeiro <> concat_lista(resto)
    }
  }
}

//Exercicio 7)

//Conta a quantidade de elementos de uma lista
pub fn qtd_elem(lst: List(Int)) -> Int {
  case lst{
    [] -> 0
    [_, ..resto] -> {
      1 + qtd_elem(resto)
    }
  }
}

//pub fn qtd_elem_examples(){
//  check.eq(qtd_elem([4, 8, 9, 7, 10]), 5)
//  check.eq(qtd_elem([4, 8, 9, 7]), 4)
//  check.eq(qtd_elem([]), 0)
//}

//Exercicio 8)

//Por meio da função int.parse, trasnforme uma lista de strings
//em uma lista de números

pub fn transforma_str_to_num(lst: List(String)) -> List(Int){
  case lst{
    [] -> []
    [primeiro, ..resto] -> {
      case int.parse(primeiro){
        Ok(a) -> [a, ..transforma_str_to_num(resto)]
        _ -> transforma_str_to_num(resto)
      }   
    }
  }
}

//pub fn transforma_str_to_num_examples(){
//  check.eq(transforma_str_to_num(["1", "4", "9"]), [1, 4, 9])
//  check.eq(transforma_str_to_num(["4","n","9"]), [4, 9])
//  check.eq(transforma_str_to_num([]),[])
//}

//Exercicio 9

//Retira as strings vazias de dentro de uma lista de strings
pub fn retira_vazia(lst: List(String)) -> List(String){
  case lst{
    [] -> []
    [primeiro, ..resto] -> {
      case primeiro{
        "" -> retira_vazia(resto)
        _ -> [primeiro, ..retira_vazia(resto)]
      }
    }
  }
}

pub fn retira_vazia_examples(){
  check.eq(retira_vazia(["Manue", "", "Jorge", "Couto"]),["Manue", "Jorge", "Couto"])
  check.eq(retira_vazia(["Manue", "", "Jorge", ""]),["Manue", "Jorge"])
  check.eq(retira_vazia(["", "", "", ""]),[])
  check.eq(retira_vazia([]),[])
}

//Exercicio 11

//Função que define o valor maior dentro de uma lista de valores inteiros

pub fn max(lst: List(Int)) -> Result(Int, Nil){
  case lst{
    [] -> Error(Nil)
    [primeiro, ..resto] -> {
      case max(resto){
        Error(Nil) -> Ok(primeiro)
        Ok(maxresto) -> Ok(int.max(primeiro, maxresto))
      }
    }
  }
}

//Exercicio 12

//Função que verifica se uma lisa de números não está em ordem decrescente.
//Portanto deve retornar false caso não decrescente e true caso contrario.

pub fn lista_decrescente(lst: List(Int)) -> Bool{
  case lst{
    [] -> True
    [_] -> True
    [primeiro, segundo, ..resto] -> {
      primeiro < segundo && lista_decrescente([segundo, ..resto])
    }
  }
}

pub fn lista_decrescente_examples(){
  check.eq(lista_decrescente([]), True)
  check.eq(lista_decrescente([1]), True)
  check.eq(lista_decrescente([1,2,3]), True)
  check.eq(lista_decrescente([2,1,3]), False)
  check.eq(lista_decrescente([3,2,1]), False)
}

//Exercicio 13

//Função que retorna uma lista dada em ordem contrária.

pub fn inverte_lista(lst: List(a)) -> List(a){
  case lst{
    [] -> []
    [primeiro, ..resto] -> {
      concatena_fim(primeiro, inverte_lista(resto)) //pega o primeiro e concatena no fim da inversão da lista do resto
    }
  }
}

pub fn concatena_fim(var: a, lst: List(a)) -> List(a){
  case lst{
    [] -> [var]
    [primeiro, ..resto] -> [primeiro, ..concatena_fim(var, resto)]
  }
}

//Exercicio 14

//Função que analisa uma lsita de associações e atualize a lista:
// - Se o valor de certa chave já existir em uma lista ele deve ser atualizado
// - Caso o valor não exista ele deve ser adicionado

pub type Assoc{
  Assoc(chave: String, valor: Int)
}

pub fn atualiza_lista(lst: List(Assoc), val: Assoc) -> List(Assoc){
  case lst{
    [] -> [val]
    [primeiro, ..resto] -> {
      case primeiro.chave == val.chave{
        True -> [Assoc(primeiro.chave, val.valor), ..resto]
        False -> [primeiro, ..atualiza_lista(resto, val)]
      }
    }
  }
}

pub fn atualiza_lista_examples(){
  check.eq(atualiza_lista([Assoc("Maria", 14), Assoc("Lara", 7), Assoc("Marta", 16)],Assoc("Maria", 17)), [Assoc("Maria", 17), Assoc("Lara", 7), Assoc("Marta", 16)])
  check.eq(atualiza_lista([Assoc("Maria", 14), Assoc("Lara", 7), Assoc("Marta", 16)], Assoc("Marcela", 17)), [Assoc("Maria", 14), Assoc("Lara", 7), Assoc("Marta", 16), Assoc("Marcela", 17)])
  check.eq(atualiza_lista([],Assoc("Maria", 17)), [Assoc("Maria", 17)])
}

//Exercicio 15

//Função recebe uma lista com nomes de sorvetes e devolve, de acordo com os nomes
//o ganho total em dinheiro. Cada sorvete possui um preço estipulado:
/// Manga: 6
/// Uva: 7
/// Morango: 8
/// De acordo com os nomes das listas, deve se calcular o seu valor total final.


const manga = 6
const uva = 7
const morango = 8

pub type Sabor{
  Manga
  Uva
  Morango
}


pub fn calcula_sorvete(lst: List(Sabor)) -> Int{
  case lst{
    [] -> 0
    [primeiro, ..resto] -> {
      let lucro = case primeiro{
        Manga -> 10 - manga
        Uva -> 10 - uva
        Morango -> 10 - morango
      }
      lucro + calcula_sorvete(resto)
    }
  }
} 

pub fn calcula_sorvete_examples(){
  check.eq(calcula_sorvete([Manga, Manga, Uva]), 11)
  check.eq(calcula_sorvete([]), 0)
  check.eq(calcula_sorvete([Morango]), 2)
}


//Exercicio 16

//Função que remove repetição e verifica se uma lista está em ordem crescente.
//A entrada será uma lista de valores repetidos e a saída deve conter aenas valores únicos.

pub fn remove_repeticao(lst: List(Int)) -> Result(List(Int), Nil){
  case lst{
    [] -> Ok([])
    [primeiro, ..resto] -> {
      case checa_repeticao(resto, primeiro){
        True -> remove_repeticao(resto)
        False -> {
          case remove_repeticao(resto){
            Ok(recur) -> Ok([primeiro, ..recur])
            Error(Nil) -> Error(Nil)
          }
          
        } 
      }
    }
  }
  
}

pub fn remove_repeticao_examples(){
  check.eq(remove_repeticao([3,3,7,7,7,10,10]), Ok([3,7,10]))
  check.eq(remove_repeticao([3,3,7,3,7,10,10]), Ok([3,7,10]))
  check.eq(remove_repeticao([]), Ok([]))
}

pub fn checa_repeticao(lst: List(Int), val: Int) -> Bool{
  case lst{
    [] -> False
    [primeiro, ..resto] -> {
      primeiro == val || checa_repeticao(resto, val)
    }
  }
}
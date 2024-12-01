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
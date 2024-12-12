import sgleam/check
//Exercicio 3

//Função que verifica se todos os elementos de uma lista estão presentes em outra lista.

pub fn verifica_contem_listas(lsta: List(a), lstb: List(a)) -> Bool{
  case lsta, lstb{
    [], [] -> True
    [], _ -> True
    _, [] -> False

    [plsta, ..rlsta], [plstb, ..rlstb] -> {
      plsta == plstb && verifica_contem_listas(rlsta, rlstb)
    }
  }
}

//Exercicio 4

//cria todos os possíveis pares entre os elementos de duas listas.

pub fn pares(lsta: List(a), lstb: List(a)) -> List(List(a)){
  case lsta{
    [] -> []
    [primeiro, ..resto] ->{
      concatena_lista(cria_pares(primeiro, lstb), pares(resto, lstb))
    }
  }
}

pub fn cria_pares(elem: a, lstb: List(a)) -> List(List(a)){
  case lstb{
    [] -> []
    [primeiro, ..resto] -> {
      [[elem, primeiro], ..cria_pares(elem, resto)]
    }
  }
}

pub fn concatena_lista(lsta: List(a), lstb: List(a)) -> List(a){
  case lsta{
    [] -> lstb
    [primeiro, ..resto] -> {
      [primeiro, ..concatena_lista(resto, lstb)]
    }


  }
}

//Exercicio 5

//Função que recebe uma lista de nomes e uma lista de booleanos, e devolve uma lsita
//Com o correspondente True de cada nome.

pub fn escolhe_nome(lsta: List(String), lstb: List(Bool)) -> Result(List(String), Nil){
  case lsta, lstb{
    [], [] -> Ok([])
    [primeiroa, ..restoa], [primeirob, ..restob] -> {
      case primeirob{
        True -> case escolhe_nome(restoa, restob){
          Ok(a) -> Ok([primeiroa, ..a])
          Error(a) -> Error(a)
        }
        False -> escolhe_nome(restoa, restob)
      }
    }
    _, [] -> Error(Nil)
    [], _ -> Error(Nil)
  }
}


pub fn escolhe_nome_examples(){
  check.eq(escolhe_nome(["Isabela","Vitor","Matheus","Fernando"], [True, False, False, True]), Ok(["Isabela", "Fernando"]))
  check.eq(escolhe_nome(["Isabela","Vitor","Matheus","Fernando"], [False, False, False, False]), Ok([]))
  check.eq(escolhe_nome([], []), Ok([]))
  check.eq(escolhe_nome(["Vitor", "Maicon"], [True]), Error(Nil))
  check.eq(escolhe_nome(["Vitor", "Maicon"], [True, False, True]), Error(Nil))
}


//Exercicio 6

//Compara se duas listas de numeros são iguais
pub fn compara_listas(lsta: List(Int), lstb: List(Int)) -> Bool{
  case lsta, lstb{
    [], [] -> True
    _, [] -> False
    [], _ -> False
    [primeiroa, ..restoa], [primeirob, ..restob] -> {
      primeiroa == primeirob && compara_listas(restoa, restob)
    } 
  }
}

pub fn compara_listas_examples(){
  check.eq(compara_listas([],[]),True)
  check.eq(compara_listas([1], [1,2]),False)
  check.eq(compara_listas([1,2],[1]),False)
  check.eq(compara_listas([1,2,3],[1,2,3]),True)
  check.eq(compara_listas([1,2,3],[]),False)
  check.eq(compara_listas([],[1,2,3]),False)
}

//Exercicio 7
//Função verifica se uma lista possui mmais elementos que a segunda lista.
//Retorna True caso possua e False caso não.

pub fn compara_tamanho(lsta: List(a), lstb: List(a)) -> Bool{
  case lsta, lstb{
    [], [] -> False
    _, [] -> True
    [], _ -> False
    [_, ..restoa], [_, ..restob] -> {
      False || compara_tamanho(restoa, restob)
    }
  }
}

//Exercicio 8

//Recebe uma lista e um n, retorna os n primeiros elementos da lista

pub fn n_elem_lista(lsta: List(a), elem: Int) -> Result(List(a), Nil){
  case lsta, elem{
    _, 0 -> Ok([])
    [], _ -> Error(Nil)
    [primeiro, ..resto], n -> {
      case n_elem_lista(resto, n-1){
        Ok(a) -> Ok([primeiro, ..a])
        Error(a) -> Error(a)
      }
    }
  }
}

pub fn n_elem_lista_examples(){
  check.eq(n_elem_lista([], 0), Ok([]))
  check.eq(n_elem_lista([], 2), Error(Nil))
  check.eq(n_elem_lista([1,2,3,4,5], 0), Ok([]))
  check.eq(n_elem_lista([1,2,3,4,5], 4), Ok([1,2,3,4]))
  check.eq(n_elem_lista([1,2,3,4,5], 7), Error(Nil))
  check.eq(n_elem_lista([1,2,3,4,5], 5), Ok([1,2,3,4,5]))
}

//Exercicio 9

//Função que devolve uma lista sem os n primeiros elementos
pub fn descarta(lsta: List(a), elem: Int) -> Result(List(a), Nil){
  case lsta, elem{
    [], _ if elem > 0 -> Error(Nil)
    _, 0 -> Ok(lsta)
    [], 0 -> Ok([])
    [], _ -> Error(Nil) 
    [_, ..resto], n -> {
      case descarta(resto, n-1){
        Ok(a) -> Ok(a)
        Error(a) -> Error(a)
      }
    }
  }
}

pub fn descarta_examples(){
  check.eq(descarta([], 2), Error(Nil))
  check.eq(descarta([1], 2), Error(Nil))
  check.eq(descarta([], 0), Ok([]))
  check.eq(descarta([1,2,3,4], 0), Ok([1,2,3,4]))
  check.eq(descarta([1,2,3,4,5,6], 3), Ok([4,5,6]))
  check.eq(descarta([1,2,3,4,5,6], 6), Ok([]))
}
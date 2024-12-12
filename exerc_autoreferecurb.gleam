import sgleam/check
import gleam/string
import gleam/int

//Exercicio 8

//Função que, de acordo com a entrada de 
//uma lista de strings, gere a média
//do tamanho das strings

pub fn media_tam(lst: List(String)) -> Float {
  int.to_float(total_tam_string(lst))/.tam_lista(lst)
}

pub fn total_tam_string(lst: List(String)) -> Int{
  case lst{
    [] -> 0
    [primeiro, ..resto] -> {
      string.length(primeiro)+total_tam_string(resto)
    }
  }
}

pub fn tam_lista(lst: List(String)) -> Float{
  case lst{
    [] -> 0.0
    [_, ..resto] -> {
      1.0+.tam_lista(resto)
    }
  }
}

pub fn media_tam_examples(){
  check.eq(media_tam(["gggg", "gggg"]), 4.0)
  //check.eq(media_tam(["gg", "ggg", "gg"]), 2.3)
  check.eq(media_tam([]), 0.0)
  check.eq(media_tam(["gg"]),2.0)
}


//Exercicio 9

//Função que verifica se dentro de uma lista dada existem mais
//valores positivios do que negativos. Os valores são todos inteiros

pub type MaisTpParidade{
  Positivo
  Negativo
  Igual
}

pub fn mais_neg_pos(lst: List(Int)) -> MaisTpParidade{
  case qtd_negativo(lst), qtd_positivo(lst){
    a, b if a > b -> Negativo
    a, b if b > a -> Positivo
    a, b if a == b -> Igual
    _, _ -> Igual
  }
}

pub fn mais_neg_pos_examples(){
  check.eq(mais_neg_pos([]), Igual)
  check.eq(mais_neg_pos([-1,-2,1,5]), Igual)
  check.eq(mais_neg_pos([-1,-9,1]), Negativo)
  check.eq(mais_neg_pos([-1,-9, 1, 4, 5]), Positivo)
}

pub fn qtd_negativo(lst: List(Int)) -> Int{
  case lst{
    [] -> 0
    [primeiro, ..resto] -> {
      case primeiro < 0{
        True -> 1 + qtd_negativo(resto)
        False -> qtd_negativo(resto)
      }
    }
  }
}

pub fn qtd_positivo(lst: List(Int)) -> Int{
  case lst{
    [] -> 0
    [primeiro, ..resto] -> {
      case primeiro >= 0{
        True -> 1 + qtd_positivo(resto)
        False -> qtd_positivo(resto)
      }
    }
  }
}

// Exercicio 10

//Função que recebe dois valores, o valor e a quantidade de repetições que o valor
//deve possuir na lista de saída.

pub fn repete_n(n: Int, v: Int) -> List(Int){
  case n{
    _ if n < 0 -> [] 
    0 -> []
    _ -> [v, ..repete_n({n-1}, v)]
  }
}

pub fn repete_n_examples(){
  check.eq(repete_n(1,4), [4])
  check.eq(repete_n(5,1), [1,1,1,1,1])
  check.eq(repete_n(0,1), [])
}

//Exercicio 11

//Função recebe dois valores a e b, e faz a elevado a b

pub opaque type Natural{
  Natural(num: Int)
}

pub fn new_natural(a: Int) -> Result(Natural, Nil){
  case a < 0{
    True -> Error(Nil)
    False -> Ok(Natural(a))
  }
}

pub fn get_num(nume: Natural){
  nume.num
}


pub fn potencia(num: Int, pot: Int) -> Result(Int, Nil){
  case pot{
    _ if pot < 0 -> Error(Nil)
    0 -> Ok(1)
    _ -> case potencia(num, pot-1){
      Ok(recur) -> Ok(num*recur)
      Error(Nil) -> Error(Nil)
    }
  }
}


//Exercicio 14

//Função que conta quantos nós tem uma árvore binária de grau dois.
//Isto é, possui dois filhos

pub type Arvore{
  Vazia
  No(valor: Int, esq: Arvore, dir: Arvore)
}

pub fn conta_grau_dois(arv: Arvore) -> Int{
  case arv{
    Vazia -> 0
    No(valor, esq, dir) -> {
      case esq != Vazia && dir != Vazia{
        True -> 1+conta_grau_dois(esq)+conta_grau_dois(dir)
        False -> conta_grau_dois(esq)+conta_grau_dois(dir)
      }
    }
  }
}

pub fn conta_grau_dois_examples(){
  check.eq(conta_grau_dois(No(1, Vazia, Vazia)), 0)
  check.eq(conta_grau_dois(No(1,No(2, No(3, Vazia, Vazia), No(3, Vazia, Vazia)), No(4, Vazia, Vazia))), 2)
  check.eq(conta_grau_dois(Vazia), 0)
  check.eq(conta_grau_dois(No(3,
                              No(4,
                                  No(3, Vazia, Vazia),
                                                  Vazia),
                                                            No(7,
                                                                  No(8, Vazia, Vazia),
                                                                                      No(9,
                                                                                              No(10, Vazia, Vazia),
                                                                                                                    Vazia)))), 2)
}

//Exercicio 15

//Função que diz se a árvore é cheia ou não, isto é, todos os seus
//nós possuem grau 2

pub fn verifica_cheia(arv: Arvore) -> Bool{
  case arv{
    Vazia -> False
    No(_, Vazia, Vazia) -> True
    No(valor, esq, dir) ->{
      {esq != Vazia || dir != Vazia} && verifica_cheia(esq) && verifica_cheia(dir)
    }

  }
}

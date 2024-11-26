import gleam/string

//Exercicio 12
pub fn area_retangulo(base: Float, altura: Float) -> Float {
  base *. altura
}

//Exercicio 13
pub fn produto_anterior_posterior(n: Int) -> Int {
  n*{n+1}*{n-1}
}

//Exercicio 14
pub fn so_primeira_maiuscula(nome: String) -> String{
  string.uppercase(string.slice(nome, 0, 1)) <> string.lowercase(string.slice(nome, 1, string.length(nome)))

}
//Exercicio 15
pub fn eh_par(n: Int) -> Bool{
  {n % 2} == 0
}

//Exercicio 16
pub fn tem_tres_digitos(num: Int) -> Bool{
  num < 1000 && num > 99
}

//Exercicio 17
pub fn maximo(x: Int, y: Int) -> Int{
  case x > y{
    True -> x
    False -> y
  }
}

//Exercicio 18
pub fn ordem(a: Int, b: Int, c: Int) -> String{
  case {a > b} && {b > c} {
    True -> "Decrescente"
    False -> case {a < b} && {b < c}{
      True -> "Crescente"
      _ -> "Sem Ordem"
    }
  }
}
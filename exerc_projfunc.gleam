///// Transforma a string *data* que está no formato "dia/mes/ano"

import gleam/int
import gleam/string
import sgleam/check
import gleam/float

//Exercicio 13

/// Produz True se uma pessoa com *idade* é isento da
/// tarifa de transporte público, isto é, tem menos
/// que 18 anos ou 65 ou mais. Produz False caso contrário.
pub fn isento_tarifa(idade: Int) -> Bool {
  idade < 18 || idade >= 65
}

//pub fn isento_tarifa_examples() {
//  check.eq(isento_tarifa(17), True)
//  check.eq(isento_tarifa(18), True)
//  check.eq(isento_tarifa(50), False)
//  check.eq(isento_tarifa(65), True)
//  check.eq(isento_tarifa(70), True)
//}

//Exercicio 14
/// Conta a quantidade de dígitos de *n*.
/// Se *n* é 0, então devolve um.
/// Se *n* é menor que zero, então devolve a quantidade
/// de dígitos do valor absoluto de *n*
pub fn quantidade_digitos(n: Int) -> Int {
  string.length(int.to_string(int.absolute_value(n)))
}

//pub fn quantidade_digitos_examples() {
//  check.eq(quantidade_digitos(123), 3)
//  check.eq(quantidade_digitos(0), 1)
//  check.eq(quantidade_digitos(-1519), 4)
//}

//Exercicio 15
/// Produz True se uma pessoa com a *idade* é supercentenária,
/// isto é, tem 110 anos ou mais, False caso contrário.
pub fn supercentenario(idade: Int) -> Bool {
  idade >= 110
}

//pub fn supercentenario_examples() {
//  check.eq(supercentenario(101), False)
//  check.eq(supercentenario(110), True)
//  check.eq(supercentenario(112), True)
//}

//Exercicio 16
/// para o formato "ano/mes/dia".
///
/// Requer que o dia e o mês tenham dois dígitos e que
/// o ano tenha quatro dígitos, ou seja DMA --> AMD
pub fn dma_para_amd(data: String) -> String {
  string.slice(data, 6, 4)
  <> "/"
  <> string.slice(data, 3, 2)
  <> "/"
  <> string.slice(data, 0, 2)
}

//pub fn dma_para_amd_examples() {
//  check.eq(dma_para_amd("19/07/2023"), "2023/07/19")
//  check.eq(dma_para_amd("01/01/1980"), "1980/01/01")
//  check.eq(dma_para_amd("02/02/2002"), "2002/02/20")
//}

//Exercicio 17
//Recebe um valor e uma porcentagem e faz a soma do
//valor + porcentagem
pub fn aumenta(valor: Float, porcentagem: Float) -> Float {
  valor *. { 1.0 +. porcentagem /. 100.0 }
}

//Exercicio 18
//Recebe uma dada String e retorna o seu tamanho
//Se a String for menor ou 4 retorna curto
//Se a String for maior que 4 e menor ou 10 retorna médio
//Qualquer valor acima disso retorna longo
//pub fn tamanho_nome(nome: String) -> Int {
  //case string.length(nome) <= 4 {
    //True -> "curto"
    //False ->
      //case string.length(nome) <= 10 {
        //True -> "médio"
        //False -> "longo"
      //}
  //}
//}


//Exercicio 19

//Recebe uma dada String que: Se a String não finalizar com o número *1*
//é adicionado um ponto final ao fim da dada String
//Caso finalize com 1 retorna a própria String.

pub fn ponto_final_um(frase: String) -> String{
  case string.slice(frase, -1, 1){
    "1" -> frase
    _ -> frase <> "."
  }
}

//pub fn ponto_final_um_examples(){
//  check.eq(ponto_final_um("Carlos Emanuel1"), "Carlos Emanuel1")
//  check.eq(ponto_final_um("Carlos1 E1anue11"), "Carlos1 E1anue11")
//  check.eq(ponto_final_um("Flores são belas"), "Flores são belas.")
//  check.eq(ponto_final_um("Rosas1 são vermelhas"), "Rosas1 são vermelhas.")
//  check.eq(ponto_final_um("Rosas1 são vermelhas 11"), "Rosas1 são vermelhas 11")
//}


//Exercicio 20

///Determina se determinada string impar tem traço no meio e retorna True
///caso for par retorna False

pub fn traco_meio(n: String) -> Bool{
  {string.length(n) % 2 == 1} && string.slice(n, {string.length(n) / 2}, 1) == "-"
}


//pub fn traco_meio_examples(){
//  check.eq(traco_meio("lero-lero"), True)
//  check.eq(traco_meio("quero-quero"), True)
//  check.eq(traco_meio("amanha-"), False)
//  check.eq(traco_meio("-amanha"), False)
//  check.eq(traco_meio(""), False)
//  check.eq(traco_meio("sayonara"), False)
//}


//Exercicio 21
//Encontra o numero maior entre tres numeros dados e o retorna

pub fn maximo(x: Int, y: Int, z: Int) -> Int{

  case x > y && x > z{
    True -> x
    False -> 
      case y > z && y > x{
        True -> y
        _ -> z
      }

  } 

}


//pub fn maximo_examples(){
//  check.eq(maximo(8, 5, 2), 8)
//  check.eq(maximo(4, 6, 1), 6)
//  check.eq(maximo(6, 6, 7), 7)
//}


///Exercicio 22
///Recebe uma *String* e um *Numero*, troca as *Numero* primeiras letras da
/// *String* pelas letras x. Retorna a String com os x's substituidos.
///  - o Numero deve ser inteiro e não negativo
pub fn coloca_n_x(frase: String, n: Int) -> String{
  string.repeat("x", int.min(string.length(frase), n)) <> string.drop_left(frase, n)
}

//pub fn coloca_n_x_examples(){
//  check.eq(coloca_n_x("Massa", 3), "xxxsa")
//  check.eq(coloca_n_x("Mecanico doggers", 9), "xxxxxxxxxdoggers")
//  check.eq(coloca_n_x("éan", 7), "xxx")
//  check.eq(coloca_n_x("é isso ai né mano", -5), "é isso ai né mano")
//}

//Exercicio 23
///Verifica se o texto possui espaçoes extras no inicio e no fim se uma *string*
///Se possuir, retorna False
///Se não possuir retorna apenas True

pub fn elimina_espacos(frase: String) -> Bool{
  case string.first(frase), string.last(frase){
    Ok(" "), _ -> True
    _ , Ok(" ") -> True
    _, _ -> False
  }
}

//pub fn elimina_espacos_examples(){

//  check.eq(elimina_espacos(" Eu sou um programador"), True)
//  check.eq(elimina_espacos("  Eu sou o maior genio da historia "), True)
//  check.eq(elimina_espacos("Wasteland where nothing can grow "), True)
//  check.eq(elimina_espacos("Eu sou um bobo"), False)

//}

//Exercicio 24
///Recebe o *dinheiro* e calcula o imposto que um cidadao paga sobre tal.
/// Cidadãos que recebem 1000 ou menos pagam 5% do imposto.
/// Cidadãos que recebem 5000 ou menos pagam 5% sobre os 1000 mais 10% do valor acima de 1000 de imposto.
/// Cidadãos que recebem um valor maior que 5000 pagam 5% sobre 1000 mais 10% sobre 4000 e 20% sobre o que passar de 5000.
/// 
/// dinheiro é um float com duas casas decimais não-negativo.
/// imposto é um float com duas casas decimais não-negativo.
/// 
/// Portanto:
/// *dinheiro* <= 1000 paga 5% do valor
/// 1000 < *dinheiro* <= 5000 paga 5% de 1000 + 10% do valor que passa de 1000
/// 5000 < *dinheiro* paga 5% de 1000 + 10% de 4000 + 20% do que passar do valor de 5000.
pub fn calc_imposto(dinheiro: Float) -> Float {
  case dinheiro <=. 1000.0{
    True -> {dinheiro *. 5.0/.100.0}
    False -> case dinheiro <=. 5000.0{
      True -> {1000.0*.{5.0/.100.0} +. {dinheiro-.1000.0}*.{10.0/.100.0}}
      False -> {50.0+.400.0+.{dinheiro-.5000.0}*.20.0/.100.0}
    }
  }
}

//pub fn calc_imposto_examples(){
  //check.eq(calc_imposto(580.0), 29.0)
  //check.eq(calc_imposto(4980.0), 448.0)
  //check.eq(calc_imposto(9800.0), 1410.0)
//}

//Exercicio 25

///Verifica se a palavra é duplicada contendo hífen ou não.
/// retorna True se duplicada
/// retorna False se não duplicada
/// Verifica se a palavra tem tamanho par ou ímpar, se possuir tamanho par
/// não contém hifen se for ímpar contém hífen.
pub fn duplicada(palavra: String) -> Bool{
  let metade = string.length(palavra) / 2
  case string.length(palavra) % 2 == 0{
    True -> string.drop_left(palavra, metade) == string.drop_right(palavra, metade)
    False -> case string.slice(palavra, metade, 1) == "-"{
      True -> string.drop_left(palavra, metade+1) == string.drop_right(palavra, metade+1) 
      False -> False
    }
  }
}
//pub fn duplicada_examples(){
//  check.eq(duplicada("lero-lero"), True)
//  check.eq(duplicada("xixi"), True)
//  check.eq(duplicada("nada a ver"), False)
//  check.eq(duplicada("ab-ba"), False)
//}

//Exercicio 26

///Recebe uma *comprimento* e uma *altura* em metros para saber quantos azuleijos são necessário na construção de acordo com o tamanho (20cm)
/// O comprimento e altura deve ser um valor flutuante não negativo representado em metros
/// Se calcula a *altura / 0.2* x *comprimento/0.2* para saber o tamanho total do local, e esse valor é dividido
/// por 0.2, recebendo a quantia final de azuleijos necessários.
pub fn azuleijos(comprimento: Float, altura: Float) -> Int{
  float.truncate(float.ceiling(comprimento/.0.2)*.float.ceiling(altura/.0.2))
}


import gleam/int
import gleam/string
import sgleam/check

//Exercicio 10
pub type Direcao {
  Norte
  Sul
  Leste
  Oeste
}

//a)
pub fn oposta(dir: Direcao) -> Direcao {
  case dir {
    Norte -> Sul
    Sul -> Norte
    Oeste -> Leste
    Leste -> Oeste
  }
}

//b)
pub fn nov_graus(dir: Direcao) -> Direcao {
  case dir {
    Norte -> Oeste
    Sul -> Leste
    Oeste -> Norte
    Leste -> Sul
  }
}

//Exercicio 11
pub type Estado {
  Parado
  Subindo
  Descendo
}

//a)

//Dependendo do *andar atual* e do *andar solicitado*, mostrar qual *Estado* o elevador
//deve estar de acordo com a solicitação

pub fn solic(andar_atual: Int, andar_futuro: Int) -> Estado {
  case andar_atual == andar_futuro {
    True -> Parado
    False ->
      case andar_atual > andar_futuro {
        True -> Descendo
        False -> Subindo
      }
  }
}

//pub fn solic_examples() {
//  check.eq(solic(0, 4), Subindo)
//  check.eq(solic(4, 1), Descendo)
//  check.eq(solic(5, 5), Parado)
//}

//b)....

//Exercicio 12
pub type Data {
  Date(dia: String, mes: String, ano: String)
}

//a)
//Função que transforma uma dada *String* na estrutura *Data*
pub fn dma_to_data(data_str: String) -> Data {
  Date(
    string.slice(data_str, 0, 2),
    string.slice(data_str, 3, 2),
    string.slice(data_str, 6, 4)
  )
}

//pub fn solic_examples() {
//  check.eq(dma_to_data("04/07/2024"), Date("04","07","2024"))
//  check.eq(dma_to_data("27/11/2024"), Date("27","11","2024"))
//  check.eq(dma_to_data("06/12/2024"), Date("06","12","2024"))
//}

//b)

//Função verifica se uma dada data é o ultimo dia do ano
//Ela verifica o campo *dia* e *mes*, e verifica se coincide com 31 e 12, o *ano* pode ser qualquer e retorna True para ultimo dia e False para não é o ultimo dia
pub fn verifica_ult_dia(data: Data) -> Bool {
  data.dia == "31" && data.mes == "12"
}

//pub fn verifica_ult_dia_examples(){
//  let data1 = Date(dia: "04", mes:"08", ano:"2024")
//  let data2 = Date(dia:"31", mes:"12", ano:"2023")
//  let data3 = Date(dia:"25", mes:"12", ano:"2023")
//  let data4 = Date(dia:"31", mes:"06", ano:"2023")

//  check.eq(verifica_ult_dia(data1), False)
//  check.eq(verifica_ult_dia(data2), True)
//  check.eq(verifica_ult_dia(data3), False)
//  check.eq(verifica_ult_dia(data4), False)

//}

//c)

//Função verifica se uma data *data1* vem antes de uma *data2* e indica verdadeiro ou falso
//Verifica se *dia*, *mes* e *ano* da data 1 são mmaiores que data 2. Se sim retorna False, se não retorna True
//se as datas forem iguais retorna False.

///Transforma-se a entrada para inteiro e checa em ordem se os anos são iguais, após isso meses, após isso dias.
///Para cada caso se teste se é igual, se não forem iguais, se testa qual o maior.
pub fn vem_antes(datax: Data, datay: Data) -> Bool {
  case int.parse(datax.ano), int.parse(datay.ano){ //Teste Ok(ano) para saber se ano está consistente
    Ok(anox), Ok(anoy) -> case anox == anoy{ 
      True -> case int.parse(datax.mes), int.parse(datay.mes){//Teste Ok(mes) para saber se mes está consistente
        Ok(mesx), Ok(mesy) -> case mesx == mesy{ 
          True -> case int.parse(datax.dia), int.parse(datay.dia){//Teste de dia, para saber se dia está consistente
            Ok(diax), Ok(diay) -> case diax == diay{ 
              True -> False
              False -> diax > diay
            }
            _, _ -> False
          }
          False -> mesx > mesy
        }
        _, _ -> False
      }
      False -> anox > anoy
    }
    _, _ -> False
  }
}

//pub fn vem_antes_examples(){
//    let data11 = Date(dia:"07",mes:"05",ano:"2023")
//    let data12 = Date(dia:"04",mes:"02",ano:"2023")
//    let data31 = Date(dia:"07",mes:"05",ano:"2023")

//    check.eq(vem_antes(data11, data12), True)
//    check.eq(vem_antes(data12,data11), False
      //check.eq(vem_antes(data31,data31), False)
//}

//d) DESAFIO

pub type DateCur{
  DataAct(dia: Int, mes: Int, ano: Int)
} 

///Função verifica se um ano é bissexto, vale ressaltar que em anos bissextos fevereiro
///tem 29 dias, e que o ano é bissexto apenas se for multiplo de 4 ou 400, e não de 100.
/// A função retorna a própria data apenas se o ano estiver corretamente escrito e portanto
/// deve se seguir as regras de: se fevereiro E bissexto, deve ter 29 dias. Leva-se em consideração
/// que em anos não bissextos os meses todos possuem 31 dias.

pub fn verifica_data(data: DateCur) -> Bool{
  let dia = data.dia
  let mes = data.mes
  let ano = data.ano
  
  case {ano % 4 == 0 || ano % 400 == 0} && ano % 100 != 0{
    True -> case mes == 01{
      True -> dia <= 29
      False -> dia <= 31
    }
    False -> dia <= 31 && mes <= 12
  } 

}

//pub fn verifica_data_examples(){
//  let data1 = DataAct(31, 01, 2004) //False
//  let data2 = DataAct(29, 01, 2004) //True
//  let data3 = DataAct(31, 01, 2005) //True
//  let data4 = DataAct(08, 09, 2021) //True

//  check.eq(verifica_data(data1), False)
//  check.eq(verifica_data(data2), True)
//  check.eq(verifica_data(data3), True)
//  check.eq(verifica_data(data4), True)

//}


//Exercicio 13
//pub opaque type Resolucao{
//  Resolucao(largura: Float, altura: Float)
//}

//pub fn new(resolu: Resolucao) -> Result(Resolucao, Nil){
//   case resolu.largura >=. 0.0 && resolu.altura >=. 0.0{
//    True -> Ok(resolu)
//    False -> Error(Nil)
//  }
//}


///a)

//Determina quantos megapixels uma imagem tem dados os dados de *largura* e *altura*
//os megapixels podem ser calculados multiplicando *altura* x *largura* e dividindo
//por 1 milhão.

//largura e altura devem ser não-negativos, e pontos flutuantes

//A função deve dividir o produto de largura x altura por 1 milhão e o resultado será 
//os dados megapixels da imagem

//pub fn megapixels(resol: Resolucao) -> Float{
//  case new(resol){
//    Ok(resol) -> {resol.largura*.resol.altura}/.1000000.0
//    _ -> 0.0
//  }

//}



//pub fn megapixels_examples(){
//  let reso1 = Resolucao(4.8,5.9)
//  let reso2 = Resolucao(5000.0,7000.0)
//  let reso3 = Resolucao(1.0,1.0)
//  let reso4 = Resolucao(-1.0,1.0)

//  check.eq(megapixels(reso1), 0.00002832)
//  check.eq(megapixels(reso2), 35.0)
//  check.eq(megapixels(reso3), 0.000001)
//  check.eq(megapixels(reso4), 0.0)
//}


//b)

//Função que retorna o *aspecto* da resolução da tela dadas entradas de *resolução*,
//vale dizer que a resolução é dada quando os valores de pixels são iguais, ou seja
//se uma largura x 16 == altura x 9, a resolução é 16:9, assim acontece com 4:3 ou outro.

pub type Resolucao{
  Resolucao(largura: Float, altura: Float)
}


pub type Aspecto{
  QuatroPorTres
  DezesseisPorNove
  Outro
}

pub fn calc_aspecto(resol: Resolucao) -> Aspecto{
  case resol.largura/.16.0 == resol.altura/.9.0{
    True -> DezesseisPorNove
    False -> case resol.largura/.4.0 == resol.altura/.3.0{
      True -> QuatroPorTres
      False -> Outro
    }
  }
}

//pub fn calc_aspecto_examples(){
//  let resol1 = Resolucao(1920.0, 1080.0)
//  let resol2 = Resolucao(640.0, 480.0)
//  let resol3 = Resolucao(685465.0, 987498.0)

//  check.eq(calc_aspecto(resol1), DezesseisPorNove)
//  check.eq(calc_aspecto(resol2), QuatroPorTres)
//  check.eq(calc_aspecto(resol3), Outro)
//}

//c)

//Funcção que verifica se uma tela *x* cabe em uma tela *y* sem necessidade de rotação
// ou mudança de tamanho

//Isso é feito comparando a largura e altura especifica de ambas

pub fn verifica_tela(x: Resolucao, y: Resolucao){
  x.largura >. y.largura && x.altura >. y.altura
}

//pub fn verifica_tela_examples(){
//  check.eq(verifica_tela(Resolucao(1920.0, 1080.0), Resolucao(600.0, 400.0)), True)
//  check.eq(verifica_tela(Resolucao(600.0, 400.0), Resolucao(1920.0, 1080.0)), False)
//}


//Exercicio 14

pub type Forma{
  Retangulo(largura: Float, altura: Float)
  Circulo(raio: Float)
}

//a)

//Função que calcula a área da figura determinada. retangulo é dada por *largura* x *altura*
// circulo é dada por 3.14 x raio^2

pub fn calc_area(forma: Forma) -> Float{
  case forma{
    Retangulo(largura, altura) -> largura*.altura
    Circulo(raio) -> 3.14*.{raio*.raio}
  }
}


//pub fn calc_area_examples(){
//  check.eq(calc_area(Retangulo(14.0,15.0)), 210.0)
//  check.eq(calc_area(Circulo(7.0)), 153.86)
//}


//Exercicio 15

//Verifica o *estado* de um aluno de acordo com a média de 4 notas dadas.
//Os estados podem ser: Aprovado (nota maior ou igual a 7), Reprovado (nota menor que 4)
//, Exame(maior ou igual a 4 e menor que 7).

pub type Estadoav{
  Aprovado
  Reprovado
  Exame
}

//A função verifica qual a média das 4 avaliações e ger como resultado o estado do aluno comparando
//com os valores pré definidos.
//Todas as notas devem ser pontos flutuantes não negativos.

pub fn avalia_estado(x: Float,y: Float,z: Float,w: Float) -> Estadoav{
  let media = {x+.y+.z+.w}/.4.0

  case media >=. 7.0{
    True -> Aprovado
    False -> case media <. 4.0{
      True -> Reprovado
      False -> Exame
    }
  }
}

//pub fn avalia_estado_examples(){
//  check.eq(avalia_estado(4.0, 8.0, 7.0, 9.0), Aprovado)
//  check.eq(avalia_estado(6.0, 5.0, 2.0, 1.0), Reprovado)
//  check.eq(avalia_estado(4.0, 5.0, 6.0, 4.0), Exame)
//}

//Exercicio 16

pub type Bandeira{
  Verde
  Amarela
  VermelhaUm
  VermelhaDois
}

//Mostra o valor a ser pago de energia com base na *bandeira tarifária*, *consumo em kWh* e a *tarifa básica do kWh*.
//Levando em cosnideração que a bandeira *Verde* não paga tarifa, *Amarela* sofre acréscimo de R$0.01874 no kWh,
//*Vermelha-1* sofre acréscimo de R$0.03971 no kWh e *Vermelha-2* sofre acréscimo de R$0.09492 no kWh.

//A tarifa básica paga é calculada multiplicando o consumo pela tarifa, então deve se verificar a cor da bandeira
//para entender a tarifa a ser paga, dependendo da cor da bandeira, o consumo deve ser multiplicado à taxa da bandeira
//e somado à tarifa básica.

pub fn calcula_gasto(band: Bandeira, consumo: Float, tarifa: Float) -> Float{
  let tarifa_basica = consumo*.tarifa
  case band{
    Verde -> tarifa_basica
    Amarela -> tarifa_basica+.{0.01874*.consumo}
    VermelhaUm -> tarifa_basica+.{0.03971*.consumo}
    VermelhaDois -> tarifa_basica+.{0.09492*.consumo}
  }
}

//pub fn calcula_gasto_examples(){
//  check.eq(calcula_gasto(Verde, 5.0, 0.600), 3.0)
//  check.eq(calcula_gasto(Amarela, 7.0, 0.600), 4.33118)
//  check.eq(calcula_gasto(VermelhaUm, 2.0, 0.600), 1.27942)
//  check.eq(calcula_gasto(VermelhaDois, 9.0, 0.600), 6.25428)
//}

//Exercicio 17

pub type Jokenpo{
  Pedra
  Papel
  Tesoura
}

pub type Estadojogo{
  JogadorUm
  JogadorDois
  Empate
}

//Função verifica quem ganhou o jogo Jokenpo com base nas escolhas de
//simbolos que podem ser pedra, papel ou tesoura. As opções de vitoria podem ser:
//Tesoura -> Papel, Papel -> Pedra, Pedra -> Tesoura. Se ambos os simbolos
//forem iguais o jogo é empatado, possuindo 3 estados: Vitoria jogador 1,
//Vitoria jogador2, Empate.

pub fn jokenpo(j1: Jokenpo, j2: Jokenpo) -> Estadojogo{
  case j1, j2{
    j1, j2 if j1 == j2 -> Empate
    Tesoura, Papel -> JogadorUm
    Papel, Pedra -> JogadorUm
    Pedra, Tesoura -> JogadorUm
    _, _ -> JogadorDois
  }
}

//pub fn jokenpo_examples(){
//  check.eq(jokenpo(Pedra, Papel), JogadorDois)
//  check.eq(jokenpo(Tesoura, Papel), JogadorUm)
//  check.eq(jokenpo(Pedra, Pedra), Empate)
//}

//Exercicio 18

//Recebe o resultado de um *jogo*, com *gols* e dois times em questão e devolve:
//o desempenho do primeiro time, se o *saldo* foi positivo o desempenho foi bom
//se o saldo for negativo o desempenho foi Ruim e se aconteceu empate recebe None.
//A função retorna o saldo de gols e os pontos somados.
//vale lembrar que o saldo de gols é a diferença entre gols entre os dois times.

pub type DesempenhoFinal{
  DesempenhoFinal(pontos: Int, saldo_gols: Int, vencedor: String)
}

pub type Jogo{
  Jogo(t1: String, gol1: Int, t2: String, gol2: Int)
}


pub fn desempenho(jogo: Jogo) -> DesempenhoFinal{
  case jogo.gol1 > jogo.gol2{
    True -> DesempenhoFinal(3, {jogo.gol1 - jogo.gol2}, jogo.t1)
    False -> case jogo.gol1 < jogo.gol2{
      True -> DesempenhoFinal(0, {jogo.gol1 - jogo.gol2}, jogo.t2)
      False -> DesempenhoFinal(1, 0, "Empate")
    }
  }
}



//pub fn desempenho_examples(){
//  check.eq(desempenho(Jogo("Flamengo", 3, "Fluminense", 0)), DesempenhoFinal(3, 3, "Flamengo"))
//  check.eq(desempenho(Jogo("Palmeiras", 1, "Botafogo", 3)), DesempenhoFinal(0, -2, "Botafogo"))
//  check.eq(desempenho(Jogo("Santos", 1, "São-Paulo", 1)), DesempenhoFinal(1, 0, "Empate"))
//}

//Exercicio 19


//a)

//Função transforma uma quantidade de *segundos* em *horas*, *minutos* e *segundos*.
//Levando em consideração que se dividirmos os segundos por 60 obtemos os minutos e dividindo
//os minutos obtemos as horas, a função deve retornar as três informações.

pub type Tempo{
  Tempo(horas: Int, minutos: Int, segundos: Int)
}




pub fn segundos_para_hms(segundos: Int) -> Tempo{
  Tempo({segundos/3600}, {{segundos%3600}/60}, {segundos%3600}%60)
}

//b)

//Função exibe a quantidade de *horas*, *minutos* e *segundos*, em forma de string
//não se deve considerar tempos que são 0. Eles não devem ser exibidos. Caso seja
//0 Horas minutos e segundos se retorna string vazia.

pub fn hms_to_string(tempo: Tempo) -> String{
    case tempo.horas, tempo.minutos, tempo.segundos{
      h, m, s if h == 0 && m == 0 && s == 0 -> ""
      h, m, s if h != 0 && m != 0 && s != 0 -> "horas: " <> string.inspect(h) <> " minutos: " <> string.inspect(m) <> " segundos: " <> string.inspect(s)
      h, m, s if h == 0 && m != 0 && s != 0 -> "minutos: " <> string.inspect(tempo.minutos) <> " segundos: " <> string.inspect(tempo.segundos)
      h, m, s if h != 0 && m == 0 && s != 0 -> "horas: " <> string.inspect(tempo.horas) <> " segundos: " <> string.inspect(tempo.segundos)
      h, m, s if h != 0 && m != 0 && s == 0 -> "horas: " <> string.inspect(tempo.horas) <> " minutos: " <> string.inspect(tempo.minutos)
      _, _, _ -> "horas: " <> string.inspect(tempo.horas) <> " minutos: " <> string.inspect(tempo.minutos) <> " segundos: " <> string.inspect(tempo.segundos)
    }
}


//pub fn hms_to_string_examples(){
//  check.eq(hms_to_string(Tempo(4, 2, 0)), "horas: 4 minutos: 2")
//  check.eq(hms_to_string(Tempo(4, 2, 1)), "horas: 4 minutos: 2 segundos: 1")
//  check.eq(hms_to_string(Tempo(0, 2, 0)), "minutos: 2")
//  check.eq(hms_to_string(Tempo(1, 0, 0)), "horas: 1")
//  check.eq(hms_to_string(Tempo(0, 0, 1)), "minutos: 1")
//  check.eq(hms_to_string(Tempo(0, 0, 0)), "")
//}

//Exercicio 20
 pub type Personagem{ //Tem q fazer construtor, para manter inteiros limitados?
  Personagem(direcao: Direcaoxadrez, linha: Int, coluna: Int)
 }

 pub type Direcaoxadrez{
  Nortex
  Sulx
  Lestex
  Oestex
 }
//Verifca quanto quadrados faltam até o final do tabuleiro baseado nas linhas/colunas
//e na direção do personagem
 pub fn xadrez(persona: Personagem) -> Int{
  case persona.direcao{
    Nortex -> 10 - persona.linha
    Sulx -> persona.linha
    Lestex -> 10 - persona.coluna
    Oestex -> persona.coluna
  }
 }

//pub fn xadrez_examples(){
//  check.eq(xadrez(Personagem(Nortex, 9, 5)), 1)
//  check.eq(xadrez(Personagem(Oestex, 5, 8)), 8)
//  check.eq(xadrez(Personagem(Lestex, 4, 4)), 6)
//  check.eq(xadrez(Personagem(Sulx, 7, 8)), 7)
//}

//Exercicio 22



pub type Posicao{
  Posicao(x: Int, y: Int, direcao: Direcaoa)
}

pub type Direcaoa{
  Nortea
  Sula
  Lestea
  Oestea
}

pub type Lado {
  Direita
  Esquerda
}

pub type Movimento{
  Andar(qtd: Int)
  Virar(lado: Lado)
  }


//Função que dada a *posição* de um personagem diz a *nova posição* na qual
//ele se encontra. A função possui um tipo posição que dita em qual posição do tabuleiro
//a peça se encontra assim como seu lado. De acordo com os comandos essa posição e lado
//devem mudar. A entrada da função deve ser um tipo posição e uma quantidade de casas.

pub fn xadrez_posicao(pos: Posicao, mov: Movimento) -> Posicao{
  case pos.direcao, mov{
    Nortea, Andar(qtd) -> Posicao(pos.x, pos.y+qtd, Nortea)
    Sula, Andar(qtd) -> Posicao(pos.x, pos.y-qtd, Sula)
    Lestea, Andar(qtd) -> Posicao(pos.x+qtd, pos.y, Lestea)
    Oestea, Andar(qtd) -> Posicao(pos.x-qtd, pos.y, Oestea)
    Nortea, Virar(lado) if lado == Direita -> Posicao(pos.x, pos.y, Lestea)
    Nortea, Virar(lado) if lado == Esquerda -> Posicao(pos.x, pos.y, Oestea)
    Sula, Virar(lado) if lado == Direita -> Posicao(pos.x, pos.y, Oestea)
    Sula, Virar(lado) if lado == Esquerda -> Posicao(pos.x, pos.y, Lestea)
    Lestea, Virar(lado) if lado == Direita -> Posicao(pos.x, pos.y, Sula)
    Lestea, Virar(lado) if lado == Esquerda -> Posicao(pos.x, pos.y, Nortea)
    Oestea, Virar(lado) if lado == Direita -> Posicao(pos.x, pos.y, Nortea)
    Oestea, Virar(lado) if lado == Esquerda -> Posicao(pos.x, pos.y, Sula)
    _, _ -> Posicao(pos.x, pos.y, pos.direcao)
  }
}


pub fn xadrez_posicao_examples(){
  check.eq(xadrez_posicao(Posicao(1, 1, Nortea), Andar(5)), Posicao(1,6,Nortea))
  check.eq(xadrez_posicao(Posicao(1, 5, Nortea), Virar(Direita)), Posicao(1,5,Lestea))
  check.eq(xadrez_posicao(Posicao(7, 5, Sula), Andar(2)), Posicao(7,3,Sula))
}


//Exercicio 23

pub type FormaPagamento{
  PixDinheiro
  Boleto
  CartaoParcela(vezes: Int)
}

//Função recebe uma forma de pagamento e o valor de compra e produz
//o valor final da compra com base nos descontos ou taxas da forma de pagamento em questão.
//A função recebe como entrada uma *FormaPagamento* e um *valor de compra* (Float),
//de acordo com a forma de pagamento calcula um valor especifico para cada uma:
/// - Pix/Dinheiro = 10% de desconto
/// - Boleto = 8% de desconto
/// - No cartao: para 3 < parcelas <= 12 possui acréscimo no valor de 12%.
/// Caso existam parcelas menores ou iguais a 3, não possui desconto.
/// Não são permitidas parcelas maiores do que 12.

pub fn calcula_valor(forma: FormaPagamento, valor: Float) -> Float{
  case forma{
    PixDinheiro -> valor -. {valor*.0.10}
    Boleto -> valor -. {valor*.0.08}
    CartaoParcela(vezes) if 3 < vezes -> valor +. {valor*.0.12}
    CartaoParcela(_) -> valor
  }
}


pub fn calcula_valor_examples(){
  check.eq(calcula_valor(PixDinheiro, 15.00), 13.5)
  check.eq(calcula_valor(Boleto, 27.00), 24.84)
  check.eq(calcula_valor(CartaoParcela(5), 30.00), 33.6)
  check.eq(calcula_valor(CartaoParcela(1), 30.00), 30.00)
}
import gleam/float
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
    string.slice(data_str, 6, 4),
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
//se as datas forem iguais retorna False
pub fn vem_antes(datax: Data, datay: Data) -> Bool {
  let diax = int.parse(datax.dia)
  let mesx = int.parse(datax.mes)
  let anox = int.parse(datax.ano)
  let diay = int.parse(datax.dia)
  let mesy = int.parse(datax.mes)
  let anoy = int.parse(datax.ano)
  case anox == anoy{
    True -> case mesx == mesy{
        True -> diax > diay
        False -> mesx > mesy
    }
    False -> anox > anoy
  }
}

pub fn vem_antes_examples(){
    let data11 = Date(dia:"07",mes:"05",ano:"2023")
    let data12 = Date(dia:"04",mes:"02",ano:"2023")
    let data31 = Date(dia:"07",mes:"05",ano:"2023")
    let data32 = Date(dia:"07",mes:"05",ano:"2023")

    check.eq(vem_antes(data11, data12), True)
    check.eq(vem_antes(data12,data11), False)
    check.eq(vem_antes(data31,data31), False)

}

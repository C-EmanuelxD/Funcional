import sgleam/check

//Exercicio 22

//Função que dadas posição e direção na qual um personagem está em um tabuleiro
//Executa um movimento de rotação, para a direita ou para a esquerda. Ou
//Executa um movimento de andar n casas para a direção em questão.

/// O tabuleiro possui linhas e colunas de 1 a 10, portanto, 
/// não se pode mover para valores menores que 1 ou maiores que 10.
/// Portanto dada a posição do tabuleiro, a função calcula a soma
/// do valor ou subtração do valor para o movimento em cada direção.
/// Caso um movimento não seja permitido, ou seja ultrapasse o intervalo
/// 1 >= x >= 10 a função deve retornar um Erro de movimento não permitido

pub type Posicao {
  Posicao(x: Int, y: Int, direcao: Direcao)
}

pub type Direcao {
  Norte
  Sul
  Leste
  Oeste
}

pub type Lado {
  Direita
  Esquerda
}

pub type Movimento {
  Andar(n: Int)
  Virar(lado: Lado)
}

pub type Erros {
  MovimentoImpossivel
  Outro
}

pub fn xadrez_posicao(pos: Posicao, mov: Movimento) -> Result(Posicao, Erros) {
  case pos, mov {
    _, Andar(n) if n > 10 -> Error(MovimentoImpossivel)
    pos, Andar(n) -> {
      let result_norte = pos.y + n
      let result_sul = pos.y - n
      let result_leste = pos.x + n
      let result_oeste = pos.x - n
      case pos.direcao {
        Norte ->
          case result_norte > 10 {
            True -> Error(MovimentoImpossivel)
            False -> Ok(Posicao(pos.x, result_norte, pos.direcao))
          }
        Sul ->
          case result_sul < 1 {
            True -> Error(MovimentoImpossivel)
            False -> Ok(Posicao(pos.x, result_sul, pos.direcao))
          }
        Leste ->
          case result_leste > 10 {
            True -> Error(MovimentoImpossivel)
            False -> Ok(Posicao(result_leste, pos.y, pos.direcao))
          }
        Oeste ->
          case result_oeste < 1 {
            True -> Error(MovimentoImpossivel)
            False -> Ok(Posicao(result_oeste, pos.y, pos.direcao))
          }
      }
    }
    pos, Virar(dir) -> {
      case pos.direcao, dir {
        Norte, Direita -> Ok(Posicao(pos.x, pos.y, Leste))
        Norte, Esquerda -> Ok(Posicao(pos.x, pos.y, Oeste))
        Sul, Direita -> Ok(Posicao(pos.x, pos.y, Oeste))
        Sul, Esquerda -> Ok(Posicao(pos.x, pos.y, Leste))
        Leste, Direita -> Ok(Posicao(pos.x, pos.y, Sul))
        Leste, Esquerda -> Ok(Posicao(pos.x, pos.y, Norte))
        Oeste, Direita -> Ok(Posicao(pos.x, pos.y, Norte))
        Oeste, Esquerda -> Ok(Posicao(pos.x, pos.y, Sul))
      }
    }
  }
}

pub fn xadrez_posicao_examples() {
  check.eq(
    xadrez_posicao(Posicao(1, 1, Norte), Andar(4)),
    Ok(Posicao(1, 5, Norte)),
  )
  check.eq(
    xadrez_posicao(Posicao(1, 1, Oeste), Andar(4)),
    Error(MovimentoImpossivel),
  )
  check.eq(
    xadrez_posicao(Posicao(1, 10, Norte), Andar(8)),
    Error(MovimentoImpossivel),
  )
  check.eq(
    xadrez_posicao(Posicao(1, 7, Sul), Andar(8)),
    Error(MovimentoImpossivel),
  )
  check.eq(xadrez_posicao(Posicao(1, 7, Sul), Andar(5)), Ok(Posicao(1, 2, Sul)))
  check.eq(
    xadrez_posicao(Posicao(1, 7, Sul), Virar(Direita)),
    Ok(Posicao(1, 7, Oeste)),
  )
  check.eq(
    xadrez_posicao(Posicao(1, 7, Norte), Virar(Direita)),
    Ok(Posicao(1, 7, Leste)),
  )

  check.eq(
    xadrez_posicao(Posicao(6, 7, Oeste), Andar(5)),
    Ok(Posicao(1, 7, Oeste)),
  )
  check.eq(
    xadrez_posicao(Posicao(1, 10, Sul), Andar(9)),
    Ok(Posicao(1, 1, Sul)),
  )
  check.eq(
    xadrez_posicao(Posicao(1, 7, Leste), Andar(7)),
    Ok(Posicao(8, 7, Leste)),
  )
}

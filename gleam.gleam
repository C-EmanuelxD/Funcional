case True {
  desem.pontos > primeiro.pontos -> [desem, primeiro, ..resto]
  desem.pontos == primeiro.pontos and desem.vitorias > primeiro.vitorias -> [desem, primeiro, ..resto]
  desem.pontos == primeiro.pontos and desem.vitorias == primeiro.vitorias and desem.saldo_gol > primeiro.saldo_gol -> [desem, primeiro, ..resto]
  desem.pontos == primeiro.pontos and desem.vitorias == primeiro.vitorias and desem.saldo_gol == primeiro.saldo_gol -> 
    case string.compare(desem.time, primeiro.time) {
      order.Lt -> [desem, primeiro, ..resto]
      order.Eq -> [primeiro, ..inserir_lista(resto, desem)]
      order.Gt -> [primeiro, ..inserir_lista(resto, desem)]
    }
  _ -> [primeiro, ..inserir_lista(resto, desem)]
}

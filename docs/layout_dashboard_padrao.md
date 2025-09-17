# Layout do Dashboard Power BI – Ranking de Clientes


🔹 Página 1 – Visão Geral do Ranking

**Objetivo**: visão executiva dos clientes mais relevantes.

- KPIs em Cards (topo do dashboard)

  - Total de Clientes Ativos

  - Receita Total do Período

  - Lucro Total do Período

  - % Clientes AAA+ + AAA

  - Ticket Médio

- Gráfico de Barras Horizontal

  - Top 10 clientes por Score_Final

  - Eixo X: Score Final (ou Receita)

  - Eixo Y: Clientes

- Tabela Detalhada (com filtros interativos)

  - Cliente | Classificação | Score_Final | Total_Vendas | Total_Lucro | MVA | Freq_Pedidos | Última Compra

- Filtro de Segmentação (Slicers)

  - Período (Ano, Mês, Trimestre)

  - Região / Cidade

  - Ramo de Atividade

  - Vendedor

🔹 Página 2 – Análise Temporal

**Objetivo**: avaliar evolução e sazonalidade.

- Linha do Tempo (Line Chart)

  - Evolução de Vendas e Lucro por mês

  - Linha adicional para Crescimento %

- Heatmap (Calendário de Vendas)

  - Eixo X: Mês

  - Eixo Y: Semana

  - Cor: Receita ou Quantidade de Pedidos

- Comparativo de Temporadas (Clustered Column)

  - Vendas Alta Temporada vs Baixa Temporada

  - Segmentação por Cliente ou Grupo (AAA, AA etc.)

🔹 Página 3 – Perfil de Cliente

**Objetivo**: detalhar comportamento de um cliente específico.

- Seleção de Cliente (Dropdown ou Click na Tabela)

- Resumo em Cards

  - Score Final

  - Classificação (AAA+, AAA, …)

  - Última Compra (dias)

  - Diversidade de Produtos

  - Ticket Médio

- Gráfico de Radar (Spider Chart)

  - Eixos: Vendas, Lucro, MVA, Margem %, Frequência, Recência, Estabilidade, Diversidade

  - Mostra forças e fraquezas do cliente

- Tabela de Produtos Comprados

  - Produto | Quantidade | Receita | Margem %

🔹 Página 4 – Análise Estratégica

**Objetivo**: apoiar decisões comerciais.

- Mapa Geográfico (Filled Map)

  - Localização de clientes

  - Cor por classificação (AAA+, AAA, …)

  - Tamanho da bolha por Receita

- Matriz Crescimento x Rentabilidade

  - Eixo X: Crescimento Semestral (%)

  - Eixo Y: Margem %

  - Bolha: Cliente (tamanho proporcional à Receita)

  - Classificação em quadrantes: “Estrelas”, “Potenciais”, “Risco”, “Manter”

- Alertas Automáticos (Card / Condicional)

  - Clientes AAA que caíram de volume nos últimos 3 meses

  - Clientes de alta recência (última compra muito distante)

🎯 Benefícios do Layout

- Executivos → visão rápida dos clientes mais relevantes.

- Comercial → identificação de oportunidades (crescimento, diversificação, fidelização).

- Logística → clientes eficientes x clientes com alto custo por peso.

- Financeiro → previsibilidade via estabilidade e sazonalidade.
# Fluxo de Ranking de Clientes – Versão 0.0.3

+-------------------+
|   Fonte de Dados  |
|   (ERP / PCPEDI)  |
+-------------------+
          |
          v
+-------------------+
| Pré-processamento |
| - Filtro período  |
| - Parametrização  |
+-------------------+
          |
          v
+-----------------------------+
| Cálculo de Métricas por     |
| Cliente (SQL - ClienteMetrics) |
| - Vendas totais             |
| - Lucro total               |
| - Peso bruto                |
| - Margem % média            |
| - Eficiência / kg           |
| - MVA (Valor/Peso)          |
| - Frequência de pedidos     |
| - Diversidade produtos/cat. |
| - Recência (última compra)  |
| - Sazonalidade              |
| - Estabilidade (desvio)     |
+-----------------------------+
          |
          v
+-----------------------------+
| Normalização via Quartis    |
| (NTILE, PERCENT_RANK)       |
| - Vendas_Score              |
| - Lucro_Score               |
| - Margem_Score              |
| - MVA_Score_Rank            |
| - Frequencia_Score          |
| - Recencia_Score            |
| - Estabilidade_Score        |
| - Diversidade_Score         |
+-----------------------------+
          |
          v
+-----------------------------+
| Score Ponderado (SQL)       |
| Pesos:                      |
| - Vendas (20%)              |
| - Lucro (20%)               |
| - MVA (15%)                 |
| - Margem % (10%)            |
| - Frequência (10%)          |
| - Recência (10%)            |
| - Estabilidade (5%)         |
| - Eficiência/kg (5%)        |
| - Diversidade (5%)          |
+-----------------------------+
          |
          v
+-----------------------------+
| Classificação Final         |
| - AAA+ (Top 10%)            |
| - AAA (Top 20%)             |
| - AA (Top 40%)              |
| - A (Médio Alto)            |
| - B (Médio)                 |
| - C (Desenvolvimento)       |
+-----------------------------+
          |
          v
+-----------------------------+
| Saída SQL / View            |
| - Score final por cliente   |
| - Indicadores detalhados    |
+-----------------------------+
          |
          v
+-----------------------------+
| Camada de Apresentação      |
| (Power BI / Dashboard)      |
| - Ranking interativo        |
| - Filtros por período       |
| - Análise temporal          |
| - Comparativo sazonal       |
| - Drill-down por vendedor   |
| - Alertas clientes críticos |
+-----------------------------+

🔎 Observações

O SQL (v0.0.3) funciona como camada de preparação → gera uma view ou tabela materializada.

O Power BI conecta-se diretamente a essa view, possibilitando:

Filtragem dinâmica por ano/mês/período

Visualização do ranking em tempo real

Análise temporal (tendências, sazonalidade)

Segmentação por região, ramo, vendedor

O pipeline é modular: pode ser expandido para novos indicadores sem quebrar a lógica atual.
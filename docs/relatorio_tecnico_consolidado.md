# Sistema de Ranking Global de Clientes – Relatório Técnico Consolidado

**Versão 0.0.3 - Ajustada ao Modelo de Pontuação por Faixas**

-----

**Autor:** Marcelo G Facioli  
**Data de Criação:** 12/09/2025  
**Última Atualização:** 20/10/2025 (Revisão Técnica)  
**Status:** Implementado com metodologia de **Pontuação Ponderada por Faixas Fixas**

-----

## Índice

1.  [Resumo Executivo](#1-resumo-executivo)
2.  [Motivação e Objetivos](#2-motivação-e-objetivos)
3.  [Evolução do Modelo](#3-evolução-do-modelo)
4.  [Metodologia de Pontuação](#4-metodologia-de-pontuação)
5.  [Fluxo de Processamento](#5-fluxo-de-processamento)
6.  [Implementação Técnica](#6-implementação-técnica)
7.  [Dashboards e Visualização](#7-dashboards-e-visualização)
8.  [Resultados e Benefícios](#8-resultados-e-benefícios)
9.  [Conclusões e Próximos Passos](#9-conclusões-e-próximos-passos)

-----

## 1\. Resumo Executivo

O Sistema de Ranking Global de Clientes é uma solução analítica que consolida múltiplas métricas de performance em um score único e objetivo para classificação de clientes. O sistema utiliza um modelo de **Pontuação Ponderada por Faixas Fixas**, que classifica os clientes com base em seu desempenho em métricas-chave e pesos predefinidos.

### Principais Características:

  - **Foco no Cliente**: Consolidação de todas as métricas por cliente
  - **Metodologia de Pontuação**: Uso de faixas de valor predefinidas para atribuir pontos
  - **Pesos Manuais**: Atribuição de pesos fixos para cada KPI (Vendas, Peso Líquido, Lucro, Mix)
  - **Métricas Chave**: 4 dimensões de análise com pontuações dedicadas
  - **Pipeline Automatizado**: Processamento SQL otimizado
  - **Classificação Granular**: 6 níveis hierárquicos ( (VIP), A, B, C, D, E )

### Impacto Esperado:

  - **Priorização Objetiva** de clientes para ações comerciais
  - **Identificação de Oportunidades** de crescimento e fidelização
  - **Otimização de Recursos** comerciais e logísticos
  - **Rastreamento** da distribuição de clientes nas faixas de pontuação

-----

## 2\. Motivação e Objetivos

### 2.1 Contexto do Problema

O desafio tradicional de classificação de clientes baseada apenas em volume de vendas apresenta limitações significativas:

  - **Distorção por Volume**: Grandes compradores com baixa margem recebem classificação inadequada
  - **Ignorar Eficiência**: Clientes com alto valor por kg são sub-avaliados
  - **Falta de Perspectiva Temporal**: Ausência de análise de frequência e recência (A ser adicionado em versões futuras)
  - **Visão Unidimensional**: Não considera diversidade de produtos ou lucratividade

### 2.2 Objetivos Estratégicos

1.  **Criar um Ranking Holístico**: Que considere volume, rentabilidade, eficiência e mix de produtos
2.  **Automatizar o Processo**: Pipeline SQL robusto com atualização dinâmica
3.  **Fundamentação em Pesos Ponderados**: Uso de pesos manuais e faixas fixas para pontuação
4.  **Flexibilidade Operacional**: Sistema modular e expansível
5.  **Integração com BI**: Dashboards interativos para análise executiva

-----

## 3\. Evolução do Modelo

### 3.1 Histórico de Versões

| Versão | Foco Principal | Limitações | Melhorias Implementadas |
|--------|---------------|------------|-------------------------|
| **0.0.1** | Transações individuais | Granularidade excessiva, pesos fixos | Base conceitual |
| **0.0.2** | Consolidação por cliente | Pesos subjetivos, métricas limitadas | Foco no cliente, introdução MVA |
| **0.0.3** | **Pontuação por Faixas Fixas** | Pesos manuais, falta de métricas temporais | **Pontuação por Faixas, Contagem de Clientes por Faixa, Classificação Ajustada** |

### 3.2 Principais Mudanças na Versão 0.0.3

#### ✅ **Inclusões Estratégicas:**

1.  **Modelo de Pontuação por Faixa**: Definição de tabelas fixas (`pontuacao_*`) para mapear performance em pontos.
2.  **Contagem de Clientes por Faixa**: Geração de contadores dinâmicos (Script 3) para visualização da distribuição de clientes.
3.  **Métricas Chave**: Inclusão de **Total de Vendas**, **Peso Líquido**, **Lucro Total** e **Mix de Produtos**.
4.  **Cálculo de Frequência**: Adição da métrica `freq_pedidos` (Contagem de dias/clientes distintos).
5.  **Classificação Simplificada**: Uso de 6 categorias hierárquicas (VIP, A, B, C, D, E) com base no score final.

#### ❌ **Remoções Justificadas:**

  - **Metodologia PCA**: Removida. O cálculo de pesos é agora manual.
  - **Métricas Temporais Avançadas**: Recência, Sazonalidade e Estabilidade não estão implementadas.

-----

## 4\. Metodologia de Pontuação

### 4.1 Fundamentação Técnica - Pontuação por Faixas

A pontuação é calculada através de uma **abordagem ponderada** onde o cliente recebe uma nota para cada KPI com base em faixas de valor predefinidas. Os pesos são definidos manualmente e armazenados na tabela `pesos_ranking`.

#### 4.1.1 Formulação Matemática

O Score Final é a soma ponderada das pontuações de cada KPI:

$$Score_{Final} = \sum_{k=1}^4 (Pontos_{KPI_k} \times Peso_{KPI_k})$$

Onde:

  * $KPI_k$ é uma das métricas (Vendas, Peso Líquido, Lucro Total, Mix de Produtos).
  * $Pontos_{KPI_k}$ é a pontuação atribuída pela tabela `pontuacao_*` correspondente.
  * $Peso_{KPI_k}$ é o peso manual definido na tabela `pesos_ranking`.

#### 4.1.2 Tabela de Pesos Atuais (`pesos_ranking`)

| KPI Nome | Peso | Descrição |
| :--- | :--- | :--- |
| `vendas` | **0.30** | Peso para Total de Vendas |
| `peso_liquido` | **0.20** | Peso para Total Peso Líquido |
| `lucro_total` | **0.30** | Peso para Lucro Total |
| `mix_produtos` | **0.20** | Peso para Mix de Produtos |

*(Soma total dos pesos: 1.00)*

### 4.2 Métricas do Modelo

O modelo atual considera 4 métricas principais para pontuação e diversas métricas derivadas para análise.

#### 4.2.1 Métricas de Pontuação (KPIs)

1.  **Total de Vendas** (`SUM(VLRVENDA)`)
      - Representa o volume financeiro.
2.  **Total Peso Líquido** (`SUM(TOTLIQ)`)
      - Eficiência logística (peso vendido).
3.  **Lucro Total** (`SUM("lucro total (R$)")`)
      - Contribuição absoluta para rentabilidade.
4.  **Mix de Produtos** (`COUNT(DISTINCT CODPROD)`)
      - Diversidade do relacionamento e potencial de cross-selling.

#### 4.2.2 Métricas Derivadas (Apenas para Análise no Dashboard)

1.  **MVA (Valor por Venda)**: (VLRVENDA / TOTBRUTONF)
2.  **Margem Percentual**: (Lucro / Vendas) \* 100
3.  **Frequência de Pedidos**: Contagem de pedidos distintos por cliente/dia.
4.  **Peso por Entrega**: (Total Peso Líquido / Frequência de Pedidos)
5.  **Lucro por Entrega**: (Lucro Total / Frequência de Pedidos)

### 4.3 Sistema de Classificação

O Score Final (soma ponderada) é mapeado em **6 níveis hierárquicos** de cliente:

| Categoria | Score Mínimo | Descrição |
| :--- | :--- | :--- |
| **(VIP)** | ≥ 21 | Clientes de performance excelente |
| **A** | ≥ 18 | Clientes Preferenciais |
| **B** | ≥ 12 | Clientes com Bom Potencial |
| **C** | ≥ 7 | Relacionamento Sólido / Manutenção |
| **D** | ≥ 3 | Oportunidade / Qualificação |
| **E** | \< 3 | Desenvolvimento / Prospecção |

-----

## 5\. Fluxo de Processamento

### 5.1 Arquitetura do Pipeline

```mermaid
graph TD
    A[Fonte de Dados<br/>ERP / PCPEDI] --> B[Script 1: Criação de Tabelas<br/>Pesos e Pontuações Fixas]
    B --> C[Script 2: Cálculo de Métricas<br/>Consolidação por Cliente (CTE ClienteMetrics)]
    C --> D[Script 2: Pontuação<br/>Mapeamento de Pontos por Faixa (CTE ClientesPontuados)]
    D --> E[Script 2: Score Ponderado e Categoria<br/>Tabela ranking_temp]
    E --> F[Script 3: Atualização de Contadores<br/>qtd_clientes nas tabelas de pontuação]
    F --> G[Script 4: View/Tabela Final<br/>Tabela teste_por_faixas (Ranking Consolidado)]
    G --> H[Power BI / Dashboard<br/>Visualização Interativa]
```

### 5.2 Detalhamento das Etapas

#### 5.2.1 Pré-processamento e Filtros

  - **Filtros aplicados**: `CODFILIAL = 1`, `POSICAO = 'F'`, `CONDVENDA = 1`, `CONSIDERAR = 'SIM'`.
  - **Exclusão de Funcionários**: `CODUSUR NOT IN (3)`.
  - **Agrupamento**: A consolidação é feita por `periodo` (mês/ano) e `codcli`.

#### 5.2.2 Consolidação e Cálculo de Pontos (SCRIPT 2)

1.  **`CTE ClienteMetrics`**: Agrega as métricas por cliente/período, calculando Vendas, Peso Líquido, Lucro, Mix, MVA, Margem e Frequência.
2.  **`CTE ClientesPontuados`**: Utiliza `COALESCE` e subconsultas para buscar os `pontos` correspondentes a cada métrica dentro das faixas definidas (e define o ponto mínimo como 1 caso não encontre).
3.  **`SELECT Final`**: Calcula a `pontuacao_total` (soma ponderada) e define a `Categoria_Cliente`.

#### 5.2.3 Atualização de Contadores (SCRIPT 3)

  - As tabelas de pontuação são atualizadas para registrar a quantidade de clientes (`qtd_clientes`) que caíram em cada faixa de valor. Isso permite a visualização da distribuição de clientes no dashboard.

-----

## 6\. Implementação Técnica

### 6.1 Componentes do Sistema

#### 6.1.1 Scripts SQL Principais

Os scripts são projetados para execução sequencial:

1.  **SCRIPT 1**: Cria e popula as tabelas de pesos (`pesos_ranking`) e faixas de pontuação (`pontuacao_*`).
2.  **SCRIPT 2**: Cria a tabela temporária `ranking_temp` com todas as métricas, pontos e o score final.
3.  **SCRIPT 3**: Atualiza os campos `qtd_clientes` nas tabelas de pontuação com base nos dados de `ranking_temp`.
4.  **SCRIPT 4**: Cria a tabela final `teste_por_faixas` com o ranking formatado, incluindo `pos_global`, `pos_vendedor` e o `percentil_posicao`.

#### 6.1.2 Definição de Lucro

O cálculo do lucro é protegido contra valores negativos de custo, garantindo que o lucro mínimo considerado seja zero:

```sql
ROUND(SUM(
    CASE WHEN "custo total" > VLRVENDA THEN 0 ELSE "lucro total (R$)" END
), 2) AS lucro_total
```

### 6.2 Estrutura de Dados

#### 6.2.1 Tabela de Pesos (`pesos_ranking`)

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `kpi_nome` | TEXT | Nome da métrica (ex: 'vendas') |
| `peso` | DECIMAL(3,2) | Peso manual (ex: 0.30) |

#### 6.2.2 Tabelas de Pontuação (`pontuacao_*`)

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `faixa_min` | DECIMAL/INT | Valor mínimo da faixa |
| `faixa_max` | DECIMAL/INT | Valor máximo da faixa |
| `pontos` | INT | Pontuação atribuída à faixa |
| `qtd_clientes` | INT | **(Atualizado pelo Script 3)** Quantidade de clientes na faixa |

-----

## 9\. Conclusões e Próximos Passos

### 9.1 Conquistas da Versão 0.0.3

1.  ✅ **Metodologia Clara**: Implementação bem-sucedida do modelo de Pontuação Ponderada por Faixas Fixas.
2.  ✅ **Pipeline Automatizado**: Processamento SQL otimizado e reproduzível.
3.  ✅ **Métricas Robustas**: Cobertura de volume, rentabilidade e eficiência (Mix de Produtos e Peso Líquido).
4.  ✅ **Sistema Modular**: Tabelas separadas para pesos e faixas, facilitando a manutenção e ajustes de pontuação.
5.  ✅ **Rastreabilidade**: Adição do contador de clientes por faixa.

### 9.2 Roadmap Futuro

#### 9.3.1 Versão 0.0.4 (Curto Prazo)

  - **Métricas Temporais Essenciais**:
      - Implementação completa de **Recência** (Dias desde a última compra).
      - Adição do cálculo de **Estabilidade** (Coeficiente de Variação) das vendas.
  - **Flexibilidade de Faixas**:
      - Criação de um processo (Python ou SQL) para recalcular automaticamente as faixas de pontuação usando quartis ou NTILEs.

#### 9.3.2 Versão 1.0.0 (Médio Prazo)

  - **Metodologia PCA**:
      - Reintrodução da metodologia PCA para cálculo estatístico dos pesos.
      - Implementação de um script Python para gerar os pesos e atualizar a tabela `pesos_ranking`.
  - **Machine Learning Avançado**:
      - Algoritmos de clustering para segmentação automática de clientes.

-----

**Documento controlado - Versão 0.0.3 - Ajustada ao Modelo de Pontuação por Faixas**
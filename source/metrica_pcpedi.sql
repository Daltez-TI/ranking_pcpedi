-- Modelo de Ranking por CLIENTE/REDE - Versão Adaptada
-- Foco: Agrupar por (CODREDE, NOME_REDE) quando houver rede
--       Caso contrário, agrupar por (CODCLI, CLIENTE)

CREATE TABLE teste5 AS
WITH ClienteMetrics AS (
    -- Etapa 1: Agregação das métricas por CLIENTE ou REDE
    SELECT
        CASE
            WHEN CODREDE <> 0 AND NOME_REDE IS NOT NULL THEN CODREDE
            ELSE CODCLI
        END AS Agrupa_Cod,
        
        CASE
            WHEN CODREDE <> 0 AND NOME_REDE IS NOT NULL THEN NOME_REDE
            ELSE CLIENTE
        END AS Agrupa_Nome,

        -- Métricas consolidadas
        SUM(VLRVENDA) AS Total_Vendas,
        SUM("lucro total (R$)") AS Total_Lucro,
        SUM(TOTBRUTONF) AS Total_Peso_Bruto,

        -- Métricas derivadas
        ((SUM("VLRVENDA") - SUM("custo total")) / SUM("VLRVENDA")) * 100 AS Avg_Margem_Percentual,
        (SUM("lucro total (R$)") / SUM("TOTLIQ")) AS Avg_Eficiencia_Por_Kg,

        -- Novo indicador MVA (Valor de Venda por Peso Bruto)
        CASE 
            WHEN SUM(TOTBRUTONF) > 0 THEN SUM(VLRVENDA) / SUM(TOTBRUTONF)
            ELSE 0 
        END AS MVA_Score,

        -- Frequência de pedidos
        COUNT(DISTINCT NUMPED) AS Freq_Pedidos,
        COUNT(DISTINCT CODPROD) AS Diversidade_Produtos,
        COUNT(DISTINCT CODCLI) AS Lojas,

        -- Referências
        MAX(CODREDE) AS CODREDE,
        MAX(CODGRUPO) AS CODGRUPO
    FROM pcpedi
    WHERE
        CODFILIAL = 1
        AND POSICAO = 'F'
        AND CONDVENDA = 1
    GROUP BY 
        CASE
            WHEN CODREDE <> 0 AND NOME_REDE IS NOT NULL THEN CODREDE
            ELSE CODCLI
        END,
        CASE
            WHEN CODREDE <> 0 AND NOME_REDE IS NOT NULL THEN NOME_REDE
            ELSE CLIENTE
        END
),

RankedClientes AS (
    -- Etapa 2: Cálculo dos scores por percentil (quartis)
    SELECT *,
        NTILE(4) OVER (ORDER BY Total_Vendas) AS Vendas_Score,
        NTILE(4) OVER (ORDER BY Total_Lucro) AS Lucro_Score,
        NTILE(4) OVER (ORDER BY MVA_Score) AS MVA_Score_Rank,
        NTILE(4) OVER (ORDER BY Avg_Margem_Percentual) AS Margem_Score,
        NTILE(4) OVER (ORDER BY Freq_Pedidos) AS Frequencia_Score,
        NTILE(4) OVER (ORDER BY Avg_Eficiencia_Por_Kg) AS Eficiencia_Score,
        NTILE(4) OVER (ORDER BY Diversidade_Produtos) AS Diversidade_Score
    FROM ClienteMetrics
),

ScoredClientes AS (
    -- Etapa 3: Cálculo da pontuação ponderada (normalizada)
    SELECT *,
        (
         Vendas_Score       * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Vendas_Score') +  
         Lucro_Score        * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Lucro_Score') +              
         Margem_Score       * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Margem_Score') +           
         MVA_Score_Rank     * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'MVA_Score_Rank') +         
         Frequencia_Score   * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Frequencia_Score') +       
         Eficiencia_Score   * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Eficiencia_Score') +        
         Diversidade_Score  * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Diversidade_Score')       
        ) 
        / (SELECT SUM(peso) FROM pesos_ranking_pca) AS TotalScore_Ponderado,
        
        -- Percentil para classificação final (também normalizado)
        PERCENT_RANK() OVER (
            ORDER BY (
                Vendas_Score       * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Vendas_Score') +
                Lucro_Score        * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Lucro_Score') + 
                Margem_Score       * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Margem_Score') + 
                MVA_Score_Rank     * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'MVA_Score_Rank') + 
                Frequencia_Score   * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Frequencia_Score') + 
                Eficiencia_Score   * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Eficiencia_Score') +
                Diversidade_Score  * (SELECT peso FROM pesos_ranking_pca WHERE metrica = 'Diversidade_Score')
            ) / (SELECT SUM(peso) FROM pesos_ranking_pca)
        ) AS Percentil
    FROM RankedClientes
)

-- Etapa 4: Resultado final com ranking e análise detalhada
SELECT
    CASE
        WHEN CODREDE <> 0 AND Agrupa_Nome IS NOT NULL
            THEN 'Rede ' || CAST(Agrupa_Cod AS TEXT) || ' - ' || Agrupa_Nome
        ELSE 'Cliente ' || CAST(Agrupa_Cod AS TEXT) || ' - ' || Agrupa_Nome
    END AS CLIENTE,
    Lojas,
    CODREDE,
    CODGRUPO,

    -- Métricas consolidadas
    ROUND(Total_Vendas, 2) AS Total_Vendas,
    ROUND(Total_Lucro, 2) AS Total_Lucro,
    ROUND(MVA_Score, 2) AS MVA_Valor_Por_Peso,
    ROUND(Avg_Margem_Percentual, 2) AS Media_Margem_Perc,
    Freq_Pedidos,
    Diversidade_Produtos,

    -- Scores individuais
    Vendas_Score,
    Lucro_Score, 
    MVA_Score_Rank,
    Margem_Score,
    Frequencia_Score,
    Eficiencia_Score,
    Diversidade_Score,

    -- Pontuação final
    ROUND(TotalScore_Ponderado, 2) AS Score_Final,
    
    -- Classificação por faixas
    CASE
        WHEN Percentil >= 0.90 THEN 'AAA+ (Top 10%)'
        WHEN Percentil >= 0.80 THEN 'AAA (Top 20%)'
        WHEN Percentil >= 0.60 THEN 'AA (Top 40%)'
        WHEN Percentil >= 0.40 THEN 'A (Médio Alto)'
        WHEN Percentil >= 0.20 THEN 'B (Médio)'
        ELSE 'C (Desenvolvimento)'
    END AS Classificacao,
    
    -- Percentil para análise
    ROUND(Percentil * 100, 1) AS Percentil_Posicao

FROM ScoredClientes
ORDER BY TotalScore_Ponderado DESC, Total_Vendas DESC;


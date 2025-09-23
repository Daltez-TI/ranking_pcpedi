-- Sistema de Ranking Completo - Versão SQLite Compatível
-- Execute os scripts em sequência (não todos de uma vez)

-- SCRIPT 1: Criação das tabelas (execute primeiro)
CREATE TABLE pesos_ranking (
    kpi_nome TEXT PRIMARY KEY,
    peso DECIMAL(3,2),
    descricao TEXT
);

INSERT INTO pesos_ranking VALUES
('vendas', 0.30, 'Peso para Total de Vendas'),
('peso_liquido', 0.20, 'Peso para Total Peso Líquido'),
('lucro_total', 0.30, 'Peso para Lucro Total'),
('mix_produtos', 0.20, 'Peso para Mix de Produtos');

CREATE TABLE pontuacao_vendas (
    faixa_min DECIMAL(10,2),
    faixa_max DECIMAL(10,2),
    pontos INT,
    qtd_clientes INT DEFAULT 0
);

INSERT INTO pontuacao_vendas VALUES
(0, 1000, 1, 0),
(1000.01, 5000, 3, 0),
(5000.01, 15000, 6, 0),
(15000.01, 30000, 10, 0),
(30000.01, 50000, 15, 0),
(50000.01, 100000, 22, 0),
(100000.01, 200000, 30, 0),
(200000.01, 999999999, 40, 0);

CREATE TABLE pontuacao_peso_liquido (
    faixa_min DECIMAL(10,2),
    faixa_max DECIMAL(10,2),
    pontos INT,
    qtd_clientes INT DEFAULT 0
);

INSERT INTO pontuacao_peso_liquido VALUES
(0, 50, 1, 0),
(50.01, 100, 2, 0),
(100.01, 250, 4, 0),
(250.01, 500, 7, 0),
(500.01, 1000, 12, 0),
(1000.01, 2000, 18, 0),
(2000.01, 5000, 25, 0),
(5000.01, 999999999, 35, 0);

CREATE TABLE pontuacao_lucro_total (
    faixa_min DECIMAL(10,2),
    faixa_max DECIMAL(10,2),
    pontos INT,
    qtd_clientes INT DEFAULT 0
);

INSERT INTO pontuacao_lucro_total VALUES
(0, 50, 1, 0),
(50.01, 200, 3, 0),
(200.01, 500, 6, 0),
(500.01, 1000, 10, 0),
(1000.01, 2500, 15, 0),
(2500.01, 5000, 22, 0),
(5000.01, 10000, 28, 0),
(10000.01, 999999999, 35, 0);

CREATE TABLE pontuacao_mix_produtos (
    faixa_min INT,
    faixa_max INT,
    pontos INT,
    qtd_clientes INT DEFAULT 0
);

INSERT INTO pontuacao_mix_produtos VALUES
(0, 3, 1, 0),
(4, 5, 2, 0),
(6, 9, 3, 0),
(10, 14, 4, 0),
(15, 19, 7, 0),
(20, 29, 10, 0),
(30, 49, 15, 0),
(50, 999999, 25, 0);

-- SCRIPT 2: Criar tabela temporária com o ranking (execute depois)
DROP TABLE IF EXISTS ranking_temp;

CREATE TABLE ranking_temp AS
WITH ClienteMetrics AS (
    SELECT
        CODCLI,
        CLIENTE,
        CODREDE,
        NOME_REDE,
        CODUSUR,
        NOME,
        
        SUM(VLRVENDA) AS Total_Vendas,
        SUM(TOTLIQ) AS Total_Peso_Liquido,
        
        SUM(
            CASE WHEN "custo total" > VLRVENDA THEN 0 ELSE "lucro total (R$)" END
        ) AS Lucro_Total,
        
        COUNT(DISTINCT CODPROD) AS Mix_Produtos,
        
        CASE 
            WHEN CODREDE <> 0 THEN (
                SELECT COUNT(DISTINCT CODCLI)
                FROM pcpedi p2
                WHERE p2.CODREDE = pcpedi.CODREDE
            )
            ELSE 1
        END AS Total_Lojas_Rede

    FROM pcpedi
    WHERE
        CODFILIAL = 1
        AND POSICAO = 'F'
        AND CONDVENDA = 1
        AND CONSIDERAR = 'SIM'
    GROUP BY 
        CODCLI, CLIENTE, CODREDE, NOME_REDE, CODUSUR, NOME
),

ClientesPontuados AS (
    SELECT 
        *,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_vendas 
            WHERE Total_Vendas >= faixa_min AND Total_Vendas <= faixa_max
            LIMIT 1
        ), 1) AS Pontos_Vendas,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_peso_liquido 
            WHERE Total_Peso_Liquido >= faixa_min AND Total_Peso_Liquido <= faixa_max
            LIMIT 1
        ), 1) AS Pontos_Peso,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_lucro_total 
            WHERE Lucro_Total >= faixa_min AND Lucro_Total <= faixa_max
            LIMIT 1
        ), 1) AS Pontos_Lucro,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_mix_produtos 
            WHERE Mix_Produtos >= faixa_min AND Mix_Produtos <= faixa_max
            LIMIT 1
        ), 1) AS Pontos_Mix

    FROM ClienteMetrics
)

SELECT 
    *,
    (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
     Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
     Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
     Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) AS Pontuacao_Total,
     
    CASE 
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 21 THEN 'AAA+'
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 18 THEN 'AAA'
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 15 THEN 'AA'
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 12 THEN 'A'
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 9 THEN 'B'
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 6 THEN 'C'
        WHEN (Pontos_Vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              Pontos_Lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              Pontos_Mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 3 THEN 'D'			  
        ELSE 'E'
    END AS Categoria_Cliente

FROM ClientesPontuados;

-- SCRIPT 3: Atualizar contadores (execute depois do Script 2)
UPDATE pontuacao_vendas SET qtd_clientes = 0;
UPDATE pontuacao_peso_liquido SET qtd_clientes = 0;
UPDATE pontuacao_lucro_total SET qtd_clientes = 0;
UPDATE pontuacao_mix_produtos SET qtd_clientes = 0;

UPDATE pontuacao_vendas 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.Total_Vendas >= pontuacao_vendas.faixa_min 
    AND r.Total_Vendas <= pontuacao_vendas.faixa_max
);

UPDATE pontuacao_peso_liquido 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.Total_Peso_Liquido >= pontuacao_peso_liquido.faixa_min 
    AND r.Total_Peso_Liquido <= pontuacao_peso_liquido.faixa_max
);

UPDATE pontuacao_lucro_total 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.Lucro_Total >= pontuacao_lucro_total.faixa_min 
    AND r.Lucro_Total <= pontuacao_lucro_total.faixa_max
);

UPDATE pontuacao_mix_produtos 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.Mix_Produtos >= pontuacao_mix_produtos.faixa_min 
    AND r.Mix_Produtos <= pontuacao_mix_produtos.faixa_max
);

-- SCRIPT 4: Visualizar o ranking final (execute por último)
create TABLE teste_por_faixas as
SELECT
	ROW_NUMBER() OVER (ORDER BY Pontuacao_Total DESC, Total_Vendas DESC) AS Pos_Global,
    ROW_NUMBER() over (partition by NOME order by Pontuacao_Total desc, Total_Vendas desc) as Pos_Vendedor,
    CAST(CODCLI AS TEXT) || ' - ' || CLIENTE AS Cliente_Info,
    Total_Lojas_Rede,
    CASE WHEN CODREDE <> 0 THEN NOME_REDE ELSE 'INDEPENDENTE' END AS Rede,
	CODUSUR,
    NOME AS Vendedor,
    
    ROUND(Total_Vendas, 2) AS Total_Vendas,
    ROUND(Total_Peso_Liquido, 2) AS Total_Peso_Liquido,
    ROUND(Lucro_Total, 2) AS Lucro_Total,
    Mix_Produtos,
    
    Pontos_Vendas,
    Pontos_Peso,
    Pontos_Lucro,
    Pontos_Mix,
    
    ROUND(Pontuacao_Total, 2) AS Pontuacao_Final,
    Categoria_Cliente,
    
    ROUND(
        PERCENT_RANK() OVER (ORDER BY Pontuacao_Total) * 100, 1
    ) AS Percentil_Posicao

FROM ranking_temp
ORDER BY Pontuacao_Total DESC, Total_Vendas DESC;

-- SCRIPTS AUXILIARES (executar conforme necessidade):

-- Ver distribuição nas faixas:
SELECT 
    'VENDAS' AS KPI,
    CAST(faixa_min AS TEXT) || ' - ' || CAST(faixa_max AS TEXT) AS Faixa,
    pontos AS Pontos,
    qtd_clientes AS Qtd_Clientes,
    ROUND(qtd_clientes * 100.0 / (SELECT COUNT(*) FROM ranking_temp), 1) AS Percentual
FROM pontuacao_vendas
UNION ALL
SELECT 'PESO_LIQUIDO', CAST(faixa_min AS TEXT) || ' - ' || CAST(faixa_max AS TEXT), pontos, qtd_clientes,
       ROUND(qtd_clientes * 100.0 / (SELECT COUNT(*) FROM ranking_temp), 1) FROM pontuacao_peso_liquido
UNION ALL
SELECT 'LUCRO_TOTAL', CAST(faixa_min AS TEXT) || ' - ' || CAST(faixa_max AS TEXT), pontos, qtd_clientes,
       ROUND(qtd_clientes * 100.0 / (SELECT COUNT(*) FROM ranking_temp), 1) FROM pontuacao_lucro_total
UNION ALL
SELECT 'MIX_PRODUTOS', CAST(faixa_min AS TEXT) || ' - ' || CAST(faixa_max AS TEXT), pontos, qtd_clientes,
       ROUND(qtd_clientes * 100.0 / (SELECT COUNT(*) FROM ranking_temp), 1) FROM pontuacao_mix_produtos
ORDER BY KPI, pontos;

-- Ver pesos atuais:
SELECT kpi_nome AS KPI, peso AS Peso_Atual, ROUND(peso * 100, 1) AS Percentual, descricao 
FROM pesos_ranking ORDER BY peso DESC;

-- Para alterar pesos (exemplo):
-- UPDATE pesos_ranking SET peso = 0.50 WHERE kpi_nome = 'vendas';
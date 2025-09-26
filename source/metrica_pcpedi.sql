-- Sistema de Ranking Completo - Versão SQLite Compatível
-- Execute os scripts em sequência (não todos de uma vez)

-- Criação de Índices para performance (execute uma vez)
CREATE INDEX idx_pcpedi_filtros ON pcpedi(CODFILIAL, POSICAO, CONDVENDA, CONSIDERAR);
CREATE INDEX idx_pcpedi_data ON pcpedi(DATA); -- para os cálculos de frequência
CREATE INDEX idx_pcpedi_cliente ON pcpedi(CODCLI); -- para agrupamentos por cliente
CREATE INDEX idx_pcpedi_produto ON pcpedi(CODPROD); -- para contagem de mix de produtos

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
        strftime('%Y-%m', DATA) AS periodo,
        CODCLI AS codcli,
        CLIENTE AS cliente,
        CODREDE AS codrede,
        NOME_REDE AS nome_rede,
        CODUSUR AS codusur,
        NOME AS nome,
        RAMO AS ramo,
        MUNICENT AS municipio,
        
        ROUND(SUM(VLRVENDA), 2) AS total_vendas,
        ROUND(SUM(TOTLIQ), 2) AS total_peso_liquido,

        ROUND(SUM(
            CASE WHEN "custo total" > VLRVENDA THEN 0 ELSE "lucro total (R$)" END
        ), 2) AS lucro_total,

        COUNT(DISTINCT CODPROD) AS mix_produtos,

        CASE
            WHEN SUM(TOTBRUTONF) > 0 THEN ROUND(SUM(VLRVENDA) / SUM(TOTBRUTONF), 2)
            ELSE 0
        END AS mva,
        
        CASE 
            WHEN SUM(VLRVENDA) > 0 THEN ROUND((SUM(VLRVENDA) - SUM("custo total")) / SUM(VLRVENDA) * 100, 2)
            ELSE 0 
        END AS margem_percent,
        
        CASE 
            WHEN CODREDE <> 0 THEN (
                SELECT COUNT(DISTINCT CODCLI)
                FROM pcpedi p2
                WHERE p2.CODREDE = pcpedi.CODREDE
            )
            ELSE 1
        END AS total_lojas_rede,

        COUNT(DISTINCT DATE(DATA) || '-' || CODCLI) AS freq_pedidos,

        ROUND((SUM(TOTLIQ) / COUNT(DISTINCT DATE(DATA) || '-' || CODCLI)), 2) AS peso_por_entrega,
        ROUND((SUM(CASE WHEN "custo total" > VLRVENDA THEN 0 ELSE "lucro total (R$)" END) / COUNT(DISTINCT DATE(DATA) || '-' || CODCLI)), 2) AS lucro_por_entrega


    FROM pcpedi
    WHERE
        CODFILIAL = 1
        AND POSICAO = 'F'
        AND CONDVENDA = 1
        AND CONSIDERAR = 'SIM'
        AND CODUSUR NOT IN (3) -- código 3 usado para funcionarios internos
    GROUP BY 
        periodo, codcli
),

ClientesPontuados AS (
    SELECT 
        *,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_vendas 
            WHERE total_vendas >= faixa_min AND total_vendas <= faixa_max
            LIMIT 1
        ), 1) AS pontos_vendas,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_peso_liquido 
            WHERE total_peso_liquido >= faixa_min AND total_peso_liquido <= faixa_max
            LIMIT 1
        ), 1) AS pontos_peso,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_lucro_total 
            WHERE lucro_total >= faixa_min AND lucro_total <= faixa_max
            LIMIT 1
        ), 1) AS pontos_lucro,
        
        COALESCE((
            SELECT pontos 
            FROM pontuacao_mix_produtos 
            WHERE mix_produtos >= faixa_min AND mix_produtos <= faixa_max
            LIMIT 1
        ), 1) AS pontos_mix 

    FROM ClienteMetrics
)

SELECT 
    *,
    (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
     pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
     pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
     pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) AS pontuacao_total,
     
    CASE 
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 21 THEN 'AAA+'
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 18 THEN 'AAA'
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 15 THEN 'AA'
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 12 THEN 'A'
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              Pontos_Peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 9 THEN 'B'
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 6 THEN 'C'
        WHEN (pontos_vendas * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'vendas') + 
              pontos_peso * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'peso_liquido') + 
              pontos_lucro * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'lucro_total') + 
              pontos_mix * (SELECT peso FROM pesos_ranking WHERE kpi_nome = 'mix_produtos')) >= 3 THEN 'D'			  
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
    WHERE r.total_vendas >= pontuacao_vendas.faixa_min 
    AND r.total_vendas <= pontuacao_vendas.faixa_max
);

UPDATE pontuacao_peso_liquido 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.total_peso_liquido >= pontuacao_peso_liquido.faixa_min 
    AND r.total_peso_liquido <= pontuacao_peso_liquido.faixa_max
);

UPDATE pontuacao_lucro_total 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.lucro_total >= pontuacao_lucro_total.faixa_min 
    AND r.lucro_total <= pontuacao_lucro_total.faixa_max
);

UPDATE pontuacao_mix_produtos 
SET qtd_clientes = (
    SELECT COUNT(*) 
    FROM ranking_temp r
    WHERE r.mix_produtos >= pontuacao_mix_produtos.faixa_min 
    AND r.mix_produtos <= pontuacao_mix_produtos.faixa_max
);

-- SCRIPT 4: Visualizar o ranking final (execute por último)
create TABLE teste_por_faixas as
SELECT
    periodo,
	ROW_NUMBER() OVER (PARTITION BY periodo ORDER BY pontuacao_total DESC, total_vendas DESC) AS pos_global,
    ROW_NUMBER() over (partition by periodo, nome order by pontuacao_total desc, total_vendas desc) as pos_vendedor,
    CAST(codcli AS TEXT) || ' - ' || cliente AS cliente_info,
    total_lojas_rede,
    CASE WHEN codrede <> 0 THEN nome_rede ELSE 'INDEPENDENTE' END AS rede,
	codusur,
    nome AS vendedor,

    ROUND(total_vendas, 2) AS total_vendas,
    ROUND(total_peso_liquido, 2) AS total_peso_liquido,
    ROUND(lucro_total, 2) AS lucro_total,
    mix_produtos,
    
    pontos_vendas,
    pontos_peso,
    pontos_lucro,
    pontos_mix,

    ROUND(pontuacao_total, 2) AS pontuacao_final,
    categoria_cliente,

    ROUND(
        PERCENT_RANK() OVER (PARTITION BY periodo ORDER BY pontuacao_total) * 100, 1
    ) AS percentil_posicao,

    freq_pedidos,
    ramo,
    municipio,
    ROUND(mva, 2) AS mva,
    ROUND(margem_percent, 2) AS margem_percent,
    ROUND(peso_por_entrega, 2) AS peso_por_entrega,
    ROUND(lucro_por_entrega, 2) AS lucro_por_entrega

FROM ranking_temp
-- GROUP BY periodo
ORDER BY pontuacao_total DESC, total_vendas DESC;

-- SCRIPTS AUXILIARES (executar conforme necessidade):

-- Ver distribuição nas faixas:
SELECT 
    'VENDAS' AS kpi,
    CAST(faixa_min AS TEXT) || ' - ' || CAST(faixa_max AS TEXT) AS faixa,
    pontos AS pontos,
    qtd_clientes AS qtd_clientes,
    ROUND(qtd_clientes * 100.0 / (SELECT COUNT(*) FROM ranking_temp), 1) AS percentual
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
ORDER BY kpi, pontos;

-- Ver pesos atuais:
SELECT kpi_nome AS kpi, peso AS peso_atual, ROUND(peso * 100, 1) AS percentual, descricao
FROM pesos_ranking ORDER BY peso DESC;

-- Para alterar pesos (exemplo):
-- UPDATE pesos_ranking SET peso = 0.50 WHERE kpi_nome = 'vendas';
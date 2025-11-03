-- criada em 2025-10-31
-- Autor: Marcelo


-- gera uma curva ABC geral por periodo, apos o rankeamento dos clientes
-- permitido salvar em uma nova tabela para analises futuras

CREATE TABLE Rank_plus_CurvaABC as
WITH base AS (
    SELECT
        f1.*
    FROM "teste_por_faixas" f1
    WHERE f1.Categoria_Cliente IN ('(VIP)', 'A', 'B', 'C', 'D', 'E')
      AND f1.ramo NOT IN ('REPRESENTANTE', 'FUNCIONARIO', 'EX FUNCIONARIO') -- CODATV1 IN (4010, 4015, 4016)
      AND f1.codusur NOT IN (3, 9901) -- vendedor NOT IN ('APP ION', 'VENDA DIRETA DEPOSITO')
      AND f1.margem_percent > 0
      AND NOT EXISTS (
          SELECT 1
          FROM "teste_por_faixas" f2
          WHERE TRIM(SUBSTR(f2.cliente_info, INSTR(f2.cliente_info, ' - ') + 2)) LIKE f2.vendedor || '%'
            AND f2.cliente_info = f1.cliente_info
      )
),

ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY Categoria_Cliente, periodo
            ORDER BY total_vendas DESC
        ) AS rank_cliente
    FROM base
),

acumulado AS (
    SELECT
        r1.*,
        r1.rank_cliente,
        (
            SELECT SUM(r2.total_vendas)
            FROM ranked r2
            WHERE r2.Categoria_Cliente = r1.Categoria_Cliente
              AND r2.periodo = r1.periodo
              AND r2.rank_cliente <= r1.rank_cliente
        ) AS total_acumulado
    FROM ranked r1
),

total_categoria AS (
    SELECT
        Categoria_Cliente,
        periodo,
        SUM(total_vendas) AS total_categoria
    FROM base
    GROUP BY Categoria_Cliente, periodo
)

SELECT
    a.*,
    ROUND(1.0 * a.total_acumulado / t.total_categoria, 4) AS percent_acumulado,
    CASE
        WHEN 1.0 * a.total_acumulado / t.total_categoria <= 0.8 THEN 'A'
        WHEN 1.0 * a.total_acumulado / t.total_categoria <= 0.95 THEN 'B'
        ELSE 'C'
    END AS classe_abc
FROM acumulado a
JOIN total_categoria t
  ON a.Categoria_Cliente = t.Categoria_Cliente
     AND a.periodo = t.periodo
ORDER BY 
    a.periodo,
    CASE 
        WHEN a.Categoria_Cliente = '(VIP)' THEN 1
        WHEN a.Categoria_Cliente = 'A' THEN 2
        WHEN a.Categoria_Cliente = 'B' THEN 3
        WHEN a.Categoria_Cliente = 'C' THEN 4
        WHEN a.Categoria_Cliente = 'D' THEN 5
        WHEN a.Categoria_Cliente = 'E' THEN 6
    END,
    a.rank_cliente;
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 15 09:49:17 2025

@author: marcelo.fascioli

Adaptado para SQLite - PCA
Lê dados de uma tabela existente, calcula pesos via PCA
e grava em uma nova tabela no mesmo banco.
"""

import pandas as pd
import sqlite3
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

# =====================================================
# 1. Conectar ao banco e ler a tabela de origem
# =====================================================
db_path = "G:/TI/marcelo/estudos/projeto_ranking/database/prototipagem_ranking_Ago25.db3"        # <-- ajuste o caminho do seu banco
tabela_origem = "pcpedi"       # <-- ajuste o nome da tabela de origem
tabela_destino = "pesos_ranking_pca"

conn = sqlite3.connect(db_path)

# Carregar dados
df = pd.read_sql(f"SELECT * FROM {tabela_origem} WHERE CODFILIAL = 1 AND POSICAO = 'F' AND CONDVENDA = 1", conn)

# =====================================================
# 2. Preparar métricas relevantes
# =====================================================
df["MVA"] = df["VLRVENDA"] / df["TOTBRUTONF"].replace(0, 1)

df_agg = df.groupby("CLIENTE").agg({
    "VLRVENDA": "sum",
    "lucro total (R$)": "sum",
    "TOTBRUTONF": "sum",
    "% brut un.": "mean",
    "Lucro / Kg Liq": "mean",
    "NUMPED": pd.Series.nunique,
    "CODPROD": pd.Series.nunique
}).reset_index()

df_agg["MVA"] = df_agg["VLRVENDA"] / df_agg["TOTBRUTONF"].replace(0, 1)

# =====================================================
# 3. Seleção de métricas para PCA
# =====================================================
X = df_agg[[
    "VLRVENDA", "lucro total (R$)", "% brut un.",
    "Lucro / Kg Liq", "NUMPED", "CODPROD", "MVA"
]].fillna(0)

# Padronização
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# =====================================================
# 4. PCA
# =====================================================
pca = PCA(n_components=len(X.columns))
pca.fit(X_scaled)

# Pegar as cargas do primeiro componente
loadings = abs(pca.components_[0])
weights = loadings / loadings.sum()

# =====================================================
# 5. Mapear pesos para métricas de ranking
# =====================================================
mapping = {
    "Vendas_Score": "VLRVENDA",
    "Lucro_Score": "lucro total (R$)",
    "Margem_Score": "% brut un.",
    "Eficiencia_Score": "Lucro / Kg Liq",
    "Frequencia_Score": "NUMPED",
    "Diversidade_Score": "CODPROD",
    "MVA_Score_Rank": "MVA"
}

final_weights = {}
for metric, col in mapping.items():
    if col in X.columns:
        idx = list(X.columns).index(col)
        final_weights[metric] = round(float(weights[idx]), 6)

# Normalização final para garantir soma = 1.0
soma = sum(final_weights.values())
final_weights = {m: round(w / soma, 6) for m, w in final_weights.items()}

# =====================================================
# 6. Gravar resultados em nova tabela no SQLite
# =====================================================
cur = conn.cursor()

# Criar tabela destino (se não existir)
cur.execute(f"""
CREATE TABLE IF NOT EXISTS {tabela_destino} (
    metrica TEXT PRIMARY KEY,
    peso REAL
)
""")

# Limpar registros anteriores
cur.execute(f"DELETE FROM {tabela_destino}")

# Inserir novos pesos
for m, w in final_weights.items():
    cur.execute(f"INSERT INTO {tabela_destino} (metrica, peso) VALUES (?, ?)", (m, w))

conn.commit()
conn.close()

print("✅ Pesos (PCA) calculados e gravados em", tabela_destino)

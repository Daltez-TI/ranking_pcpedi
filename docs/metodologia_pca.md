# Relatório Técnico – Cálculo de Pesos com PCA

## 1. Contexto

O objetivo é calcular **pesos estatísticos** para diferentes métricas de clientes (ex.: vendas, lucro, margem, frequência, recência, diversidade de produtos, quantidade etc.), de forma a compor um **ranking agregado**.

Existem duas abordagens possíveis:

* **Regressão Linear Múltipla** – assume uma variável dependente (`y`) e mede como cada variável explicativa contribui para prever esse alvo.
* **Análise de Componentes Principais (PCA)** – trata todas as variáveis de forma simétrica, buscando combinações lineares que maximizem a variância explicada.

Como o objetivo aqui **não é previsão de uma variável específica**, mas sim **estimar importância relativa das métricas**, o **PCA é mais apropriado**.

---

## 2. Formulação Matemática do PCA

Dado um conjunto de dados com $n$ observações e $p$ variáveis (métricas):

$$
X = \begin{bmatrix}
x_{11} & x_{12} & \dots & x_{1p} \\
x_{21} & x_{22} & \dots & x_{2p} \\
\vdots & \vdots & \ddots & \vdots \\
x_{n1} & x_{n2} & \dots & x_{np}
\end{bmatrix}
$$

### 2.1 Padronização

Cada variável é padronizada (z-score) para evitar distorções de escala:

$$
z_{ij} = \frac{x_{ij} - \bar{x}_j}{s_j}
$$

onde $\bar{x}_j$ é a média e $s_j$ o desvio padrão da variável $j$.

### 2.2 Decomposição

O PCA encontra autovalores e autovetores da matriz de covariância $S$:

$$
S = \frac{1}{n-1} Z^T Z
$$

onde $Z$ é a matriz padronizada.

### 2.3 Componentes Principais

Os **componentes principais** são combinações lineares das variáveis originais:

$$
PC_k = a_{k1} z_1 + a_{k2} z_2 + \dots + a_{kp} z_p
$$

com $a_{kj}$ sendo as **cargas fatoriais** (loadings) do componente $k$.

### 2.4 Pesos a partir do Primeiro Componente

Normalmente, usamos o **primeiro componente principal (PC1)**, pois ele captura a maior variância do sistema.

Os pesos relativos são obtidos pelas cargas absolutas normalizadas:

$$
w_j = \frac{|a_{1j}|}{\sum_{j=1}^p |a_{1j}|}
$$

garantindo que:

$$
\sum_{j=1}^p w_j = 1
$$

---

## 3. Interpretação

* Cada $w_j$ representa a **importância relativa** da métrica $j$ na formação da variância explicada pelo **PC1**.
* Como todas as métricas são tratadas igualmente (não há variável dependente), o resultado é um **conjunto equilibrado de pesos**.
* Esses pesos podem ser armazenados em banco de dados e aplicados na construção de um **índice composto** ou ranking.

---

## 4. Comparação PCA vs Regressão Linear

| Método               | Uso principal                                      | Vantagens                                                            | Limitações                                                         |
| -------------------- | -------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------ |
| **Regressão Linear** | Previsão de uma variável dependente ($y$)          | Mede contribuição de cada preditor para explicar $y$                 | Exige variável alvo; ignora métricas não diretamente ligadas a $y$ |
| **PCA**              | Redução de dimensionalidade e análise exploratória | Inclui todas as métricas de forma simétrica; gera pesos normalizados | Não prevê diretamente $y$; interpretação pode ser menos intuitiva  |

---

## 5. Conclusão

Para o problema em questão — **atribuição de pesos para métricas de ranking de clientes** — o **PCA** é a escolha mais adequada, pois:

* Considera todas as métricas como igualmente relevantes a priori.
* Fornece pesos normalizados, diretamente utilizáveis para compor índices.
* Evita viés de escolher arbitrariamente uma variável como dependente.

$$
\boxed{\text{Portanto, os pesos obtidos via PCA são a forma mais consistente de definir o ranking.}}
$$



CREATE TABLE data_warehouse.dim_item_modalidade 
( 
 id SERIAL PRIMARY KEY,  
 cod_item_modalidade VARCHAR NOT NULL,  
 dsc_item_modalidade VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.dim_item_elemento 
( 
 id SERIAL PRIMARY KEY,  
 cod_item_elemento VARCHAR NOT NULL,  
 dsc_item_elemento VARCHAR NOT NULL 
); 

CREATE TABLE data_warehouse.dim_subfuncao 
( 
 id SERIAL PRIMARY KEY,  
 cod_subfuncao VARCHAR NOT NULL,  
 dsc_subfuncao VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.dim_programa 
( 
 id SERIAL PRIMARY KEY,  
 cod_programa VARCHAR NOT NULL,  
 dsc_programa VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.dim_fonte 
( 
 id SERIAL PRIMARY KEY,  
 cod_fonte VARCHAR NOT NULL,  
 dsc_fonte VARCHAR NOT NULL 
); 

CREATE TABLE data_warehouse.dim_funcao 
( 
 id SERIAL PRIMARY KEY,  
 cod_funcao VARCHAR NOT NULL,  
 dsc_funcao VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.dim_orgao 
( 
 id SERIAL PRIMARY KEY,  
 cod_orgao VARCHAR NOT NULL,  
 dsc_orgao VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.dim_tempo 
( 
 id SERIAL PRIMARY KEY,  
 data_inteira DATE NOT NULL,  
 ano VARCHAR NOT NULL,  
 mes VARCHAR NOT NULL,  
 dia VARCHAR NOT NULL
); 

CREATE TABLE data_warehouse.dim_item_grupo 
( 
 id SERIAL PRIMARY KEY,  
 cod_item_grupo VARCHAR NOT NULL,  
 dsc_item_grupo VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.dim_item_categoria 
( 
 id SERIAL PRIMARY KEY,  
 cod_item_categoria VARCHAR NOT NULL,  
 dsc_item_categoria VARCHAR NOT NULL  
); 

CREATE TABLE data_warehouse.fato_execucao_financeira 
( 
 id SERIAL PRIMARY KEY,  
 id_item_categoria INT,  
 id_item_grupo INT,   
 id_orgao INT,  
 id_programa INT,  
 id_subfuncao INT,  
 id_item_elemento INT,  
 id_item_modalidade INT,  
 id_funcao INT,  
 id_fonte INT,
 id_data_empenho INT,
 id_data_pagamento INT,
 cod_ne VARCHAR,  
 cod_emp VARCHAR,  
 valor_empenho DECIMAL (18,2),  
 valor_pagamento DECIMAL (18,2) 
); 

ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_item_categoria) REFERENCES data_warehouse.dim_item_categoria (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_item_grupo) REFERENCES data_warehouse.dim_item_grupo (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_orgao) REFERENCES data_warehouse.dim_orgao (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_programa) REFERENCES data_warehouse.dim_programa (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_subfuncao) REFERENCES data_warehouse.dim_subfuncao (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_item_elemento) REFERENCES data_warehouse.dim_item_elemento (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_item_modalidade) REFERENCES data_warehouse.dim_item_modalidade (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_funcao) REFERENCES data_warehouse.dim_funcao (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY(id_fonte) REFERENCES data_warehouse.dim_fonte (id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY (id_data_empenho) REFERENCES data_warehouse.dim_tempo(id)
ALTER TABLE data_warehouse.fato_execucao_financeira ADD FOREIGN KEY (id_data_pagamento) REFERENCES data_warehouse.dim_tempo(id)

--Preenchimento da dimensão tempo
INSERT INTO data_warehouse.dim_tempo(data_inteira,ano,mes,dia)
SELECT
	dt as data_inteira,
	EXTRACT('YEAR' FROM dt) AS ano,
	EXTRACT('MONTH' FROM dt) AS mes,
	EXTRACT('DAY' FROM dt) AS dia
FROM generate_series(CURRENT_DATE - INTERVAL '30 YEARS', CURRENT_DATE + INTERVAL'5 YEARS', INTERVAL '1 day') AS dt

--Resultado:
SELECT * FROM data_warehouse.dim_tempo
ORDER BY 1 DESC

--Análise Exploratória da DIM_ORGÃO
SELECT 
	count(*) as total, 
	count(cod_orgao) as total_codigo, 
	count(dsc_orgao) as total_descricao
FROM public.execucao_financeira_despesa

--Selecionando as linhas de descrição que estão nulas
SELECT DISTINCT cod_orgao, dsc_orgao
FROM public.execucao_financeira_despesa
WHERE dsc_orgao is null

--Tratamento de Dados - DIM ORGAO
UPDATE public.execucao_financeira_despesa
SET dsc_orgao = 'NÃO INFORMADO'
WHERE dsc_orgao is null

--Atualizando os valores
UPDATE public.execucao_financeira_despesa
SET dsc_orgao = 'Secretaria da Segurança Pública e Defesa Social'
WHERE cod_orgao = '561001'

UPDATE public.execucao_financeira_despesa
SET dsc_orgao = 'Agência de Desenvolvimento do Estado do Ceará'
WHERE cod_orgao = '561101'

UPDATE public.execucao_financeira_despesa
SET dsc_orgao = UPPER (dsc_orgao)

--Preenchimento da DIM ORGAO
INSERT INTO data_warehouse.dim_orgao (cod_orgao, dsc_orgao)
SELECT DISTINCT cod_orgao, dsc_orgao
FROM public.execucao_financeira_despesa

--Resultado:
SELECT * FROM data_warehouse.dim_orgao
ORDER BY 1 DESC

--Análise Explorátória da DIM ITEM_GRUPO
SELECT 
	count(*) as total,
	count(cod_item_grupo) as total_codigo, 
	count(dsc_item_grupo) as total_descricao
FROM public.execucao_financeira_despesa

SELECT num_ano, cod_item_grupo, dsc_item_grupo, count(*)
FROM public.execucao_financeira_despesa
GROUP BY num_ano, cod_item_grupo, dsc_item_grupo

UPDATE public.execucao_financeira_despesa
SET cod_item_grupo = 'NÃO INFORMADO para 2020', dsc_item_grupo = 'NÃO INFORMADO para 2020'
WHERE cod_item_grupo is null AND dsc_item_grupo is null

--Preenchimento da DIM ITEM_GRUPO
INSERT INTO data_warehouse.dim_item_grupo(cod_item_grupo, dsc_item_grupo)
SELECT DISTINCT cod_item_grupo, dsc_item_grupo
FROM public.execucao_financeira_despesa
ORDER BY cod_item_grupo

--Resultado:
SELECT * FROM data_warehouse.dim_orgao
ORDER BY 1 DESC

--Preenchimento da DIM-categoria
INSERT INTO data_warehouse.dim_item_categoria (cod_item_categoria, dsc_item_categoria)
SELECT DISTINCT cod_item_categoria, dsc_item_categoria
FROM public.execucao_financeira_despesa
ORDER BY cod_item_categoria;

--Preenchimento da DIM_ITEM_MODALIDADE
INSERT INTO data_warehouse.dim_item_modalidade(cod_item_modalidade, dsc_item_modalidade)
SELECT DISTINCT cod_item_modalidade, dsc_item_modalidade
FROM public.execucao_financeira_despesa

--Preenchimento da ITEM_ELEMENTO
INSERT INTO data_warehouse.dim_item_elemento(cod_item_elemento, dsc_item_elemento)
SELECT DISTINCT cod_item_elemento, dsc_item_elemento
FROM public.execucao_financeira_despesa

--Preenchimento da DIM_SUBFUNCAO
INSERT INTO data_warehouse.dim_subfuncao(cod_subfuncao, dsc_subfuncao)
SELECT DISTINCT cod_subfuncao, dsc_subfuncao
FROM public.execucao_financeira_despesa

--Preenchimento da DIM_PROGRAMA
INSERT INTO data_warehouse.dim_programa (cod_programa, dsc_programa)
SELECT DISTINCT cod_programa, dsc_programa
FROM public.execucao_financeira_despesa

--Preenchimento da DIM_FONTE
INSERT INTO data_warehouse.dim_fonte (cod_fonte, dsc_fonte)
SELECT DISTINCT cod_fonte, dsc_fonte
FROM public.execucao_financeira_despesa

--Preenchimento da DIM_FUNCAO
INSERT INTO data_warehouse.dim_funcao (cod_funcao, dsc_funcao)
SELECT DISTINCT cod_funcao, dsc_funcao
FROM public.execucao_financeira_despesa

--Preenchimento da fato_execucao_financeira
INSERT INTO data_warehouse.fato_execucao_financeira(
id_orgao, id_data_empenho, id_data_pagamento, id_fonte, id_item_categoria, id_item_elemento, id_funcao, 
id_subfuncao, id_programa, id_item_grupo, id_item_modalidade, cod_ne, cod_emp, valor_empenho, valor_pagamento)

SELECT dor.id as id_orgao, dt_empenho.id as id_data_empenho, dt_pagamento.id as id_data_pagamento,
df.id as id_fonte, dic.id as id_item_categoria, die.id as id_item_elemento, dfu.id as id_funcao, 
dsu.id as id_subfuncao, dp.id as id_programa,dig.id as id_item_grupo, dim.id as id_item_modalidade, 
cod_ne, cod_emp, vlr_empenho as valor_empenho, vlr_pagamento as valor_pagamento

FROM public.execucao_financeira_despesa efd
INNER JOIN data_warehouse.dim_orgao dor on dor.cod_orgao = efd.cod_orgao
INNER JOIN data_warehouse.dim_tempo dt_empenho on dt_empenho.data_inteira = efd.dth_empenho
LEFT JOIN data_warehouse.dim_tempo dt_pagamento on dt_pagamento.data_inteira = efd.dth_pagamento
INNER JOIN data_warehouse.dim_fonte df on df.cod_fonte = efd.cod_fonte
INNER JOIN data_warehouse.dim_item_categoria dic on dic.cod_item_categoria = efd.cod_item_categoria
INNER JOIN data_warehouse.dim_item_elemento die on die.cod_item_elemento = efd.cod_item_elemento
INNER JOIN data_warehouse.dim_funcao dfu on dfu.cod_funcao = efd.cod_funcao
INNER JOIN data_warehouse.dim_subfuncao dsu on dsu.cod_subfuncao = efd.cod_subfuncao
INNER JOIN data_warehouse.dim_programa dp on dp.cod_programa = efd.cod_programa
INNER JOIN data_warehouse.dim_item_grupo dig on dig.cod_item_grupo = efd.cod_item_grupo
INNER JOIN data_warehouse.dim_item_modalidade dim on dim.cod_item_modalidade = efd.cod_item_modalidade

--Criando a View
CREATE OR REPLACE VIEW data_warehouse.view_empenho_por_ano AS
SELECT ano, SUM(valor_empenho)::money as total_empenho, SUM(valor_pagamento)::money as valor_pagamento 
FROM (
	SELECT  id_orgao, cod_ne, dt.ano, valor_empenho, SUM(valor_pagamento) as valor_pagamento
	FROM data_warehouse.fato_execucao_financeira fef
	INNER JOIN data_warehouse.dim_tempo dt on dt.id = fef.id_data_empenho
	LEFT JOIN data_warehouse.dim_tempo dtp on dtp.id = fef.id_data_pagamento
	GROUP BY id_orgao, cod_ne, dt.ano, valor_empenho
	) tb
GROUP BY ano
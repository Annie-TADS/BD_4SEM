\c postgres
DROP DATABASE IF EXISTS aliexpress;

CREATE DATABASE aliexpress;

\c aliexpress;

CREATE SCHEMA localizacao;
SET search_path TO public, localizacao;

CREATE TABLE localizacao.estado (
    id serial primary key,
    nome text not null,
    sigla character(2) not null
);
INSERT INTO localizacao.estado (nome, sigla) VALUES ('RIO GRANDE DO SUL', 'RS');

CREATE TABLE localizacao.cidade (
    id serial primary key,
    nome text not null,
    estado_id integer references localizacao.estado (id)
);
INSERT INTO localizacao.cidade (nome, estado_id) VALUES ('RIO GRANDE', 1);

CREATE TABLE fornecedor (
    cnpj character(14) primary key,
    razao_social character varying (200) not null,
    endereco text,
    cidade_id integer references localizacao.cidade (id)
);
INSERT INTO fornecedor (cnpj, razao_social, endereco, cidade_id) VALUES
('97276163000133', 'FIFINE CORPORATION', 'ALFREDO HUCH 134', 1),
('97276163000132', 'M-VAVE GUITARS PRODUCTS', 'LAR GAÚCHO', 1);

INSERT INTO fornecedor (cnpj, razao_social, endereco) VALUES
('97276163000131', 'WHAAH Pickups', 'PARQUE SÃO PEDRO');

CREATE TABLE cliente (
    id serial primary key,
    nome character varying(100) not null,
    bairro text,
    rua text,
    complemento text,
    nro text,
    cep character(8),
    cidade_id integer references localizacao.cidade (id)
);
INSERT INTO cliente (nome, bairro, rua, complemento, nro, cep, cidade_id) VALUES
('IGOR PEREIRA', 'TREVO', 'RUA DO TREVO', NULL, '201', '96202188', 1),
('RAFAEL BETITO', 'PARQUE MARINHA', 'RUA DO MARINHA', NULL, '134', '96202100', 1),
('BRUNO 1', 'BAIRRO DO BRUNO', 'RUA DO BRUNO', NULL, '234', '96202188', null);

CREATE TABLE nota  (
    id serial primary key,
    data_hora timestamp default current_timestamp,
    tipo_pagamento character varying(100) check(tipo_pagamento in ('DINHEIRO', 'PIX', 'CARTÃO', 'BOLETO')),
    impostos money,
    cliente_id integer references cliente (id)
);
INSERT INTO nota (tipo_pagamento, cliente_id) VALUES 
('PIX', 1);

INSERT INTO nota (tipo_pagamento, cliente_id, data_hora) VALUES 
('PIX', 2, '01-01-2024');

CREATE TABLE produto (
    id serial primary key,
    descricao text not null,
    estoque integer check(estoque >= 0),
    valor money check(cast(valor AS numeric(8,2)) >= 0),
    cnpj_fornecedor character(14) references fornecedor (cnpj)
);
INSERT INTO produto (descricao, estoque, valor, cnpj_fornecedor) VALUES
('MICROFONE KM688', 100, 150.00, '97276163000133'),
('MICROFONE RUIM', 0, 0.50, '97276163000133'),
('SUPORTE PARA MICROFONES', 200, 250, '97276163000133');

CREATE TABLE item (
    nota_id integer references nota (id),
    produto_id integer references produto (id),
    qtde integer check (qtde > 0),
    preco_unitario_pago money check(cast(preco_unitario_pago AS numeric(8,2)) >= 0),
    primary key (nota_id, produto_id)
);
INSERT INTO item (nota_id, produto_id, qtde, preco_unitario_pago) VALUES
(1,1,1,150.00),(1,2,5,0.50),(2,1,90,150.00);

CREATE VIEW fornecedor_cidade AS SELECT fornecedor.*, cidade.nome FROM fornecedor left join cidade on (fornecedor.cidade_id = cidade.id);

-- Quais produtos estão sem estoque?
SELECT * FROM produto WHERE estoque <= 0;

-- Qual produto mais vendido no último mês?
SELECT produto.* FROM produto INNER JOIN item ON item.produto_id = produto.id INNER JOIN nota ON nota.id = item.nota_id WHERE CAST(nota.data_hora AS DATE) >= CURRENT_DATE - INTERVAL '30 days' AND CAST(nota.data_hora AS DATE) <= CURRENT_DATE GROUP BY produto.id HAVING SUM(item.qtde) = 
    (SELECT SUM(item.qtde) FROM produto INNER JOIN item ON item.produto_id = produto.id INNER JOIN nota ON nota.id = item.nota_id WHERE CAST(nota.data_hora AS DATE) >= CURRENT_DATE - INTERVAL '30 days' AND CAST(nota.data_hora AS DATE) <= CURRENT_DATE GROUP BY produto.id ORDER BY SUM(item.qtde) DESC LIMIT 1);

-- Qual o produto mais vendido?
SELECT produto.* FROM produto INNER JOIN item ON item.produto_id = produto.id GROUP BY produto.id HAVING SUM(item.qtde) = 
    (SELECT SUM(item.qtde) FROM produto INNER JOIN item ON item.produto_id = produto.id GROUP BY produto.id ORDER BY SUM(item.qtde) DESC LIMIT 1);

-- Quantidade de pedidos por cliente?
SELECT cliente.nome, CASE WHEN count(nota.id) > 0 THEN count(nota.id) ELSE 0 END AS qtd_pedidos FROM cliente LEFT JOIN nota ON nota.cliente_id = cliente.id GROUP BY cliente.id; 

-- Produto mais vendido
SELECT produto.* FROM produto INNER JOIN item ON item.produto_id = produto.id GROUP BY produto.id HAVING SUM(item.qtde) = 
    (SELECT SUM(item.qtde) FROM produto INNER JOIN item ON item.produto_id = produto.id GROUP BY produto.id ORDER BY SUM(item.qtde) DESC LIMIT 1);

-- Média de preço dos produtos
SELECT AVG(produto.valor::numeric) FROM produto;

-- Somente produtos comprados entre um determinado intervalo de datas (2024-06-20 / 2024-07-20)
SELECT produto.* FROM produto INNER JOIN item ON item.produto_id = produto.id INNER JOIN nota ON nota_id = item.nota_id WHERE nota.data_hora BETWEEN '2024-06-20' AND '2024-07-20' GROUP BY produto.id;

-- Quais clientes fizeram mais pedidos?
SELECT cliente.*, count(nota.id) AS qtd_pedidos FROM cliente INNER JOIN nota ON nota.cliente_id = cliente.id GROUP BY cliente.id HAVING count(nota.id) = 
    (SELECT count(nota.id) FROM cliente INNER JOIN nota ON nota.cliente_id = cliente.id GROUP BY cliente.id ORDER BY count(nota.id) DESC LIMIT 1); 

-- Qual pedido que solicitou a maior quantide de itens?
SELECT nota.*, count(item.nota_id) AS qtd_itens FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id HAVING count(item.nota_id) = 
    (SELECT count(item.nota_id) FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id ORDER BY count(item.nota_id) DESC LIMIT 1);

-- Qual o pedido mais caro?
SELECT nota.*, SUM(item.preco_unitario_pago * item.qtde) AS valor_nota FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id HAVING SUM(item.preco_unitario_pago * item.qtde) = 
    (SELECT SUM(item.preco_unitario_pago * item.qtde ) FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id ORDER BY SUM(item.preco_unitario_pago * item.qtde) DESC LIMIT 1);

-- Qual o cliente que realizou o pedido mais caro?
SELECT cliente.*, SUM(item.preco_unitario_pago * item.qtde) AS valor_nota FROM nota INNER JOIN item ON item.nota_id = nota.id INNER JOIN cliente ON cliente.id = nota.cliente_id GROUP BY nota.id, cliente.id HAVING SUM(item.preco_unitario_pago * item.qtde) = 
    (SELECT SUM(item.preco_unitario_pago * item.qtde ) FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id ORDER BY SUM(item.preco_unitario_pago * item.qtde) DESC LIMIT 1);

-- Listar os últimos 10 pedidos?
SELECT * FROM nota ORDER BY data_hora DESC LIMIT 10;

-- Clientes cadastrados que ainda não fizeram nenhum pedido
SELECT cliente.* FROM cliente LEFT JOIN nota ON nota.cliente_id = cliente.id WHERE nota.id IS NULL;

-- Somente clientes que realizaram algum pedido
SELECT cliente.* FROM cliente INNER JOIN nota ON nota.cliente_id = cliente.id;

-- Somente clientes que não cadastraram sua cidade
SELECT cliente.* FROM cliente WHERE cidade_id IS NULL;

-- Fornecedores que fornecem mais de um produto
SELECT fornecedor.*, count(produto.id) AS qtd_produtos FROM fornecedor INNER JOIN produto ON produto.cnpj_fornecedor = fornecedor.cnpj GROUP BY fornecedor.cnpj HAVING count(produto.id) > 1;

-- Clientes que moram em estados onde a sigla começa por 'A'
SELECT cliente.* FROM cliente INNER JOIN localizacao.cidade ON localizacao.cidade.id = cliente.cidade_id INNER JOIN localizacao.estado ON localizacao.estado.id = localizacao.cidade.estado_id WHERE localizacao.estado.nome LIKE 'A%';

-- Listar todos os pedidos da última semana
SELECT * FROM nota WHERE CAST(data_hora AS DATE) >= (CURRENT_DATE - INTERVAL '7 days') AND CAST(data_hora AS DATE) <= CURRENT_DATE;

-- Quantidade de pedidos por cada forma de pagamento.
SELECT nota.tipo_pagamento, count(nota.id) AS qtd FROM nota GROUP BY nota.tipo_pagamento;

-- Qual é a principal forma de pagamento da plataforma?
SELECT nota.tipo_pagamento, count(nota.id) AS qtd FROM nota GROUP BY nota.tipo_pagamento HAVING count(nota.id) = 
    (SELECT count(nota.id) FROM nota GROUP BY nota.tipo_pagamento ORDER BY count(nota.id) DESC LIMIT 1);

-- Quantos itens tem o pedido com maior valor?
SELECT nota.*, count(item.nota_id) AS qtd_itens, SUM(item.preco_unitario_pago * item.qtde) AS valor_nota FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id HAVING SUM(item.preco_unitario_pago * item.qtde) = 
    (SELECT SUM(item.preco_unitario_pago * item.qtde ) FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id ORDER BY SUM(item.preco_unitario_pago * item.qtde) DESC LIMIT 1);

-- Qual fornecedor fornece mais produtos?
SELECT fornecedor.*, count(produto.id) AS qtd_produtos FROM fornecedor INNER JOIN produto ON produto.cnpj_fornecedor = fornecedor.cnpj GROUP BY fornecedor.cnpj HAVING count(produto.id) = 
    (SELECT count(produto.id) FROM fornecedor INNER JOIN produto ON produto.cnpj_fornecedor = fornecedor.cnpj GROUP BY fornecedor.cnpj ORDER BY count(produto.id) DESC LIMIT 1);

-- Qual fornecedor tem fornecido uma maior quantidade de produtos em estoque?
SELECT fornecedor.*, SUM(produto.estoque) AS produtos_estoque FROM fornecedor INNER JOIN produto ON produto.cnpj_fornecedor = fornecedor.cnpj GROUP BY fornecedor.cnpj HAVING SUM(produto.estoque) = 
    (SELECT SUM(produto.estoque) FROM fornecedor INNER JOIN produto ON produto.cnpj_fornecedor = fornecedor.cnpj GROUP BY fornecedor.cnpj ORDER BY SUM(produto.estoque) DESC LIMIT 1);

-- Quantidade de itens por pedido.
SELECT nota.*, count(item.nota_id) AS qtd_itens FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id;

-- Quantidade de itens por pedido (considerando qtde solicitada de cada item)
SELECT nota.*, SUM(item.qtde) AS qtd_itens FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id;

-- Principal cidade dos clientes
SELECT cidade.*, count(cliente.id) AS qtd_clientes FROM localizacao.cidade INNER JOIN cliente ON cliente.cidade_id = localizacao.cidade.id GROUP BY cidade.id HAVING count(cliente.id) = 
    (SELECT count(cliente.id) FROM localizacao.cidade INNER JOIN cliente ON cliente.cidade_id = localizacao.cidade.id GROUP BY cidade.id ORDER BY count(cliente.id) DESC LIMIT 1);

-- Principal cidade dos fornecedores
SELECT cidade.*, count(fornecedor.cnpj) AS qtd_fornecedores FROM localizacao.cidade INNER JOIN fornecedor ON fornecedor.cidade_id = localizacao.cidade.id GROUP BY cidade.id HAVING count(fornecedor.cnpj) = 
    (SELECT count(fornecedor.cnpj) FROM localizacao.cidade INNER JOIN fornecedor ON fornecedor.cidade_id = localizacao.cidade.id GROUP BY cidade.id ORDER BY count(fornecedor.cnpj) DESC LIMIT 1);

-- Dia com mais pedidos
SELECT TO_CHAR(CAST(nota.data_hora AS DATE), 'dd/mm/yyyy') AS data, count(nota.id) AS qtd_pedidos FROM nota GROUP BY CAST(nota.data_hora AS DATE) HAVING count(nota.id) =
    (SELECT count(nota.id) FROM nota GROUP BY CAST(nota.data_hora AS DATE) ORDER BY count(nota.id) DESC LIMIT 1);

-- Total de um pedido
SELECT nota.*, SUM(item.preco_unitario_pago * item.qtde) AS valor_nota FROM nota INNER JOIN item ON item.nota_id = nota.id WHERE nota.id = 1 GROUP BY nota.id;

-- Faça uma consulta que mostre a descrição e o estoque do produto e o nome do fornecedor do produto.
CREATE VIEW produto_fornecedor AS SELECT produto.descricao, produto.estoque, fornecedor.razao_social FROM produto LEFT JOIN fornecedor ON produto.cnpj_fornecedor = fornecedor.cnpj; 
SELECT * FROM produto_fornecedor;

-- Faça uma consulta que mostra o número, data, valor da nota e o nome do cliente de todas as notas.
CREATE VIEW nota_cliente AS SELECT nota.id AS numero, TO_CHAR(CAST(nota.data_hora AS DATE), 'dd/mm/yyyy') AS data, SUM(item.preco_unitario_pago * item.qtde) AS valor_nota, cliente.nome FROM nota INNER JOIN cliente ON cliente.id = nota.cliente_id INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id, cliente.id;
SELECT * FROM nota_cliente;

-- Faça uma consulta que mostre o nome do cliente e a soma das notas desse cliente.
CREATE VIEW soma_cliente AS SELECT cliente.nome, SUM(nota.valor) AS soma_nota FROM cliente INNER JOIN (SELECT SUM(item.preco_unitario_pago * item.qtde) AS valor, nota.cliente_id FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.id) AS nota ON nota.cliente_id = cliente.id GROUP BY cliente.id; 
SELECT * FROM soma_cliente;

-- Faça uma consulta que mostre os fornecedores que tenham produtos com estoque igual a 0.
CREATE VIEW fornecedor_sem_estoque AS SELECT fornecedor.* FROM fornecedor INNER JOIN produto ON produto.cnpj_fornecedor = fornecedor.cnpj WHERE produto.estoque = 0 GROUP BY fornecedor.cnpj;
SELECT * FROM fornecedor_sem_estoque;

-- Faça uma consulta que mostre o valor total das notas por tipo de pagamento.
CREATE VIEW soma_tipo_pagamento AS SELECT nota.tipo_pagamento, SUM(item.preco_unitario_pago * item.qtde) AS valor_total FROM nota INNER JOIN item ON item.nota_id = nota.id GROUP BY nota.tipo_pagamento; 
SELECT * FROM soma_tipo_pagamento;

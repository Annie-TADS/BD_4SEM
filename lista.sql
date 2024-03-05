--Listas o nome do usuário e o nomes das suas contas
SELECT usuario.nome, STRING_AGG(conta.nome_usuario, ', ') AS contas FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id;

-- Listas as publicações e seus arquivos
SELECT publicacao.texto, STRING_AGG(arquivo.arquivo, ', ') AS arquivo FROM publicacao LEFT JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id;

-- Listar as publicações e seus comentários
SELECT publicacao.texto, STRING_AGG(comentario.texto, ', ') AS comentario FROM publicacao LEFT JOIN comentario ON comentario.publicacao_id = publicacao.id GROUP BY publicacao.id;

-- Listar somente publicações com comentários
SELECT publicacao.texto FROM publicacao INNER JOIN comentario ON comentario.publicacao_id = publicacao.id;

-- Retornar a quantidade de contas por usuário
SELECT usuario.nome, count(conta.*) AS quantidade FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id;

-- Retornar a quantidade de publicações por usuário
SELECT usuario.nome, count(conta_publicacao.*) AS quantidade  FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY usuario.id;

-- Retornar as publicações com mais comentários
SELECT publicacao.texto, count(comentario.*) AS quantidade FROM publicacao LEFT JOIN comentario ON comentario.publicacao_id = publicacao.id GROUP BY publicacao.id ORDER BY quantidade DESC;

-- Retornar publicações que não tem comentários
SELECT publicacao.texto FROM publicacao LEFT JOIN comentario ON comentario.publicacao_id = publicacao.id WHERE comentario.id IS NULL;

-- Retornar somente usuários que possuem um única conta
SELECT usuario.nome FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id HAVING count(conta.*) = 1;

-- Retornar usuários com mais de uma conta sob sua responsabilidade
SELECT usuario.nome FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id HAVING count(conta.*) > 1;

-- Retornar publicações sem arquivos adicionais (Sem registros na tabela de arquivo)
SELECT publicacao.texto FROM publicacao LEFT JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(arquivo.*) = 0;

-- Retornar somente publicações compartilhadas por mais de uma conta
SELECT publicacao.texto FROM publicacao LEFT JOIN conta_publicacao ON conta_publicacao.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(conta_publicacao.*) > 1;

-- Retornar usuários que ainda não criaram nenhuma publicação
SELECT usuario.nome FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id WHERE conta_publicacao.publicacao_id IS NULL GROUP BY usuario.id;

-- Retornar usuários que possuem só publicações sem comentários
SELECT publicacao.texto FROM publicacao LEFT JOIN comentario ON comentario.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(comentario.*) = 0;

-- Retornar a conta que mais realizou comentários
SELECT conta.nome_usuario FROM conta LEFT JOIN comentario ON comentario.conta_id = conta.id GROUP BY conta.id HAVING count(comentario.*) = (SELECT count(comentario.*) AS quantidade FROM conta LEFT JOIN comentario ON comentario.conta_id = conta.id GROUP BY conta.id ORDER BY quantidade DESC LIMIT 1);

-- Retornar o nome do usuário e o nome da conta da última conta criada
SELECT usuario.nome, conta.nome_usuario FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id WHERE conta.id = (SELECT conta.id FROM conta WHERE conta.usuario_id = usuario.id ORDER BY data_hora_criacao DESC LIMIT 1);

-- Retornar usuário(s) que possue(m) a maior quantidade de contas
SELECT usuario.nome FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id HAVING count(conta.*) = (SELECT count(conta.*) AS quantidade FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id ORDER BY quantidade DESC LIMIT 1);

-- Retornar usuário(s) que possue(m) a menor quantidade de contas
SELECT usuario.nome FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id HAVING count(conta.*) = (SELECT count(conta.*) AS quantidade FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id ORDER BY quantidade ASC LIMIT 1);

-- Retornar comentários realizados durante a última semana (últimos 7 dias)
SELECT comentario.texto FROM comentario WHERE comentario.data_hora > (now() - INTERVAL '7 DAYS');

-- Retornar as contas do(s) usuário(s) mais velho(s)
SELECT usuario.nome, STRING_AGG(conta.nome_usuario, ', ') AS contas FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id WHERE usuario.data_nascimento IN ((SELECT usuario.data_nascimento FROM usuario ORDER BY usuario.data_nascimento ASC LIMIT 1)) GROUP BY usuario.id;

-- Listar nos primeiros resultados usuários sem conta acima dos usuários com conta
SELECT usuario.nome FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id ORDER BY count(conta.*) ASC;

-- Quantidade total de comentários dado um intervalo de datas
SELECT count(*) AS comentarios FROM comentario WHERE comentario.data_hora BETWEEN '2020-01-01' AND now();

-- Selecione publicações que tenham mais de um arquivo (fora o obrigatório)
SELECT publicacao.texto FROM publicacao LEFT JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(arquivo.*) > 1;

-- Publicação com maior texto (maior número de caracteres)
SELECT publicacao.texto, LENGTH(publicacao.texto) AS tamanho_texto FROM publicacao ORDER BY LENGTH(publicacao.texto) DESC LIMIT 1;

-- Publicações com maior número de caracteres (nesta questão cuidar a questão do empate, ou seja, 2 ou mais publicações terem o texto com o mesma quantidade de caracteres)
SELECT publicacao.texto, LENGTH(publicacao.texto) AS tamanho_texto FROM publicacao WHERE LENGTH(publicacao.texto) = (SELECT LENGTH(publicacao.texto) FROM publicacao ORDER BY LENGTH(publicacao.texto) DESC LIMIT 1);

-- Usuário que mais publicou em um dado intervalo de tempo
SELECT usuario.nome, count(conta_publicacao.*) AS quantidade FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY usuario.id HAVING count(conta_publicacao.*) = (SELECT count(conta_publicacao.*) FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY usuario.id ORDER BY count(conta_publicacao.*) DESC LIMIT 1);

-- Conta que mais publicou
SELECT conta.nome_usuario, count(conta_publicacao.*)-1 AS quantidade FROM conta LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY conta.id HAVING count(conta_publicacao.*) = (SELECT count(conta_publicacao.*) FROM conta LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY conta.id ORDER BY count(conta_publicacao.*) DESC LIMIT 1);

-- Conta que mais compartilhou publicações
SELECT conta.nome_usuario, count(conta_publicacao.*) AS quantidade FROM conta LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id WHERE conta.id != (SELECT conta_publicacao_primeira.conta_id FROM conta_publicacao AS conta_publicacao_primeira WHERE conta_publicacao_primeira.publicacao_id = conta_publicacao.publicacao_id GROUP BY conta_publicacao_primeira.conta_id LIMIT 1) GROUP BY conta.id HAVING count(conta_publicacao.*) = (SELECT count(conta_publicacao.*) FROM conta LEFT JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id WHERE conta.id != ((SELECT conta_publicacao_primeira.conta_id FROM conta_publicacao AS conta_publicacao_primeira WHERE conta_publicacao_primeira.publicacao_id = conta_publicacao.publicacao_id GROUP BY conta_publicacao_primeira.conta_id LIMIT 1)) GROUP BY conta.id ORDER BY count(conta_publicacao.*) DESC LIMIT 1);

-- Publicação com mais arquivos
SELECT publicacao.texto, count(arquivo.*) AS quantidade FROM publicacao LEFT JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(arquivo.*) = ((SELECT count(arquivo.*) FROM publicacao LEFT JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id ORDER BY count(arquivo.*) DESC LIMIT 1));

-- Alterar a tabela conta_publicação e adicionar a data e hora em que uma publicação foi compartilhada
ALTER TABLE conta_publicacao DROP IF EXISTS data_hora;
ALTER TABLE conta_publicacao ADD data_hora TIMESTAMP NOT NULL DEFAULT '1900-01-01 00:00:00';

-- Usuário que mais realizou comentários
SELECT usuario.nome, count(comentario.*) AS quantidade FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id LEFT JOIN comentario ON comentario.conta_id = conta.id GROUP BY usuario.id HAVING count(comentario.*) = (SELECT count(comentario.*) FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id LEFT JOIN comentario ON comentario.conta_id = conta.id GROUP BY usuario.id ORDER BY count(comentario.*) DESC LIMIT 1);

-- Conta que mais realizou comentários
SELECT conta.nome_usuario, count(comentario.*) AS quantidade FROM conta LEFT JOIN comentario ON comentario.conta_id = conta.id GROUP BY conta.id HAVING count(comentario.*) = (SELECT count(comentario.*) FROM conta LEFT JOIN comentario ON comentario.conta_id = conta.id GROUP BY conta.id ORDER BY count(comentario.*) DESC LIMIT 1);

-- Formatar o retorno da data e hora
SELECT conta.nome_usuario, publicacao.texto, TO_CHAR(conta_publicacao.data_hora, 'dd/mm/yyyy hh:mi:ss') AS data FROM conta_publicacao INNER JOIN conta ON conta.id = conta_publicacao.conta_id INNER JOIN publicacao ON publicacao.id = conta_publicacao.publicacao_id;  
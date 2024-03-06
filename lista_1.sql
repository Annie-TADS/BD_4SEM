--Listas o nome do usuário e o nomes das suas contas
SELECT    usuario.nome,
          String_agg(conta.nome_usuario, ', ') AS contas
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id;

-- Listas as publicações e seus arquivosSELECT    publicacao.texto,
          String_agg(arquivo.arquivo, ', ') AS arquivo
FROM      publicacao
LEFT JOIN arquivo
ON        arquivo.publicacao_id = publicacao.id
GROUP BY  publicacao.id;

-- Listar as publicações e seus comentáriosSELECT    publicacao.texto,
          String_agg(comentario.texto, ', ') AS comentario
FROM      publicacao
LEFT JOIN comentario
ON        comentario.publicacao_id = publicacao.id
GROUP BY  publicacao.id;

-- Listar somente publicações com comentáriosSELECT     publicacao.texto
FROM       publicacao
INNER JOIN comentario
ON         comentario.publicacao_id = publicacao.id;

-- Retornar a quantidade de contas por usuárioSELECT    usuario.nome,
          Count(conta.*) AS quantidade
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id;

-- Retornar a quantidade de publicações por usuárioSELECT    usuario.nome,
          Count(conta_publicacao.*) AS quantidade
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
LEFT JOIN conta_publicacao
ON        conta_publicacao.conta_id = conta.id
GROUP BY  usuario.id;

-- Retornar as publicações com mais comentáriosSELECT    publicacao.texto,
          Count(comentario.*) AS quantidade
FROM      publicacao
LEFT JOIN comentario
ON        comentario.publicacao_id = publicacao.id
GROUP BY  publicacao.id
ORDER BY  quantidade DESC;

-- Retornar publicações que não tem comentáriosSELECT    publicacao.texto
FROM      publicacao
LEFT JOIN comentario
ON        comentario.publicacao_id = publicacao.id
WHERE     comentario.id IS NULL;

-- Retornar somente usuários que possuem um única contaSELECT    usuario.nome
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id
HAVING    Count(conta.*) = 1;

-- Retornar usuários com mais de uma conta sob sua responsabilidadeSELECT    usuario.nome
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id
HAVING    Count(conta.*) > 1;

-- Retornar publicações sem arquivos adicionais (Sem registros na tabela de arquivo)SELECT    publicacao.texto
FROM      publicacao
LEFT JOIN arquivo
ON        arquivo.publicacao_id = publicacao.id
GROUP BY  publicacao.id
HAVING    Count(arquivo.*) = 0;

-- Retornar somente publicações compartilhadas por mais de uma contaSELECT    publicacao.texto
FROM      publicacao
LEFT JOIN conta_publicacao
ON        conta_publicacao.publicacao_id = publicacao.id
GROUP BY  publicacao.id
HAVING    Count(conta_publicacao.*) > 1;

-- Retornar usuários que ainda não criaram nenhuma publicaçãoSELECT    usuario.nome
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
LEFT JOIN conta_publicacao
ON        conta_publicacao.conta_id = conta.id
WHERE     conta_publicacao.publicacao_id IS NULL
GROUP BY  usuario.id;

-- Retornar usuários que possuem só publicações sem comentáriosSELECT    publicacao.texto
FROM      publicacao
LEFT JOIN comentario
ON        comentario.publicacao_id = publicacao.id
GROUP BY  publicacao.id
HAVING    Count(comentario.*) = 0;

-- Retornar a conta que mais realizou comentáriosSELECT    conta.nome_usuario
FROM      conta
LEFT JOIN comentario
ON        comentario.conta_id = conta.id
GROUP BY  conta.id
HAVING    Count(comentario.*) =
          (
                    SELECT    Count(comentario.*) AS quantidade
                    FROM      conta
                    LEFT JOIN comentario
                    ON        comentario.conta_id = conta.id
                    GROUP BY  conta.id
                    ORDER BY  quantidade DESC limit 1);

-- Retornar o nome do usuário e o nome da conta da última conta criadaSELECT    usuario.nome,
          conta.nome_usuario
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
WHERE     conta.id =
          (
                   SELECT   conta.id
                   FROM     conta
                   WHERE    conta.usuario_id = usuario.id
                   ORDER BY data_hora_criacao DESC limit 1);

-- Retornar usuário(s) que possue(m) a maior quantidade de contasSELECT    usuario.nome
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id
HAVING    Count(conta.*) =
          (
                    SELECT    Count(conta.*) AS quantidade
                    FROM      usuario
                    LEFT JOIN conta
                    ON        conta.usuario_id = usuario.id
                    GROUP BY  usuario.id
                    ORDER BY  quantidade DESC limit 1);

-- Retornar usuário(s) que possue(m) a menor quantidade de contasSELECT    usuario.nome
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id
HAVING    Count(conta.*) =
          (
                    SELECT    Count(conta.*) AS quantidade
                    FROM      usuario
                    LEFT JOIN conta
                    ON        conta.usuario_id = usuario.id
                    GROUP BY  usuario.id
                    ORDER BY  quantidade ASC limit 1);

-- Retornar comentários realizados durante a última semana (últimos 7 dias)SELECT comentario.texto
FROM   comentario
WHERE  comentario.data_hora > (Now() - interval '7 DAYS');

-- Retornar as contas do(s) usuário(s) mais velho(s)SELECT    usuario.nome,
          String_agg(conta.nome_usuario, ', ') AS contas
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
WHERE     usuario.data_nascimento IN (
          (
                   SELECT   usuario.data_nascimento
                   FROM     usuario
                   ORDER BY usuario.data_nascimento ASC limit 1))
GROUP BY  usuario.id;

-- Listar nos primeiros resultados usuários sem conta acima dos usuários com contaSELECT    usuario.nome
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
GROUP BY  usuario.id
ORDER BY  Count(conta.*) ASC;

-- Quantidade total de comentários dado um intervalo de datasSELECT Count(*) AS comentarios
FROM   comentario
WHERE  comentario.data_hora BETWEEN '2020-01-01' AND    Now();

-- Selecione publicações que tenham mais de um arquivo (fora o obrigatório)SELECT    publicacao.texto
FROM      publicacao
LEFT JOIN arquivo
ON        arquivo.publicacao_id = publicacao.id
GROUP BY  publicacao.id
HAVING    Count(arquivo.*) > 1;

-- Publicação com maior texto (maior número de caracteres)SELECT   publicacao.texto,
         Length(publicacao.texto) AS tamanho_texto
FROM     publicacao
ORDER BY Length(publicacao.texto) DESC limit 1;

-- Publicações com maior número de caracteres (nesta questão cuidar a questão do empate, ou seja, 2 ou mais publicações terem o texto com o mesma quantidade de caracteres)SELECT publicacao.texto,
       Length(publicacao.texto) AS tamanho_texto
FROM   publicacao
WHERE  Length(publicacao.texto) =
       (
                SELECT   Length(publicacao.texto)
                FROM     publicacao
                ORDER BY Length(publicacao.texto) DESC limit 1);

-- Usuário que mais publicou em um dado intervalo de tempoSELECT    usuario.nome,
          Count(conta_publicacao.*) AS quantidade
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
LEFT JOIN conta_publicacao
ON        conta_publicacao.conta_id = conta.id
GROUP BY  usuario.id
HAVING    Count(conta_publicacao.*) =
          (
                    SELECT    Count(conta_publicacao.*)
                    FROM      usuario
                    LEFT JOIN conta
                    ON        conta.usuario_id = usuario.id
                    LEFT JOIN conta_publicacao
                    ON        conta_publicacao.conta_id = conta.id
                    GROUP BY  usuario.id
                    ORDER BY  Count(conta_publicacao.*) DESC limit 1);

-- Conta que mais publicouSELECT    conta.nome_usuario,
          Count(conta_publicacao.*)-1 AS quantidade
FROM      conta
LEFT JOIN conta_publicacao
ON        conta_publicacao.conta_id = conta.id
GROUP BY  conta.id
HAVING    Count(conta_publicacao.*) =
          (
                    SELECT    Count(conta_publicacao.*)
                    FROM      conta
                    LEFT JOIN conta_publicacao
                    ON        conta_publicacao.conta_id = conta.id
                    GROUP BY  conta.id
                    ORDER BY  Count(conta_publicacao.*) DESC limit 1);

-- Conta que mais compartilhou publicaçõesSELECT    conta.nome_usuario,
          Count(conta_publicacao.*) AS quantidade
FROM      conta
LEFT JOIN conta_publicacao
ON        conta_publicacao.conta_id = conta.id
WHERE     conta.id !=
          (
                   SELECT   conta_publicacao_primeira.conta_id
                   FROM     conta_publicacao AS conta_publicacao_primeira
                   WHERE    conta_publicacao_primeira.publicacao_id = conta_publicacao.publicacao_id
                   GROUP BY conta_publicacao_primeira.conta_id limit 1)
GROUP BY  conta.id
HAVING    Count(conta_publicacao.*) =
          (
                    SELECT    Count(conta_publicacao.*)
                    FROM      conta
                    LEFT JOIN conta_publicacao
                    ON        conta_publicacao.conta_id = conta.id
                    WHERE     conta.id != (
                              (
                                       SELECT   conta_publicacao_primeira.conta_id
                                       FROM     conta_publicacao AS conta_publicacao_primeira
                                       WHERE    conta_publicacao_primeira.publicacao_id = conta_publicacao.publicacao_id
                                       GROUP BY conta_publicacao_primeira.conta_id limit 1))
                    GROUP BY  conta.id
                    ORDER BY  Count(conta_publicacao.*) DESC limit 1);

-- Publicação com mais arquivosSELECT    publicacao.texto,
          Count(arquivo.*) AS quantidade
FROM      publicacao
LEFT JOIN arquivo
ON        arquivo.publicacao_id = publicacao.id
GROUP BY  publicacao.id
HAVING    Count(arquivo.*) = (
          (
                    SELECT    Count(arquivo.*)
                    FROM      publicacao
                    LEFT JOIN arquivo
                    ON        arquivo.publicacao_id = publicacao.id
                    GROUP BY  publicacao.id
                    ORDER BY  Count(arquivo.*) DESC limit 1));

-- Alterar a tabela conta_publicação e adicionar a data e hora em que uma publicação foi compartilhadaALTER TABLE conta_publicacao DROPIF EXISTS data_hora;ALTER TABLE conta_publicacao ADD data_hora TIMESTAMP NOT NULL DEFAULT '1900-01-01 00:00:00';

-- Usuário que mais realizou comentáriosSELECT    usuario.nome,
          Count(comentario.*) AS quantidade
FROM      usuario
LEFT JOIN conta
ON        conta.usuario_id = usuario.id
LEFT JOIN comentario
ON        comentario.conta_id = conta.id
GROUP BY  usuario.id
HAVING    Count(comentario.*) =
          (
                    SELECT    Count(comentario.*)
                    FROM      usuario
                    LEFT JOIN conta
                    ON        conta.usuario_id = usuario.id
                    LEFT JOIN comentario
                    ON        comentario.conta_id = conta.id
                    GROUP BY  usuario.id
                    ORDER BY  Count(comentario.*) DESC limit 1);

-- Conta que mais realizou comentáriosSELECT    conta.nome_usuario,
          Count(comentario.*) AS quantidade
FROM      conta
LEFT JOIN comentario
ON        comentario.conta_id = conta.id
GROUP BY  conta.id
HAVING    Count(comentario.*) =
          (
                    SELECT    Count(comentario.*)
                    FROM      conta
                    LEFT JOIN comentario
                    ON        comentario.conta_id = conta.id
                    GROUP BY  conta.id
                    ORDER BY  Count(comentario.*) DESC limit 1);

-- Formatar o retorno da data e horaSELECT     conta.nome_usuario,
           publicacao.texto,
           To_char(conta_publicacao.data_hora, 'dd/mm/yyyy hh:mi:ss') AS data
FROM       conta_publicacao
INNER JOIN conta
ON         conta.id = conta_publicacao.conta_id
INNER JOIN publicacao
ON         publicacao.id = conta_publicacao.publicacao_id;

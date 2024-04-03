\c postgres;
DROP DATABASE IF EXISTS spotipobre; 

CREATE DATABASE spotipobre;
\c spotipobre;

CREATE TABLE usuario (
    id SERIAL NOT NULL,
    nome TEXT,
    email TEXT NOT NULL,
    senha TEXT NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE playlist (
    id SERIAL NOT NULL,
    nome TEXT NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    usuario_id INTEGER NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (usuario_id) REFERENCES usuario
);

CREATE TABLE artista (
    id SERIAL NOT NULL,
    nome TEXT NOT NULL,
    nome_artistico VARCHAR(60) NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE album (
    id SERIAL NOT NULL,
    titulo TEXT NOT NULL,
    data_lancamento DATE NOT NULL,
    artista_id INTEGER NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (artista_id) REFERENCES artista
);

CREATE TABLE musica (
    id SERIAL NOT NULL,
    titulo TEXT NOT NULL,
    duracao INTEGER NOT NULL,
    album_id INTEGER NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (album_id) REFERENCES album
);

CREATE TABLE playlist_musica (
    playlist_id INTEGER NOT NULL,
    musica_id INTEGER NOT NULL,

    PRIMARY KEY (playlist_id, musica_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist,
    FOREIGN KEY (musica_id) REFERENCES musica
);

--Insira no mínimo 3 tuplas em cada tabela
INSERT INTO usuario (nome, email, senha) VALUES 
    ('O escutador', 'escuto@musicas', 'musica123'),
    ('O ouvidor', 'ouvo@musicas', 'musica456'),
    ('O provador', 'provo@musicas', 'musica789');

INSERT INTO playlist (nome, usuario_id) VALUES
    ('playlist okay', 1), ('playlist okay2', 1),
    ('plalist boa', 2), ('plalist boa2', 2),
    ('playlist baseada', 3), ('playlist baseada2', 3);

INSERT INTO artista (nome, nome_artistico) VALUES
    ('Yo seu', 'teuMeu'),
    ('José', 'N0Way'),
    ('Jojo', 'Ganhemo');

INSERT INTO album (titulo, data_lancamento, artista_id) VALUES
    ('O single do ano', '2024-04-20', 1),
    ('O single da década', '2020-10-23', 2),
    ('O single do século', '2001-01-01', 3);

INSERT INTO musica (titulo, duracao, album_id) VALUES
    ('Despacito 3', 3800, 1),
    ('Baby Shark: O inimigo agora é outro', 120, 2),
    ('Whatsapp 2', 2, 3);

INSERT INTO playlist_musica (playlist_id, musica_id) VALUES
    (1,1), (1,2),
    (2,2), (2,3),
    (3,3), (3,1);

--Adicione a coluna data_nascimento na tabela de usuários. Além disso, coloque uma cláusula CHECK permitindo somente anos de nascimento >= 1900
ALTER TABLE usuario ADD data_nascimento DATE CHECK (data_nascimento >= '1900-01-01');

--Retorne os nomes dos usuários e suas datas de nascimento formatadas em dia/mes/ano. Para testar será preciso inserir ou atualizar as datas de nascimento de alguns usuários
UPDATE usuario SET data_nascimento = '2003-01-06' WHERE id = 1;
UPDATE usuario SET data_nascimento = '1993-04-29' WHERE id = 2;

SELECT nome, TO_CHAR(data_nascimento::date, 'dd/mm/yyyy') as data_nascimento FROM usuario;

--Delete usuários sem nome
INSERT INTO usuario (nome, email, senha) VALUES ('', 'nome@invalido', 'deleteME');
INSERT INTO usuario (email, senha) VALUES ('nome@invalido.tbm', 'deleteME2');

DELETE FROM usuario WHERE nome IS NULL OR nome = '';

--Torne a coluna nome da tabela usuários obrigatória
ALTER TABLE usuario ALTER COLUMN nome SET NOT NULL;

--Retorne os títulos de todos os álbuns em maiúsculo
SELECT UPPER(titulo) AS titulo FROM album;

--Retorne somente os títulos dos 2 primeiros álbuns cadastrados
SELECT titulo FROM album ORDER BY id ASC LIMIT 2;

--Retorne o nome e o email de todos os usuários separados por ponto-e-vírgula
SELECT CONCAT(nome, ';', email) AS nome_email FROM usuario;

-- Retorne músicas com duração entre 100 e 200 segundos
SELECT titulo, duracao FROM musica WHERE duracao BETWEEN 100 AND 200;

-- Retorne músicas que não possuem duração entre 100 e 200 segundos
SELECT titulo, duracao FROM musica WHERE duracao NOT BETWEEN 100 AND 200;

-- Retorne artistas que possuem nome e nome artístico
SELECT nome, nome_artistico FROM artista WHERE nome IS NOT NULL AND nome != '' AND nome_artistico IS NOT NULL AND nome_artistico != '';

-- Retorne, preferencialmente, o nome de todos os artistas. Caso um determinado artista não tenha cadastrado seu nome, retorne na mesma consulta seu nome artístico
SELECT CASE WHEN (nome IS NULL OR nome = '') THEN nome_artistico ELSE nome END AS nome FROM artista;

-- Retorne o título dos álbuns lançados em 2023
SELECT titulo FROM album WHERE EXTRACT(YEAR FROM data_lancamento) = 2023;

-- Retorne o nome das playlists que foram criadas hoje
SELECT nome FROM playlist WHERE data_hora::date = CURRENT_DATE;

-- Atualize todos os nomes dos artistas (nome e nome_artistico) para maiúsculo
UPDATE artista SET nome = UPPER(nome), nome_artistico = UPPER(nome_artistico);

-- Coloque uma verificação para a coluna duracao (tabela musica) para que toda duração tenha mais de 0 segundos
ALTER TABLE musica ADD CONSTRAINT duracao CHECK (duracao > 0);

-- Adicione uma restrição UNIQUE para a coluna email da tabela usuario
ALTER TABLE usuario ADD CONSTRAINT email UNIQUE (email);

-- Retorne somente os artistas que o nome artístico começa com "Leo" (Ex: Leo Santana, Leonardo e etc.)
SELECT nome, nome_artistico FROM artista WHERE nome_artistico ILIKE 'LEO%';

-- Retorne o título dos álbuns que estão fazendo aniversário neste mês
SELECT titulo FROM album WHERE EXTRACT(MONTH FROM data_lancamento) = EXTRACT(MONTH FROM NOW()) AND EXTRACT(YEAR FROM data_lancamento) < EXTRACT(YEAR FROM NOW());

-- Retorne o título dos álbuns lançados no segundo semestre do ano passado (de julho de 2022 a dezembro de 2022)
SELECT titulo FROM album WHERE EXTRACT(MONTH FROM data_lancamento) >= 6 AND EXTRACT(YEAR FROM data_lancamento) = EXTRACT(YEAR FROM NOW())-1;

-- Retorne o título dos álbuns lançados nos últimos 30 dias (https://www.postgresql.org/docs/current/functions-datetime.html)
SELECT titulo FROM album WHERE data_lancamento >= (NOW() - INTERVAL '30 DAY');

-- Retorne o título e o dia de lançamento (por extenso) de todos os álbuns
SELECT titulo, TO_CHAR(data_lancamento, 'Month DD, YYYY') AS data_lancamento FROM album;

-- Retorne o título e o mês de lançamento (por extenso) de todos os álbuns
SELECT titulo, CASE 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 1 THEN 'Janeiro' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 2 THEN 'Fevereiro' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 3 THEN 'Março' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 4 THEN 'Abril' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 5 THEN 'Maio' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 6 THEN 'Junho' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 7 THEN 'Julho' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 8 THEN 'Agosto' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 9 THEN 'Setembro' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 10 THEN 'Outubro' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 11 THEN 'Novembro' 
    WHEN EXTRACT(MONTH FROM data_lancamento) = 12 THEN 'Dezembro' 
    END
FROM album;

-- Retorne pelo menos um dos álbuns mais antigos
SELECT titulo FROM album WHERE data_lancamento = (SELECT data_lancamento FROM album ORDER BY data_lancamento ASC LIMIT 1);

-- Retorne pelo menos um dos álbuns mais recentes
SELECT titulo FROM album WHERE data_lancamento = (SELECT data_lancamento FROM album ORDER BY data_lancamento DESC LIMIT 1);

-- Liste os títulos das músicas de todos os álbuns de um determinado artista
SELECT musica.titulo FROM musica LEFT JOIN album ON album.id = musica.album_id WHERE album.artista_id = 1;

-- Liste os títulos das músicas de um álbum de um determinado artista
SELECT musica.titulo AS musica, album.titulo AS album FROM musica LEFT JOIN album ON album.id = musica.album_id WHERE album.artista_id = 1 AND album.id = 1;

-- Liste somente os nomes de usuários que possuem alguma playlist (cuidado! com a repetição)
SELECT nome FROM usuario WHERE id IN (SELECT usuario_id FROM playlist GROUP BY usuario_id);

-- Liste artistas que ainda não possuem álbuns cadastrados
SELECT nome FROM artista WHERE id NOT IN (SELECT artista_id FROM album GROUP BY artista_id);

-- Liste usuários que ainda não possuem playlists cadastradas
SELECT nome FROM usuario WHERE id NOT IN (SELECT usuario_id FROM playlist GROUP BY usuario_id);

-- Retorne a quantidade de álbuns por artista
SELECT artista.nome, count(*) AS albuns FROM artista LEFT JOIN album ON album.artista_id = artista.id GROUP BY artista.id;

-- Retorne a quantidade de músicas por artista
SELECT artista.nome, count(*) AS musicas FROM artista LEFT JOIN album ON album.artista_id = artista.id LEFT JOIN musica ON musica.album_id = album.id GROUP BY artista.id;

-- Retorne o título das músicas de uma playlist de um determinado usuário
SELECT titulo FROM musica INNER JOIN playlist_musica ON playlist_musica.musica_id = musica.id INNER JOIN playlist ON playlist.id = playlist_musica.playlist_id WHERE playlist.usuario_id = 1 AND playlist.id = 1; 

-- Retorne a quantidade de playlist de um determinado usuário
SELECT usuario.nome, count(*) AS playlists FROM usuario LEFT JOIN playlist ON playlist.usuario_id = usuario.id GROUP BY usuario.id;

-- Retone a quantidade de músicas por artista (de artistas que possuem pelo menos 2 músicas)
SELECT artista.nome, count(*) AS musicas FROM artista LEFT JOIN album ON album.artista_id = artista.id LEFT JOIN musica ON musica.album_id = album.id GROUP BY artista.id HAVING count(*) >= 2;

-- Retorne os títulos de todos os álbuns lançados no mesmo ano em que o álbum mais antigo foi lançado
SELECT titulo FROM album WHERE EXTRACT(YEAR FROM data_lancamento) = (SELECT EXTRACT(YEAR FROM data_lancamento) FROM album ORDER BY data_lancamento ASC LIMIT 1);

-- Retorne os títulos de todos os álbuns lançados no mesmo ano em que o álbum mais novo foi lançado
SELECT titulo FROM album WHERE EXTRACT(YEAR FROM data_lancamento) = (SELECT EXTRACT(YEAR FROM data_lancamento) FROM album ORDER BY data_lancamento DESC LIMIT 1);

-- Retorne na mesma consulta os nomes de todos os artistas e de todos os usuários. Caso um determinado artista não tenha cadastrado seu nome, retorne seu nome artístico
(SELECT CASE WHEN (nome IS NULL OR nome = '') THEN nome_artistico ELSE nome END AS nome FROM artista) UNION (SELECT nome FROM usuario);

-- Retorne nomes das playlists com e sem músicas
SELECT nome, CASE WHEN (SELECT musica_id FROM playlist_musica WHERE playlist_id = playlist.id LIMIT 1) IS NULL THEN 'SEM MÚSICA' ELSE 'COM MÚSICA' END AS tem_musica FROM playlist; 

-- Retorne a média da quantidade de músicas de todas as playlists
SELECT SUM((SELECT COUNT(DISTINCT musica_id) FROM musica INNER JOIN playlist_musica ON playlist_musica.musica_id = musica.id)) / (SELECT COUNT(*) FROM playlist);

-- Retorne somente playlists que possuem quantidade de músicas maior ou igual a média
SELECT playlist.nome FROM playlist_musica INNER JOIN playlist ON playlist.id = playlist_musica.playlist_id GROUP BY playlist_musica.playlist_id, playlist.nome HAVING count(*) > (SELECT SUM((SELECT COUNT(DISTINCT musica_id) FROM musica INNER JOIN playlist_musica ON playlist_musica.musica_id = musica.id)) / (SELECT COUNT(*) FROM playlist));
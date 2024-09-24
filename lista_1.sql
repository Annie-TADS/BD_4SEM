-- Procedure para verificar se um participante é maior de idade:
CREATE OR REPLACE PROCEDURE verificar_maioridade_participante(id_aux integer) AS 
$$
    DECLARE
        idade integer; 
    BEGIN
        SELECT EXTRACT(YEAR FROM AGE(data_nascimento)) INTO idade
        FROM participante where id = id_aux;
        IF (idade >= 18) THEN
            RAISE NOTICE 'PARTICIPANTE MAIOR DE IDADE';
        ELSE
            RAISE NOTICE 'PARTICIPANTE MENOR DE IDADE';
        END IF;
    END; 
$$
LANGUAGE 'plpgsql';

-- Procedure para atualizar o nome de um evento com tratamento de exceção:
CREATE OR REPLACE PROCEDURE atualizar_nome_evento_com_excecao(evento_id_aux integer, novo_nome character varying(150)) AS 
$$
    BEGIN
        IF (evento_id_aux > 0) THEN
            IF EXISTS(SELECT * FROM evento where id = evento_id_aux) THEN
                UPDATE evento SET nome = novo_nome where id = evento_id_aux;
                RAISE NOTICE 'EVENTO ATUALIZADO COM SUCESSO';
            ELSE
                RAISE NOTICE 'EVENTO INEXISTENTE';
            END IF;
        ELSE
            RAISE NOTICE 'PK DE EVENTO NAO PODE SER NEGATIVA';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'ERRO NA ATUALIZACAO DO EVENTO';
    END;
$$ 
LANGUAGE 'plpgsql';

-- Function para verificar se um desejo está dentro de um valor limite:
CREATE OR REPLACE FUNCTION verifica_limite(desejo_id_aux integer, valor_limite money) RETURNS BOOLEAN AS 
$$
DECLARE
    valor_desejo money;
BEGIN
    IF EXISTS(SELECT * FROM desejo where id = desejo_id_aux) THEN    
        SELECT valor_medio INTO valor_desejo FROM desejo where id = desejo_id_aux;
        RAISE NOTICE '% <= %', valor_desejo, valor_limite;        
        IF CAST(valor_desejo AS NUMERIC(10,2)) <= CAST(valor_limite AS NUMERIC(10,2)) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
   ELSE
        RAISE NOTICE 'DESEJO INEXISTENTE';
        RETURN FALSE; 
   END IF;   
END;
$$ 
LANGUAGE 'plpgsql';

-- Procedure para listar todos os participantes com idade acima de um valor específico:
CREATE OR REPLACE PROCEDURE listar_participantes_maiores_de(idade_limite integer) AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT * FROM participante where EXTRACT(YEAR FROM AGE(data_nascimento)) >= idade_limite LOOP
        RAISE NOTICE '%: %', rec.nome, rec.data_nascimento;    
    END LOOP;    
END;
$$ 
LANGUAGE 'plpgsql';

-- Function para verificar se um participante tem desejos cadastrados:
CREATE OR REPLACE FUNCTION verifica_participante_desejos(participante_id_aux integer) RETURNS BOOLEAN AS
$$
BEGIN
    IF EXISTS(SELECT * FROM desejo where participante_id = participante_id_aux) THEN
        
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ 
LANGUAGE 'plpgsql';

-- Procedure para listar todos os eventos criados após uma data específica:
CREATE OR REPLACE PROCEDURE listar_eventos_pos_data(data_aux date) AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT * FROM evento where cast(data_hora as date) > data_aux LOOP
        RAISE NOTICE '%:%', rec.id, rec.data_hora;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';

-- Function para calcular a diferença de idade entre dois participantes:
CREATE OR REPLACE FUNCTION diferenca(participante_id_aux1 integer, participante_id_aux2 integer) RETURNS integer AS
$$
DECLARE
    idade_aux1 integer := 0;
    idade_aux2 integer := 0;
BEGIN
    IF EXISTS(SELECT * FROM participante where id = participante_id_aux1) AND EXISTS(SELECT * FROM participante where id = participante_id_aux2) THEN
        SELECT EXTRACT(YEAR FROM AGE(data_nascimento)) INTO idade_aux1 FROM participante where id = participante_id_aux1;
        SELECT EXTRACT(YEAR FROM AGE(data_nascimento)) INTO idade_aux2 FROM participante where id = participante_id_aux2;
        RETURN abs(idade_aux2 - idade_aux1);
   ELSE
        RAISE NOTICE 'ALGUM (OU ambos) PARTICIPANTE(S) NAO EXISTE(M)';
   END IF;
   RETURN 0;
END;
$$ 
LANGUAGE 'plpgsql';

-- Function para listar todos os participantes de um evento:
CREATE OR REPLACE FUNCTION listar_participantes_evento(id_evento integer) RETURNS TABLE(nome_participante VARCHAR(100)) AS
$$
    BEGIN
        RETURN QUERY(SELECT participante.nome FROM evento_participante INNER JOIN participante ON participante.id = evento_participante.participante_id WHERE evento_participante.evento_id = id_evento);
    END;
$$
LANGUAGE 'plpgsql';

-- Function para listar todos os desejos de um participante:
CREATE OR REPLACE FUNCTION listar_desejos_participante(id_participante integer) RETURNS TABLE(descricao_desejo TEXT, valor_medio money) AS
$$
    BEGIN
        RETURN QUERY(SELECT desejo.descricao, desejo.valor_medio FROM desejo WHERE desejo.participante_id = id_participante);
    END;
$$
LANGUAGE 'plpgsql';

-- Function para listar todos os eventos de um participante:
CREATE OR REPLACE FUNCTION listar_eventos_participante(id_participante integer) RETURNS TABLE(nome_evento VARCHAR(100)) AS
$$
    BEGIN
        RETURN QUERY(SELECT evento.nome FROM evento_participante INNER JOIN evento ON evento.id = evento_participante.evento_id WHERE evento_participante.participante_id = id_participante);
    END;
$$
LANGUAGE 'plpgsql';

-- Function para verificar se um participante está em um evento:
CREATE OR REPLACE FUNCTION participante_esta_em_evento(id_participante integer, id_evento integer) RETURNS BOOLEAN AS
$$
    BEGIN
        RETURN EXISTS(SELECT id FROM evento_participante WHERE evento_id = id_evento AND id_participante = participante_id);
    END;
$$
LANGUAGE 'plpgsql';

-- Function para obter o valor médio total dos desejos de um participante:
CREATE OR REPLACE FUNCTION media_desejos_participante(id_participante integer) RETURNS DECIMAL AS
$$
    BEGIN
        RETURN (SELECT AVG(CAST(valor_medio AS DECIMAL)) AS media FROM desejo WHERE desejo.participante_id = id_participante);
    END;
$$
LANGUAGE 'plpgsql';

-- Procedure para adicionar múltiplos participantes a um evento usando loop:
CREATE OR REPLACE PROCEDURE adicionar_participantes(id_participantes int[], evento_id_aux int) AS
$$
    DECLARE
        id_participante int;
    BEGIN
        FOREACH id_participante IN ARRAY id_participantes LOOP
            IF EXISTS (SELECT 1 FROM participante WHERE participante.id = id_participante) THEN
                IF EXISTS (SELECT 1 FROM evento WHERE evento.id = evento_id_aux) THEN
                    IF NOT EXISTS (SELECT 1 FROM evento_participante WHERE evento_participante.evento_id = evento_id_aux AND evento_participante.participante_id = id_participante) THEN
                        INSERT INTO evento_participante(evento_id, participante_id) VALUES (evento_id_aux, id_participante);
                    ELSE 
                        RAISE NOTICE 'PARTICIPANTE % JA PRESENTE NO EVENTO', id_participante;
                    END IF;
                ELSE
                    RAISE NOTICE 'EVENTO NAO EXISTE';
                END IF;
            ELSE
                RAISE NOTICE 'PARTICIPANTE % NAO EXISTE', id_participante;
            END IF;
        END LOOP; 
    END;
$$
LANGUAGE 'plpgsql';

-- Function para contar o número de participantes em um evento:
CREATE OR REPLACE FUNCTION conta_participantes_evento(id_evento integer) RETURNS int AS
$$
    BEGIN
        RETURN (SELECT COUNT(id) FROM evento_participante WHERE evento_participante.evento_id = id_evento);
    END;
$$
LANGUAGE 'plpgsql';

-- Procedure para atualizar o valor médio de todos os desejos de um participante usando loop:
-- Function para verificar se um desejo excede um valor específico:
CREATE OR REPLACE FUNCTION desejo_excede_valor(id_desejo integer, valor_maximo DECIMAL) RETURNS BOOLEAN AS
$$
    DECLARE
        valor_desejo money := (SELECT valor_medio FROM desejo WHERE desejo.id = id_desejo);
    BEGIN
        IF (CAST(valor_desejo AS DECIMAL) > valor_maximo) THEN
            RETURN TRUE;
        ELSE    
            RETURN FALSE;
        END IF;
    END;
$$
LANGUAGE 'plpgsql';

-- Procedure para adicionar múltiplos desejos para um participante usando loop:
-- Validação e Máscara de CPF   
CREATE OR REPLACE FUNCTION cpf_valido(cpf TEXT) RETURNS TEXT AS
$$
    DECLARE
        soma INT;
        digito1 INT;
        digito2 INT;
        i INT;
    BEGIN
        IF (NOT regexp_like(cep, '\d{11}')) THEN
            RAISE NOTICE 'CPF INVALIDO';
            RETURN '';
        END IF;

        IF (cpf = repeat(substr(cpf, 1, 1), 11)) THEN
            RAISE NOTICE 'CPF INVALIDO';
            RETURN '';
        END IF;

        soma := 0;
        FOR i IN 1..9 LOOP
            soma := soma + (CAST(substr(cpf, i, 1) AS INT) * (11 - i));
        END LOOP;

        digito1 := (soma * 10) % 11;
        IF (digito1 = 10) THEN
            digito1 := 0;
        END IF;

        soma := 0;
        FOR i IN 1..10 LOOP
            soma := soma + (CAST(substr(cpf, i, 1) AS INT) * (12 - i));
        END LOOP;

        digito2 := (soma * 10) % 11;
        IF (digito2 = 10) THEN
            digito2 := 0;
        END IF;

        IF (digito1 <> CAST(substr(cpf, 10, 1) AS INT) OR
        digito2 <> CAST(substr(cpf, 11, 1) AS INT)) THEN
            RAISE NOTICE 'CPF INVALIDO';
            RETURN '';
        END IF;

        RETURN format('%s.%s.%s-%s',
                    substr(cpf, 1, 3),
                    substr(cpf, 4, 3),
                    substr(cpf, 7, 3),
                    substr(cpf, 10, 2));
    END;
$$ 
LANGUAGE 'plpgsql';

-- Máscara de Telefone
CREATE OR REPLACE FUNCTION mascara_telefone(telefone TEXT) RETURNS TEXT AS
$$
    BEGIN
        IF (NOT regexp_like(telefone, '\d{8}|\d{9}|\d{11}|\d{13}')) THEN
            RAISE NOTICE 'TELEFONE INVALIDO';
            RETURN '';
        ELSIF (LENGTH(telefone) = 8) THEN
            RETURN FORMAT('9%s-%s',
                    substr(telefone, 1, 4),
                    substr(telefone, 5, 4));
        ELSIF (LENGTH(telefone) = 9) THEN
            RETURN FORMAT('%s-%s',
                    substr(telefone, 1, 5),
                    substr(telefone, 6, 4));
        ELSIF (LENGTH(telefone) = 11) THEN
            RETURN FORMAT('(%s) %s-%s',
                    substr(telefone, 1, 2),
                    substr(telefone, 3, 5),
                    substr(telefone, 8, 4));
        ELSE
            RETURN FORMAT('+%s (%s) %s-%s',
                    substr(telefone, 1, 2),
                    substr(telefone, 3, 2),
                    substr(telefone, 5, 5),
                    substr(telefone, 10, 4));
        END IF;
    END;
$$ 
LANGUAGE 'plpgsql';

-- Máscara de Cep. Obs: Validar CEP é possível?
CREATE OR REPLACE FUNCTION mascara_cep(cep TEXT) RETURNS TEXT AS
$$
    BEGIN
        IF (NOT regexp_like(cep, '\d{8}')) THEN 
            RAISE NOTICE 'CEP INVALIDO';
            RETURN '';
        END IF;

        RETURN FORMAT('%s-%s',
                substr(cep, 1, 5),
                substr(cep, 6, 3));
    END;
$$ 
LANGUAGE 'plpgsql';
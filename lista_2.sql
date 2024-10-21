--1 Criar uma stored procedure para listar todos os alunos.
CREATE OR REPLACE FUNCTION listar_todos_alunos() RETURNS TABLE(nome VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT alunos.nome AS nome FROM alunos);
    END;
$$ LANGUAGE 'plpgsql';

--2 Criar uma stored procedure para listar todos os cursos.
CREATE OR REPLACE FUNCTION listar_todos_cursos() RETURNS TABLE(nome VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome AS nome FROM cursos);
    END;
$$ LANGUAGE 'plpgsql';

--3 Criar uma stored procedure para listar todas as matrículas de um aluno.
CREATE OR REPLACE FUNCTION listar_todas_matriculas(id_aluno_aux INT) RETURNS TABLE(nome_aluno VARCHAR(100), nome_curso VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT alunos.nome AS nome_aluno, cursos.nome AS nome_curso FROM alunos INNER JOIN matriculas ON matriculas.aluno_id = alunos.id INNER JOIN cursos ON cursos.id = matriculas.curso_id WHERE alunos.id = id_aluno_aux);
    END;
$$ LANGUAGE 'plpgsql';

--4 Criar uma stored procedure para listar todos os professores.
CREATE OR REPLACE FUNCTION listar_todos_professores() RETURNS TABLE(nome VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT professores.nome AS nome FROM professores);
    END;
$$ LANGUAGE 'plpgsql';

--5 Criar uma stored procedure para atualizar a especialidade de um professor.
CREATE OR REPLACE PROCEDURE atualizar_especialidade_professor(id_professor_aux INTEGER, especialidade_nova VARCHAR(100)) AS 
$$
    BEGIN
        UPDATE professores SET especialidade = especialidade_nova WHERE id = id_professor_aux;
    END;
$$ LANGUAGE 'plpgsql';

--6 Criar uma stored procedure para deletar um curso pelo ID.
CREATE OR REPLACE PROCEDURE deletar_curso(id_curso_aux INTEGER) AS 
$$
    BEGIN
        BEGIN
            DELETE FROM matriculas WHERE matriculas.curso_id = id_curso_aux;
            DELETE FROM cursos WHERE id = id_curso_aux;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'ERRO AO TENTAR DELETAR';
        END;
    END;
$$ LANGUAGE 'plpgsql';

--7 Criar uma stored procedure para listar todos os alunos matriculados em um curso.
CREATE OR REPLACE FUNCTION listar_alunos_no_curso(id_curso_aux INTEGER) RETURNS TABLE(nome VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT alunos.nome FROM alunos INNER JOIN matriculas ON matriculas.aluno_id = alunos.id WHERE matriculas.curso_id = id_curso_aux);
    END
$$ LANGUAGE 'plpgsql';

--8 Criar uma stored procedure para contar o número de alunos em um curso.
CREATE OR REPLACE FUNCTION contar_alunos_curso(id_curso_aux INTEGER) RETURNS INTEGER AS
$$
    BEGIN
        RETURN (SELECT COUNT(alunos.id) AS quantidade_alunos FROM alunos INNER JOIN matriculas ON matriculas.aluno_id = alunos.id WHERE matriculas.curso_id = id_curso_aux);
    END
$$ LANGUAGE 'plpgsql';

--9 Criar uma stored procedure para listar todos os cursos de um professor.
CREATE OR REPLACE FUNCTION cursos_de_professor(id_professor_aux INTEGER) RETURNS TABLE(nome VARCHAR(100)) AS
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome FROM cursos WHERE cursos.professor_id = id_professor_aux);
    END
$$ LANGUAGE 'plpgsql';


--10 Criar uma stored procedure para calcular a idade média dos alunos.
CREATE OR REPLACE FUNCTION calcular_idade_media() RETURNS INTEGER AS 
$$
    BEGIN
        RETURN (SELECT AVG(EXTRACT (year FROM (AGE(alunos.data_nascimento)))) FROM alunos);
    END;
$$ LANGUAGE 'plpgsql';


--11 Criar uma stored procedure para listar todos os cursos com mais de um determinado número de alunos matriculados.
CREATE OR REPLACE FUNCTION listar_cursos_com_minimo(quantidade_alunos INTEGER) RETURNS TABLE(nome VARCHAR(100), qtd_alunos BIGINT) AS 
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome, count(matriculas.id) as qtd_alunos FROM cursos LEFT JOIN matriculas ON matriculas.curso_id = cursos.id GROUP BY cursos.id HAVING count(matriculas.id) > quantidade_alunos);
    END;
$$ LANGUAGE 'plpgsql';

--12 Criar uma stored procedure para atualizar a descrição de um curso e tratar exceções.
CREATE OR REPLACE PROCEDURE alterar_descricao_curso(nova_descricao VARCHAR(100), id_curso_aux INTEGER) AS
$$
    BEGIN
        BEGIN
            UPDATE cursos SET nome = nova_descricao WHERE id = id_curso_aux;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'ERRO AO TENTAR ATUALIZAR';
        END;
    END
$$ LANGUAGE 'plpgsql';

--13 Criar uma stored procedure para calcular a média de idade dos alunos por curso.
CREATE OR REPLACE FUNCTION calcular_idade_media_curso(id_curso_aux INTEGER) RETURNS INTEGER AS 
$$
    BEGIN
        RETURN (SELECT AVG(EXTRACT (year FROM (AGE(alunos.data_nascimento)))) FROM alunos INNER JOIN matriculas ON matriculas.aluno_id = alunos.id WHERE matriculas.curso_id = id_curso_aux);
    END;
$$ LANGUAGE 'plpgsql';

--14 Criar uma stored procedure para transferir um aluno de um curso para outro.
CREATE OR REPLACE PROCEDURE transferir_aluno(id_aluno_aux INTEGER, id_curso_inicial INTEGER, id_curso_final INTEGER) AS
$$
    BEGIN
        IF NOT EXISTS(SELECT id FROM matriculas WHERE aluno_id = id_aluno_aux AND curso_id = id_curso_inicial) THEN
            RAISE NOTICE 'ALUNO NÃO MATRICULADO NO CURSO INICIAL';
        ELSIF EXISTS (SELECT id FROM matriculas WHERE aluno_id = id_aluno_aux AND curso_id = id_curso_final) THEN
            RAISE NOTICE 'ALUNO JÁ MATRICULADO NO CURSO FINAL';
        ELSE
            UPDATE matriculas SET curso_id = id_curso_final WHERE aluno_id = id_aluno_aux AND curso_id = id_curso_inicial;
        END IF;
    END
$$ LANGUAGE 'plpgsql';

--15 Criar uma stored procedure para calcular a quantidade de alunos por curso e tratar exceções.
CREATE OR REPLACE FUNCTION quantidade_alunos_por_curso() RETURNS TABLE(nome_curso VARCHAR(100), quantidade_alunos BIGINT) AS
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome AS nome, COUNT(matriculas.aluno_id) AS quantidade_alunos FROM cursos LEFT JOIN matriculas ON matriculas.curso_id = cursos.id GROUP BY cursos.id);
    END
$$ LANGUAGE 'plpgsql';

--16 Criar uma stored procedure para listar todos os alunos que não estão matriculados em nenhum curso.
CREATE OR REPLACE FUNCTION alunos_nao_matriculados() RETURNS TABLE(nome VARCHAR(100)) AS
$$
    BEGIN
        RETURN QUERY (SELECT alunos.nome FROM alunos LEFT JOIN matriculas ON matriculas.aluno_id = alunos.id WHERE matriculas.id IS NULL);
    END;
$$ LANGUAGE 'plpgsql';

--17 Criar uma stored procedure para calcular a média de idade dos professores.
CREATE OR REPLACE FUNCTION calcular_idade_media_professores() RETURNS INTEGER AS 
$$
    BEGIN
        RETURN (SELECT AVG(EXTRACT (year FROM (AGE(professores.data_nascimento)))) FROM professores WHERE data_nascimento IS NOT NULL);
    END;
$$ LANGUAGE 'plpgsql';

--18 Criar uma stored procedure para listar todos os cursos e seus respectivos professores.
CREATE OR REPLACE FUNCTION listar_cursos_professores() RETURNS TABLE(nome_curso VARCHAR(100), nome_professor VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome as nome_curso, professores.nome as nome_professor FROM cursos INNER JOIN professores ON professores.id = cursos.professor_id);
    END;
$$ LANGUAGE 'plpgsql';

--19 Criar uma stored procedure para atualizar o professor de um curso.
CREATE OR REPLACE PROCEDURE alterar_professor_curso(id_curso_aux INTEGER, id_professor_aux INTEGER) AS
$$
    BEGIN
        BEGIN
            UPDATE cursos SET professor_id = id_professor_aux WHERE cursos.id = id_curso_aux;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'ERRO AO ATUALIZAR CURSO';
        END;
    END
$$ LANGUAGE 'plpgsql';

--20 Criar uma stored procedure para listar todos os cursos ministrados por um professor específico.
CREATE OR REPLACE FUNCTION listar_cursos_professor(id_professor_aux INTEGER) RETURNS TABLE(nome VARCHAR(100)) AS
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome FROM cursos WHERE cursos.professor_id = id_professor_aux);
    END
$$ LANGUAGE 'plpgsql';

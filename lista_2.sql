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
--8 Criar uma stored procedure para contar o número de alunos em um curso.
--9 Criar uma stored procedure para listar todos os cursos de um professor.
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
--13 Criar uma stored procedure para calcular a média de idade dos alunos por curso.
--14 Criar uma stored procedure para transferir um aluno de um curso para outro.
--15 Criar uma stored procedure para calcular a quantidade de alunos por curso e tratar exceções.
--16 Criar uma stored procedure para listar todos os alunos que não estão matriculados em nenhum curso.
--17 Criar uma stored procedure para calcular a média de idade dos professores.
--18 Criar uma stored procedure para listar todos os cursos e seus respectivos professores.
CREATE OR REPLACE FUNCTION listar_cursos_professores() RETURNS TABLE(nome_curso VARCHAR(100), nome_professor VARCHAR(100)) AS 
$$
    BEGIN
        RETURN QUERY (SELECT cursos.nome as nome_curso, professores.nome as nome_professor FROM cursos INNER JOIN professores ON professores.id = cursos.professor_id);
    END;
$$ LANGUAGE 'plpgsql';

--19 Criar uma stored procedure para atualizar o professor de um curso.
--20 Criar uma stored procedure para listar todos os cursos ministrados por um professor específico.

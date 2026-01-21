CREATE DATABASE gestao_estoque;

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

CREATE TABLE fornecedores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150)
);

CREATE TABLE unidades_medida (
    id SERIAL PRIMARY KEY,
    sigla VARCHAR(10) NOT NULL UNIQUE,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    cargo VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE local_estoque (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);


CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco NUMERIC(10,2) NOT NULL,
    categoria_id INT NOT NULL,
    fornecedor_id INT NOT NULL,
    unidade_medida_id INT NOT NULL,
    estoque_minimo INT DEFAULT 0,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id),
    FOREIGN KEY (unidade_medida_id) REFERENCES unidades_medida(id)
);



CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    produto_id INT NOT NULL,
    local_estoque_id INT NOT NULL,
    quantidade_atual INT NOT NULL DEFAULT 0,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (produto_id) REFERENCES produtos(id),
    FOREIGN KEY (local_estoque_id) REFERENCES local_estoque(id),
    UNIQUE (produto_id, local_estoque_id)
);



CREATE TABLE movimentacoes (
    id SERIAL PRIMARY KEY,
    produto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    local_estoque_id INT NOT NULL,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('ENTRADA','SAIDA')),
    quantidade INT NOT NULL CHECK (quantidade > 0),
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT,

    FOREIGN KEY (produto_id) REFERENCES produtos(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (local_estoque_id) REFERENCES local_estoque(id)
);



INSERT INTO categorias (nome, descricao) VALUES
('Informática','Equipamentos'),
('Escritório','Materiais administrativos'),
('Elétrica','Materiais elétricos'),
('Ferramentas','Ferramentas diversas'),
('Segurança','EPIs'),
('Limpeza','Produtos limpeza'),
('Automação','Automação industrial'),
('Mecânica','Peças mecânicas'),
('Papelaria','Papelaria'),
('Logística','Logística');

INSERT INTO fornecedores (nome, cnpj, telefone, email) VALUES
('Tech Brasil','12.345.678/0001-90','(11)1111-1111','tech@br.com'),
('OfficeMax','23.456.789/0001-01','(21)2222-2222','office@br.com'),
('EletroSul','34.567.890/0001-12','(51)3333-3333','eletro@br.com'),
('Ferramentas Pro','45.678.901/0001-23','(31)4444-4444','ferr@br.com'),
('SafeWork','56.789.012/0001-34','(41)5555-5555','epi@br.com');

INSERT INTO unidades_medida (sigla, descricao) VALUES
('UN','Unidade'),
('CX','Caixa'),
('KG','Quilograma'),
('LT','Litro');

INSERT INTO usuarios (nome, email, cargo) VALUES
('Admin','admin@empresa.com','Administrador'),
('João Silva','joao@empresa.com','Almoxarife'),
('Maria Souza','maria@empresa.com','Analista');

INSERT INTO local_estoque (nome, descricao) VALUES
('Depósito Central','Principal'),
('Filial Norte','Unidade Norte'),
('Filial Sul','Unidade Sul');

INSERT INTO produtos
(nome, descricao, preco, categoria_id, fornecedor_id, unidade_medida_id, estoque_minimo)
VALUES
('Mouse USB','Mouse óptico',45.90,1,1,1,20),
('Teclado USB','Teclado padrão',79.90,1,1,1,15),
('Monitor 24','Monitor LED',899.90,1,1,1,5),
('Papel A4','Resma A4',32.50,9,1,2,30);

INSERT INTO estoque (produto_id, local_estoque_id, quantidade_atual) VALUES
(1,1,100),
(2,1,80),
(3,1,10),
(4,2,200);


CREATE OR REPLACE FUNCTION fn_atualiza_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM estoque
        WHERE produto_id = NEW.produto_id
          AND local_estoque_id = NEW.local_estoque_id
    ) THEN
        INSERT INTO estoque (produto_id, local_estoque_id, quantidade_atual)
        VALUES (NEW.produto_id, NEW.local_estoque_id, 0);
    END IF;

    IF NEW.tipo = 'ENTRADA' THEN
        UPDATE estoque
        SET quantidade_atual = quantidade_atual + NEW.quantidade
        WHERE produto_id = NEW.produto_id
          AND local_estoque_id = NEW.local_estoque_id;

    ELSE
        IF (
            SELECT quantidade_atual FROM estoque
            WHERE produto_id = NEW.produto_id
              AND local_estoque_id = NEW.local_estoque_id
        ) < NEW.quantidade THEN
            RAISE EXCEPTION 'Estoque insuficiente';
        END IF;

        UPDATE estoque
        SET quantidade_atual = quantidade_atual - NEW.quantidade
        WHERE produto_id = NEW.produto_id
          AND local_estoque_id = NEW.local_estoque_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT ON movimentacoes
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_estoque();


CREATE OR REPLACE FUNCTION registrar_movimentacao(
    p_produto_id INT,
    p_usuario_id INT,
    p_local_estoque_id INT,
    p_tipo VARCHAR,
    p_quantidade INT,
    p_observacao TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO movimentacoes (
        produto_id,
        usuario_id,
        local_estoque_id,
        tipo,
        quantidade,
        observacao
    )
    VALUES (
        p_produto_id,
        p_usuario_id,
        p_local_estoque_id,
        p_tipo,
        p_quantidade,
        p_observacao
    );
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE VIEW vw_historico_movimentacoes AS
SELECT
    m.data_movimentacao,
    p.nome AS produto,
    m.tipo,
    m.quantidade,
    l.nome AS local,
    m.observacao
FROM movimentacoes m
JOIN produtos p ON p.id = m.produto_id
JOIN local_estoque l ON l.id = m.local_estoque_id
ORDER BY m.data_movimentacao DESC;

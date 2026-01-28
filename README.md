gestao_estoque.sql

Sistema de Gestão de Estoque em PostgreSQL

Sistema de Gestão de Estoque em PostgreSQL

Projeto de Gestão de Estoque desenvolvido inteiramente em SQL (PostgreSQL), com foco em boas práticas de modelagem de dados, integridade referencial e uso profissional de funções, triggers e views. O sistema simula um cenário real de controle de entradas e saídas de produtos, concentrando as regras críticas diretamente no banco de dados.

O projeto foi desenvolvido como case de portfólio, com o objetivo de demonstrar domínio de lógica de banco de dados, implementação de regras de negócio no nível do banco e organização profissional de scripts SQL, sem dependência de uma camada de aplicação.

Objetivo do Projeto

O objetivo do projeto é criar um sistema de estoque capaz de controlar produtos e locais de armazenamento, registrar movimentações de entrada e saída e atualizar automaticamente o saldo de estoque por meio de triggers. Além disso, o sistema garante a integridade e a consistência dos dados e disponibiliza views analíticas, incluindo uma visão financeira consolidada.

Todo o controle crítico do sistema ocorre diretamente no banco de dados, assegurando previsibilidade, centralização das regras de negócio e redução de inconsistências.

Tecnologias Utilizadas

O projeto foi desenvolvido utilizando PostgreSQL como sistema gerenciador de banco de dados, com uso de SQL e PL/pgSQL para definição de tabelas, funções, triggers e views. Os testes foram realizados em ambiente local utilizando o pgAdmin 4.

Estrutura do Projeto
sql/
├── 01_schema.sql              # Criação das tabelas
├── 02_dados_base.sql          # Dados iniciais (opcional)
├── 03_triggers_functions.sql  # Funções e triggers
├── 04_views.sql               # Views analíticas
README.md

A separação dos scripts segue uma organização lógica, facilitando a leitura, manutenção e execução do projeto.

Principais Entidades

O modelo de dados é composto pelas entidades produtos, responsáveis pelo cadastro dos itens comercializados; locais_estoque, que representam os pontos físicos de armazenamento; estoque, que mantém a quantidade atual de cada produto por local; movimentacoes, que registram o histórico de entradas e saídas; e usuarios, responsáveis pelas operações realizadas no sistema.

Essa modelagem permite rastreabilidade completa das movimentações e consistência das informações armazenadas.

Arquitetura de Regras de Negócio

A atualização do estoque segue uma arquitetura limpa e centralizada no banco de dados. A função registrar_movimentacao é responsável por validar os dados de entrada e registrar a movimentação na tabela movimentacoes, sem alterar diretamente o saldo de estoque.

A atualização efetiva do estoque é realizada exclusivamente pelo trigger trg_atualiza_estoque, que é acionado após a inserção de uma movimentação. Esse trigger decide automaticamente se deve realizar um INSERT ou UPDATE na tabela estoque, garantindo que toda movimentação tenha impacto direto e consistente no saldo armazenado.

Essa abordagem evita duplicidade de regras, reduz erros e garante previsibilidade no comportamento do sistema.

Função Principal

A função registrar_movimentacao(...) é responsável por registrar qualquer entrada ou saída de produto no sistema. Ela valida o tipo de movimentação (ENTRADA ou SAIDA), registra o usuário responsável e delega a atualização do estoque ao trigger, mantendo uma separação clara de responsabilidades.

Exemplo de uso:

SELECT registrar_movimentacao(
    1, -- produto_id
    1, -- local_estoque_id
    1, -- usuario_id
    'ENTRADA',
    10,
    'Compra inicial'
);
Trigger de Atualização de Estoque

O trigger de atualização de estoque é executado AFTER INSERT na tabela movimentacoes. Caso já exista um registro de estoque para o produto e local informados, o sistema realiza um UPDATE; caso contrário, um novo registro é criado por meio de INSERT. Essa lógica garante que nunca haja movimentações sem reflexo no estoque.

Views Criadas

O projeto disponibiliza uma view de estoque atual, que apresenta o produto, o local de armazenamento e a quantidade disponível, além de uma view financeira, que consolida o total de entradas, total de saídas e o saldo financeiro por produto. Essas views simulam relatórios utilizados por áreas administrativas e financeiras em ambientes corporativos.

Testes

O sistema foi testado com entradas sucessivas de produtos, saídas com validação de saldo disponível, criação automática de registros de estoque inexistentes e registro do usuário responsável por cada movimentação, garantindo consistência e confiabilidade dos dados.

Como Executar o Projeto

Para executar o projeto, é necessário criar um banco de dados no PostgreSQL e executar os scripts SQL na seguinte ordem:

01_schema.sql
02_dados_base.sql  -- opcional
03_triggers_functions.sql
04_views.sql

Após a execução dos scripts, o sistema pode ser operado por meio da função registrar_movimentacao.

Diferenciais do Projeto

O projeto se destaca pela implementação das regras críticas diretamente no banco de dados, uso profissional de triggers e funções, tratamento de cenários reais como estoque inexistente e organização clara e documentada dos scripts. Trata-se de um case sólido de SQL, adequado para portfólio profissional.

Observações Finais

Este projeto foi desenvolvido com foco em qualidade, clareza e boas práticas, simulando demandas comuns do mercado em sistemas de controle de estoque e demonstrando domínio de SQL em nível profissional.

Desenvolvido por Marcus Viniccius Araujo Barreto

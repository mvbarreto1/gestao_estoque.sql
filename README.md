Sistema de Gestão de Estoque em PostgreSQL

Este projeto consiste em um sistema de gestão de estoque desenvolvido inteiramente em SQL (PostgreSQL), com foco em boas práticas de modelagem de dados, integridade referencial e uso profissional de funções, triggers e views.

O sistema simula um cenário real de controle de entradas e saídas de produtos, concentrando todas as regras críticas diretamente no banco de dados, sem dependência de uma camada de aplicação. O projeto foi desenvolvido como case de portfólio, demonstrando domínio de lógica de banco de dados, regras de negócio no nível do banco e organização profissional de scripts SQL.

Objetivo do Projeto

Criar um sistema de estoque capaz de:

Controlar produtos e locais de armazenamento

Registrar movimentações de entrada e saída

Atualizar automaticamente o estoque por meio de trigger

Garantir integridade e consistência dos dados

Disponibilizar views analíticas, incluindo visão financeira

Todo o controle crítico do sistema ocorre no banco de dados, garantindo previsibilidade, consistência e centralização das regras de negócio.

Tecnologias Utilizadas

PostgreSQL

SQL / PLpgSQL

pgAdmin 4 (ambiente de testes)

Estrutura do Projeto
sql/
├── 01_schema.sql              # Criação das tabelas
├── 02_dados_base.sql          # Dados iniciais (opcional)
├── 03_triggers_functions.sql  # Funções e triggers
├── 04_views.sql               # Views analíticas
README.md
Principais Entidades

produtos – Cadastro de produtos

locais_estoque – Locais físicos de armazenamento

estoque – Quantidade atual por produto e local

movimentacoes – Histórico de entradas e saídas

usuarios – Responsáveis pelas movimentações

Arquitetura de Regras de Negócio
Atualização de Estoque (Ponto-chave do Projeto)

A atualização do estoque segue uma arquitetura limpa e centralizada no banco de dados.

A função registrar_movimentacao é responsável por:

Validar os dados de entrada

Registrar a movimentação na tabela movimentacoes

O trigger trg_atualiza_estoque:

É o único responsável por atualizar a tabela estoque

Decide automaticamente entre INSERT ou UPDATE

Garante que toda movimentação tenha reflexo direto no estoque

Essa abordagem evita duplicidade de regras e garante previsibilidade no comportamento do sistema.

Função Principal
registrar_movimentacao(...)

Responsável por registrar qualquer entrada ou saída de produto.

Características:

Validação do tipo de movimentação (ENTRADA / SAIDA)

Registro do usuário responsável

Não altera o estoque diretamente (responsabilidade do trigger)

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

Executado AFTER INSERT na tabela movimentacoes.

Regras aplicadas:

Se o estoque existir → UPDATE

Se o estoque não existir → INSERT

Essa lógica garante que nunca haja movimentação sem impacto no estoque.

Views Criadas
View de Estoque Atual

Apresenta:

Produto

Local de estoque

Quantidade atual

View Financeira

Apresenta:

Total de entradas

Total de saídas

Saldo financeiro por produto

Essas views simulam relatórios utilizados por áreas administrativas e financeiras.

Testes

O projeto foi testado com os seguintes cenários:

Entradas sucessivas de produtos

Saídas com validação de saldo disponível

Criação automática de estoque inexistente

Registro de usuário responsável pela movimentação

Como Executar o Projeto

Crie um banco de dados no PostgreSQL

Execute os scripts na seguinte ordem:

01_schema.sql

02_dados_base.sql (opcional)

03_triggers_functions.sql

04_views.sql

Utilize a função registrar_movimentacao para operar o sistema

Diferenciais do Projeto

Regras críticas implementadas diretamente no banco

Uso profissional de triggers e funções

Tratamento de cenários reais (estoque inexistente)

Código organizado, modular e documentado

Ideal como case SQL para portfólio profissional

Considerações Finais

Este projeto foi desenvolvido com foco em qualidade, clareza e boas práticas, simulando demandas comuns do mercado em sistemas de controle de estoque e demonstrando domínio de SQL em nível profissional.

Desenvolvido por Marcus Viniccius Araujo Barreto

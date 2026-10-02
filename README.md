# AutoMarketplace v1.0 — pacote consolidado v4

Esta versão substitui os pacotes anteriores da etapa 1. Ela reúne o marketplace de compra e venda, locação, painel do lojista, painel da locadora e painel administrativo na mesma base.

## Correções consolidadas

- conflito de `Role` no `DataInitializer.java` removido;
- imports `Bean` e `Configuration` corrigidos;
- comunicação frontend/backend alterada para proxy do Vite em `/api`;
- porta do frontend fixada em `127.0.0.1:5173` com `strictPort`;
- CORS local revisado;
- `api.ts` refeito e validado, incluindo template strings de JWT e `fetch`;
- dependências do frontend fixadas em versões conhecidas em vez de `latest`;
- testes automáticos do backend adicionados com banco H2 em memória;
- instalador agora executa `npm run build` e `mvn test` antes de iniciar;
- teste final de login passa pelo mesmo proxy usado pelo navegador.

## Funções presentes nesta etapa

### Consumidor
- catálogo público de veículos;
- busca por marca/modelo/versão;
- filtro por cidade;
- geração de lead de interesse;
- WhatsApp da loja;
- formulário para vender veículo para lojas;
- catálogo de locação;
- solicitação de reserva de locação.

### Lojista
- login JWT;
- painel protegido;
- consulta do próprio estoque;
- cadastro de veículo;
- consulta de leads recebidos.

### Locadora
- login JWT;
- painel protegido;
- consulta da frota;
- cadastro de veículo para locação;
- consulta de solicitações de reserva.

### Administrador
- login JWT;
- dashboard com métricas;
- consulta de lojas;
- consulta de veículos;
- consulta de leads;
- consulta de frota e solicitações de locação.

## Banco de dados

Produção/local: PostgreSQL 16 via Docker.

Os testes automáticos usam H2 em memória, portanto o backend é compilado e testado antes da abertura da aplicação.

## Primeira execução

1. Extraia o ZIP inteiro para uma nova pasta.
2. Feche as janelas antigas do AutoMarketplace que estiverem abertas.
3. Clique com o botão direito em `INSTALAR_E_INICIAR.bat` e escolha **Executar como administrador**.
4. O instalador verifica Java 21, Maven, Node.js, WSL 2 e Docker Desktop.
5. Em seguida executa automaticamente:
   - `npm install`;
   - `npm run build`;
   - `mvn test`;
   - PostgreSQL;
   - backend;
   - frontend;
   - teste do proxy;
   - teste do login.
6. Se tudo passar, a página de login abre em:

`http://127.0.0.1:5173/login`

## Próximas execuções

Depois que tudo estiver instalado, use `INICIAR_WINDOWS.bat`.

Para conferir uma instalação que já está em execução, use `TESTAR_APLICATIVO.bat`.

## Contas de demonstração

**Lojista**  
E-mail: `lojista@automarketplace.local`  
Senha: `Loja@123`

**Locadora**  
E-mail: `locadora@automarketplace.local`  
Senha: `Locadora@123`

**Administrador**  
E-mail: `admin@automarketplace.local`  
Senha: `Admin@123`

## Portas utilizadas

- Frontend: `5173`
- Backend: `8080`
- PostgreSQL: `5432`

## Observação sobre versões anteriores

Não copie arquivos manualmente das versões v1, v2 ou v3 para esta pasta. Use esta v4 como uma instalação nova e completa. O volume PostgreSQL existente pode ser reutilizado normalmente se já tiver sido criado pelo Docker.

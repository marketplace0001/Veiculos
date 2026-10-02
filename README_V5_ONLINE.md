# AutoMarketplace v1.0 — v5 Teste Online Gratuito

Esta versão foi preparada para publicar **frontend React/TypeScript + backend Java/Spring Boot no mesmo endereço**, usando Render Free + PostgreSQL Free.

## Por que esta versão é mais simples

- Um único endereço HTTPS público.
- O celular acessa diretamente, sem notebook ligado.
- Frontend usa `/api`, portanto não há dependência de CORS entre dois domínios.
- O Dockerfile compila frontend e backend juntos.
- `render.yaml` cria o Web Service e o PostgreSQL automaticamente.

## Contas de demonstração

- Administrador: `admin@automarketplace.local` / `Admin@123`
- Lojista: `lojista@automarketplace.local` / `Loja@123`
- Locadora: `locadora@automarketplace.local` / `Locadora@123`

## Publicação gratuita no Render

1. Crie um repositório GitHub vazio, por exemplo `automarketplace-v5`.
2. Envie **todo o conteúdo desta pasta** para a raiz do repositório.
3. Entre no Render e escolha **New > Blueprint**.
4. Conecte o repositório GitHub.
5. O Render detectará `render.yaml`.
6. Confirme a criação do serviço `automarketplace-v5` e do banco `automarketplace-db`, ambos no plano Free.
7. Aguarde o primeiro build. O Dockerfile executa os testes Java durante o build.
8. Quando o deploy concluir, abra a URL `https://automarketplace-v5-....onrender.com` exibida no Render.

## No celular

Abra a URL HTTPS do Render no Chrome/Safari. O notebook pode ficar desligado.

## Limitações do plano gratuito

- O Web Service gratuito pode dormir após inatividade e demorar cerca de um minuto no primeiro acesso.
- O PostgreSQL gratuito do Render tem 1 GB e expira após 30 dias. É apropriado apenas para teste.
- Não use estas credenciais de demonstração em produção real.

## Desenvolvimento local

A versão continua podendo ser usada localmente com Docker/PostgreSQL e Vite. O frontend permanece configurado com proxy local para `http://127.0.0.1:8080` durante `npm run dev`.

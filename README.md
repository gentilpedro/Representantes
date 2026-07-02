# Pedro Dev Representantes

> ⚠️ **Este projeto é um protótipo funcional.** Foi construído a partir de telas do
> Visily para validar fluxos e experiência de uso com representantes de vendas da
> Pedro Dev **Nenhum dado é real** — toda a camada de dados (login, pedidos,
> clientes, agenda, relatórios, sincronização) é servida por repositórios *mock* em
> memória, feitos para simular a futura Web API .NET 10 da empresa. Quando a API real
> existir, basta trocar as implementações em `lib/**/data/repositories/` — as telas não
> precisam mudar.

App em Flutter para representantes comerciais da Pedro Dev, cobrindo:

- Login e dashboard do representante
- Pedidos (lista, novo pedido, catálogo de produtos, carrinho)
- Clientes (lista, favoritos, detalhe financeiro)
- Agenda de visitas com check-in/check-out por GPS
- Relatórios de vendas (gráficos de linha, barra e donut)
- Sincronização automática: pedidos finalizados offline ficam salvos localmente como
  `pending` e são enviados sozinhos assim que a conexão volta (sem precisar tocar em
  "Sincronizar Agora") — rascunhos (`draft`) nunca entram nessa fila
- Perfil / configurações

Feito para rodar tanto em **mobile (Android e iOS)** quanto em **Web**, a partir do
mesmo código-fonte.

## Login (protótipo)

A autenticação é mock: **aceita qualquer código/e-mail e qualquer senha, desde que não
fiquem em branco.** Não existe validação real de credenciais nesta fase. Sugestão para
testar:

| Campo               | Valor de exemplo         |
|---------------------|---------------------------|
| Código ou e-mail    | `88294` (ou qualquer texto) |
| Senha               | `123456` (ou qualquer texto) |

Após o login, o app sempre retorna o mesmo usuário fixo do protótipo: **Ricardo
Santos**, Representante Comercial Sênior, Região Sul.

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable — testado
  com Flutter 3.44.4 / Dart 3.12.2)
- Para rodar no navegador: Chrome ou Edge instalado
- Para rodar em Android: Android Studio + Android SDK, um emulador configurado ou um
  aparelho físico com depuração USB habilitada
- Para rodar em iOS: um Mac com Xcode instalado (não é possível compilar para iOS a
  partir de Windows/Linux — veja seção específica abaixo)

Verifique se o ambiente está pronto com:

```bash
flutter doctor
```

Instale as dependências do projeto:

```bash
flutter pub get
```

## Rodando na Web

```bash
flutter run -d chrome
# ou
flutter run -d edge
```

Isso abre o app no navegador com hot reload. Para gerar um build de produção estático
(pasta `build/web`, publicável em qualquer servidor de arquivos estáticos):

```bash
flutter build web
```

## Rodando no celular

### Android

1. Conecte um aparelho Android via USB com a **depuração USB** ativada (Configurações
   → Opções do desenvolvedor → Depuração USB), ou inicie um emulador pelo Android
   Studio (Device Manager).
2. Confirme que o Flutter enxerga o dispositivo:
   ```bash
   flutter devices
   ```
3. Rode o app:
   ```bash
   flutter run
   ```
   Se houver mais de um dispositivo conectado (ex.: emulador + celular físico), use
   `flutter run -d <device-id>` (o id aparece na saída de `flutter devices`).

Para gerar um instalável (`.apk`) para compartilhar com outra pessoa testar sem passar
pelo `flutter run`:

```bash
flutter build apk --debug
```

O arquivo fica em `build/app/outputs/flutter-apk/app-debug.apk`.

> **Nota:** se `flutter doctor` acusar problema de licenças do Android SDK, rode
> `flutter doctor --android-licenses` e aceite todas antes de compilar para Android.

### iOS

A compilação para iOS **exige um Mac com Xcode** (é uma limitação da Apple, não do
Flutter). Em um Mac, com um iPhone conectado (ou o Simulator do Xcode aberto):

```bash
flutter devices
flutter run
```

Para instalar num iPhone físico é necessária uma conta de desenvolvedor Apple
configurada no Xcode (`ios/Runner.xcworkspace`) para assinatura do app.

## Rodando os testes automatizados

O projeto tem 9 testes de widget cobrindo o fluxo real de cada tela (não apenas
renderização). Para rodar todos:

```bash
flutter test
```

## Estrutura do projeto

```
lib/
  core/                # tema, formatação, storage de sessão, utilitários compartilhados
  features/
    auth/               # login e sessão
    dashboard/          # tela inicial do representante
    orders/             # pedidos, catálogo, carrinho
    clients/            # clientes e detalhe financeiro
    agenda/             # agenda de visitas com GPS
    reports/            # relatórios e gráficos
    sync/                # sincronização offline e notificações
    profile/            # perfil e configurações
test/                  # testes de fluxo (*_flow_test.dart), um por feature
```

Cada feature segue o padrão `domain/` (entidades + interface do repositório) →
`data/` (implementação mock do repositório) → `presentation/` (telas + providers
Riverpod). Essa separação é o que permite trocar os mocks por chamadas reais à Web API
.NET 10 no futuro sem tocar nas telas.

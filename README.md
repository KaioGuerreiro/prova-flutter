# Aplicativo de Controle de Abastecimento e Veículos

Um aplicativo Flutter completo para gerenciar veículos e seus abastecimentos, com autenticação Firebase e persistência de dados.

## 📱 Funcionalidades

### Autenticação

- ✅ Login com Google
- ✅ Login com Facebook
- ✅ Login com E-mail e Senha
- ✅ Registro de novos usuários
- ✅ Logout seguro

### Gerenciamento de Veículos

- ✅ Cadastro de veículos (nome, placa, quilometragem)
- ✅ Edição de veículos
- ✅ Exclusão com confirmação (remove também os abastecimentos relacionados)
- ✅ Validação de placa brasileira
- ✅ Listagem com formatação de números

### Gerenciamento de Abastecimentos

- ✅ Registro de abastecimentos (data, litros, valor, km)
- ✅ Edição de abastecimentos
- ✅ Exclusão com confirmação
- ✅ Date picker nativo para seleção de data
- ✅ Cálculo automático de consumo médio (km/L)
- ✅ Cálculo de preço por litro
- ✅ Formatação de valores em moeda brasileira (R$)
- ✅ Formatação de datas (dd/MM/yyyy)
- ✅ Filtro por veículo

### Interface do Usuário

- ✅ Material Design 3
- ✅ Navegação por abas (Bottom Navigation)
- ✅ Cards com visual moderno
- ✅ Ícones e cores consistentes
- ✅ Feedback visual com SnackBars
- ✅ Diálogos de confirmação
- ✅ Validações em tempo real

## 🔧 Tecnologias Utilizadas

- **Flutter 3.35.2** - Framework de desenvolvimento
- **Dart 3.9.0** - Linguagem de programação
- **Firebase Core** - Infraestrutura Firebase
- **Firebase Auth** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Google Sign-In** - Autenticação com Google
- **Flutter Facebook Auth** - Autenticação com Facebook
- **SQLite (sqflite)** - Banco de dados local (opcional)
- **intl** - Formatação de datas e moedas
- **Provider** - Gerenciamento de estado

## 📦 Instalação

### Pré-requisitos

- Flutter SDK instalado (stable)
- Dart SDK (vem com Flutter)
- Projeto Firebase configurado
- FlutterFire CLI instalado

### Passos

1. Clone o repositório:

```powershell
git clone https://github.com/KaioGuerreiro/prova-flutter.git
cd prova-flutter
```

2. Instale as dependências:

```powershell
flutter pub get
```

3. Configure o Firebase (se ainda não configurado):

```powershell
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Adicionar ao PATH (se necessário)
$env:PATH += ";$([Environment]::GetFolderPath('LocalApplicationData'))\Pub\Cache\bin"

# Configurar Firebase
flutterfire configure
```

4. Execute o aplicativo:

```powershell
# Para Android
flutter run -d android

# Para iOS
flutter run -d ios

# Para Web
flutter run -d chrome

# Para Windows (requer Visual Studio com "Desktop development with C++")
flutter run -d windows
```

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── firebase_options.dart     # Configurações do Firebase
├── models/
│   ├── vehicle.dart         # Modelo de veículo
│   └── refuel.dart          # Modelo de abastecimento
├── screens/
│   ├── login_screen.dart    # Tela de login/registro
│   ├── vehicles_screen.dart # Lista de veículos
│   ├── vehicle_form.dart    # Formulário de veículo
│   ├── refuels_screen.dart  # Lista de abastecimentos
│   └── refuel_form.dart     # Formulário de abastecimento
└── services/
    ├── auth_service.dart     # Serviço de autenticação
    ├── firestore_service.dart # Serviço Firestore
    └── db_helper.dart        # Helper SQLite (opcional)
```

## 🎯 Como Usar

### 1. Primeiro Acesso

- Abra o app e faça login com Google, Facebook ou E-mail
- Se não tiver conta, clique em "Cadastre-se"

### 2. Cadastrar um Veículo

- Na aba "Veículos", clique no botão +
- Preencha: nome, placa e quilometragem
- Clique em "Criar Veículo"

### 3. Registrar um Abastecimento

- Toque no veículo desejado OU
- Vá para aba "Abastecimentos" e selecione um veículo
- Clique no botão +
- Selecione a data (date picker)
- Preencha: litros, valor total e quilometragem atual
- Clique em "Registrar Abastecimento"

### 4. Visualizar Consumo

- Na lista de abastecimentos, você verá:
  - Preço por litro (R$/L)
  - Consumo médio entre abastecimentos (km/L)
  - Valores formatados em moeda brasileira

### 5. Editar ou Excluir

- Clique no ícone de edição (lápis azul) para modificar
- Clique no ícone de exclusão (lixeira vermelha) e confirme

## 🔐 Configuração do Firebase

### Firebase Authentication

Habilite os seguintes métodos de login no console do Firebase:

- Google
- Facebook (opcional)
- E-mail/Senha

### Cloud Firestore

Crie as seguintes coleções:

- `vehicles` - armazena dados dos veículos
- `refuels` - armazena dados dos abastecimentos

### Regras de Segurança do Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /vehicles/{vehicleId} {
      allow read, write: if request.auth != null;
    }
    match /refuels/{refuelId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🧪 Testes

Para executar os testes:

```powershell
flutter test
```

## 📝 Validações Implementadas

### Veículo

- Nome: mínimo 3 caracteres
- Placa: 7 caracteres (formato brasileiro)
- Quilometragem: número positivo

### Abastecimento

- Data: selecionada via date picker
- Litros: número decimal positivo
- Valor: número decimal positivo
- Quilometragem: número inteiro positivo

## 🎨 Formatações

- **Datas**: dd/MM/yyyy (ex: 17/11/2025)
- **Moeda**: R$ #.##0,00 (ex: R$ 250,50)
- **Números**: #.### (ex: 25.430 km)
- **Decimais**: #,##0.00 (ex: 45,30 L)

## 🚀 Melhorias Futuras

- [ ] Gráficos de consumo ao longo do tempo
- [ ] Notificações de manutenção
- [ ] Exportação de relatórios em PDF
- [ ] Modo escuro
- [ ] Múltiplos usuários e compartilhamento de veículos
- [ ] Backup automático
- [ ] Lembretes de troca de óleo/revisão

## 👤 Autor

Desenvolvido como atividade prática de Flutter

## 📄 Observações

- O aplicativo usa Cloud Firestore para persistência em nuvem
- SQLite (sqflite) está disponível como opção de persistência local
- Autenticação obrigatória para usar o app
- As pastas `android/`, `ios/`, `windows/` etc. já estão incluídas no projeto

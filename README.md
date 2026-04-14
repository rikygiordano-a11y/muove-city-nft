# Progetto Ethereum Advanced - Riccardo Giordano

## Descrizione del progetto

Questo progetto consiste nello sviluppo di uno smart contract ERC-721 per una collezione NFT dedicata all’azienda immaginaria **Moove**, attiva nel settore della micro mobilità condivisa.

L’idea del progetto è permettere agli utenti di creare NFT associati a diverse città in cui opera Moove. Ogni NFT riceve caratteristiche personalizzate in base a un numero casuale, così da rendere ogni token unico.

## Obiettivo

L’obiettivo era realizzare uno smart contract in Solidity che rispettasse lo standard **ERC-721** e includesse:

- creazione di NFT
- visualizzazione delle informazioni dei token
- trasferimento degli NFT
- logica di tokenomics
- utilizzo di una casualità non manipolabile
- deploy su testnet
- struttura ordinata del progetto

## Scelta degli strumenti

Per questo progetto ho lavorato principalmente con **Visual Studio Code** per organizzare tutti i file richiesti dalla consegna.

Ho usato anche **Remix IDE** come supporto per compilare, testare rapidamente il contratto e, se necessario, effettuare il deploy in modo più semplice.

Per avere una struttura più completa e professionale, ho aggiunto anche **Hardhat**, utile per la compilazione, i test di base e lo script di deploy.

## Tecnologie utilizzate

- Solidity
- OpenZeppelin
- Chainlink VRF v2.5
- Hardhat
- Remix IDE
- Sepolia Testnet

## Idea sviluppata

La collezione si chiama **Moove City NFT**.

Ogni NFT rappresenta una città in cui opera Moove e contiene le seguenti informazioni:

- `city`: città assegnata al token
- `rarity`: livello di rarità del token
- `hasPrize`: indica se il token assegna un premio speciale
- `randomNumber`: numero casuale usato per generare le caratteristiche
- `mintedAt`: timestamp di creazione del token

Le città disponibili sono:

- Rome
- Milan
- Paris
- Madrid

I livelli di rarità sono:

- Common
- Rare
- Epic
- Legendary

## Funzionalità implementate

### 1. Creazione NFT

Gli utenti possono richiedere la creazione di un nuovo NFT tramite la funzione `requestMint()`.

### 2. Randomicità verificabile

Le caratteristiche del token vengono assegnate tramite **Chainlink VRF**, in modo da usare una fonte di casualità non manipolabile dall’esterno.

### 3. Visualizzazione NFT

La funzione `getNFTDetails(uint256 tokenId)` permette di leggere i dettagli del singolo NFT.

### 4. Informazioni della collezione

La funzione `getCollectionInfo()` restituisce:

- nome collezione
- simbolo
- supply attuale
- supply massima
- prezzo di mint
- richieste pendenti

### 5. Trasferimento NFT

Il trasferimento è gestito dallo standard ERC-721 tramite le funzioni native come `transferFrom` e `safeTransferFrom`.

### 6. Tokenomics

Il contratto include:

- `mintPrice`: prezzo di mint
- `maxSupply`: numero massimo di NFT mintabili
- `withdraw()`: funzione per il prelievo dei fondi da parte del proprietario

### 7. Gestione amministrativa

Il proprietario del contratto può:

- modificare il prezzo di mint
- modificare la base URI
- prelevare i fondi del contratto

## Setup Chainlink VRF

Per integrare il sistema VRF sono stati eseguiti i seguenti passaggi:

- creazione Subscription VRF  
- finanziamento con **0.01 ETH Sepolia**  
- deploy contratto su Sepolia  
- collegamento del contratto come **Consumer**  
- utilizzo di pagamento in token nativo (`nativePayment: true`)  

Questo permette al contratto di richiedere randomness in modo corretto.


## Struttura del progetto

Progetto Ethereum Advanced - Riccardo Giordano  
├── contracts  
│   └── MooveCityNFT.sol  
├── scripts  
│   └── deploy.js  
├── test  
│   └── MooveCityNFT.test.js  
├── .env.example  
├── .gitignore  
├── hardhat.config.js  
├── package.json  
└── README.md

## Test eseguiti

Il progetto è stato testato con Hardhat tramite test automatici.

Comando utilizzato:

`npx hardhat test`

Risultato:

`6 passing`

I test verificano il corretto funzionamento delle principali funzionalità del contratto.

## Contract Deployment

Network: Sepolia Testnet

Contract Address: 0x4C657F2980BceBF5A8270435633fc8938E8814aC

GitHub Repository: https://github.com/rikygiordano-a11y/muove-city-nft.git
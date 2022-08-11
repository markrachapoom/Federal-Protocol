# Federal-Protocol

### The problem The Federal Protocol solves
In Web2 space, there's a popular Escrow service called Escrow.com. There are contract signing websites on Web2 like Docusign (and in Web3 there is Ethsign). However, we haven't yet found a decentralized protocol yet, where you can sign your contracts, which will automatically generate an escrow account with a judge of choice of both signing parties who will interpret the rules in the contract in case a dispute arises. Web2 services are costly and charge high fees.

Usually, escrow judge companies are centralised, but this protocol shall help hyperlocalise escrow dispute judgements between merchandise buyers and sellers.

This protocol aims to solve that.

Protocol: 
<img width="1301" alt="スクリーンショット 2022-08-12 0 51 39" src="https://user-images.githubusercontent.com/4179632/184175880-6f3b92d5-f7d5-429a-9b33-e4ac6d4aa48f.png">


With the Federal Protocol, you can create a contract, and then get the other address to sign it, and in the contract itself, you can put the judge contract's address. When both parties sign the contract, it shall create an escrow wallet with all the parties involved. If both parties agree that product was delivered, the seller and other participants get the money. If one party isn't satisfied, they can choose to sue.

The judge address can either be controlled by a human or could be a contract. If it is a human, the judge will have full control over the escrow funds. To limit judge's powers (of calling judgeRule() function on the escrow wallet), it is advised contracts are made judges instead to act as a layer between escrow wallet and human judges. The judges can be a DAO, the panel of Humans, an AI, or literally anything. Judges can also be totally anonymous. Judges may also earn if they set a commission for themselves.

In this protocol, any judges can join and advertise themselves as the good judges in their own fields, and can build their own reputation so the contract signers choose them! Kinda like how Delaware Court of Chancory is best known for solving cases for Equity based Startups.

# powershell-share
Script in Powershell che permette di creare un utente e di nasconderlo per mezzo del registro, creazione di una cartella e condividerla con l'utente. Aggiungere i permessi Full Control alla cartella appena creata. Abilitare i permessi del Firewall e rendere visibile il computer se è in modalità nascosta.

![image](https://github.com/Davide1986/powershell-share/assets/6768906/9b0c7cef-023f-4c6d-9d2b-4ede80a0c188)

# [PowerShell] - Script per la creazione e condivisione di una cartella e creazione di un utente nascosto che ci può accedere

1) Verifica esistenza dell'utente "spices"
2) Se non esiste l'utente "spices" lo crea
3) Nasconde l'utente "spices" utilizzando la chiave di registro 
4) Verifica se esiste nel percorso "C:\" la cartella "spices"
5) Se non esiste la cartella la crea
6) Aggiunge alla cartella i permessi di sicurezza Full dell'utente appena creato "spices" 
7) Condivide la cartella e aggiunge l'utente "spices" con tutti i permessi di scrittura e lettura
8) Abilita il firewall di windows alla condivisione di file e di stampanti
9) Abilita il firewall alla Individuazione rete da parte del computer

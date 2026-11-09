# AZ-104 kollokvium

Hjelpeside for Fremras AZ-104-kollokvium, ti mandager fra 5. oktober til 7. desember 2026.

**Publisert på:** https://fremra.github.io/az104/

## Tilgang

Repoet og siden er offentlige. Sidene er merket `noindex, nofollow`, så de ikke havner i
søkemotorer.

**Alt som pushes, er offentlig**, også historikken. Derfor skal dette aldri inn i repoet:

- tenantnavn, tenant-id eller subscription-id-er
- brukernavn, passord eller annen innloggingsinfo. Siden sier «får du av Anders»
- supportsaker, kundenavn eller interne notater

Workflowen stopper publiseringen hvis den finner tenantnavnet, tenantdomenet, en GUID eller et
16-sifret tall, men da ligger pushen allerede i repoet. Kjør derfor samme sjekk lokalt i
PowerShell før du pusher:

```powershell
$m = (Select-String .github\workflows\pages.yml -Pattern "^\s*m='(.*)'$").Matches[0].Groups[1].Value
Get-ChildItem -Recurse -File | Where-Object FullName -notmatch '\\\.git|\.woff2$' | Select-String -Pattern $m
```

Ingen treff betyr at du kan pushe.

## Oppbygning

| Sti | Innhold |
|---|---|
| `index.html` | Forsiden: neste møte, arbeidsform, ukeplan, format, opprydding, eksamen, endringslogg |
| `uke-NN/index.html` | Én side per uke: forberedelse (Duffy og Learn), lab, kunnskapssjekk, opprydding |
| `uke-NN/*.json`, `*.bicep` | Fasit til ukas lab. Dette er eneste kopi av lab-filene |
| `assets/` | Felles stilark, skript, favicon og skrifter (Inter og Ovo) |

Det er ingen byggesteg. HTML-filene er kilden og redigeres direkte.

Utseendet følger Fremras designtokens: merkefarge `#eb4f34`, Inter og Ovo.

**Neste møte** på forsiden fylles av `assets/side.js` fra ukeplan-tabellen. Kortet viser
første uke med dato i dag eller senere. Legg til `?dato=2026-10-06` i URL-en for å teste en
annen dato.

## Oppdatere

1. Rediger siden.
2. Legg til et nytt punkt øverst i `<section id="endringslogg">` i `index.html`.
3. Oppdater «Sist oppdatert» og versjonen i footeren på `index.html`.
4. Kjør sjekken over. Commit og push til `main`, så publiserer GitHub Pages automatisk.

### Lab for en ny uke

1. Legg lab-veiledningen inn i `uke-NN/index.html` i stedet for callouten under `<section id="lab">`.
   `uke-01/index.html` viser mønsteret.
2. Legg fasit-filene i `uke-NN/` og lenk til dem under `<section id="fasit">`.
   Kommandoene skrives for PowerShell. Bruker labben variabler eller linjeskift, legg ved boksen
   «Mac eller Linux» slik `uke-01` gjør. Azure-navn står på engelsk (storage account, resource group).
3. Legg `<span class="pill klar">Lab klar</span>` på ukas rad i ukeplanen i `index.html`.

### Kunnskapsspørsmål etter møtet

Bytt ut callouten under `<section id="kunnskapssjekk">` med ett `<details>` per spørsmål:

```html
<details>
  <summary>Spørsmålet</summary>
  <div>Svaret.</div>
</details>
```

## Kilder

Learn-modulene og eksamensinfoen er hentet fra Microsoft Learn 29.09.2026 og kontrollert 01.10.2026.

// AZ-104 · felles skript for alle sidene. To ting: «Neste økt» på forsiden og kopier-knapper på kodeblokker.

(function () {
  'use strict';

  // ------------------------------------------------------------------------
  // Neste økt: første rad i ukeplanen med dato i dag eller senere.
  // Ukeplan-tabellen er eneste kilde. Kortet i HTML viser uke 1 hvis JS ikke kjører.
  // ?dato=2026-10-06 overstyrer dagens dato, til testing.
  // ------------------------------------------------------------------------
  function nesteOkt() {
    const kort = document.getElementById('neste');
    const rader = [...document.querySelectorAll('#ukeplan tbody tr[data-dato]')];
    if (!kort || !rader.length) return;

    const idag = new URLSearchParams(location.search).get('dato') ||
      new Date().toLocaleDateString('sv-SE', { timeZone: 'Europe/Oslo' });
    const rad = rader.find(r => r.dataset.dato >= idag);
    const felt = navn => kort.querySelector('[data-felt="' + navn + '"]');

    if (!rad) {
      felt('nar').textContent = 'Kollokviet er ferdig';
      felt('linje').textContent = 'Takk for ti mandager. Lykke til på eksamen.';
      felt('forb').hidden = true;
      felt('lenke').textContent = 'Til eksamen →';
      felt('lenke').href = '#eksamen';
      felt('ekstra').hidden = true;
      return;
    }

    rad.classList.add('er-neste');
    const tekst = sel => rad.querySelector(sel).textContent.trim();
    const uke = rad.dataset.uke;
    const dag = new Date(rad.dataset.dato + 'T12:00:00')
      .toLocaleDateString('nb-NO', { weekday: 'long', day: 'numeric', month: 'long' });

    felt('nar').textContent = dag.charAt(0).toUpperCase() + dag.slice(1) + ' · Uke ' + uke;
    felt('tema').textContent = tekst('.c-tema a');
    felt('eier').textContent = tekst('.c-eier');
    felt('duffy').textContent = tekst('.c-duffy .sek');
    felt('tid').textContent = tekst('.c-duffy .tid') + ' · ' + tekst('.c-duffy .tid125') + ' på 1,25×';
    felt('lenke').textContent = 'Til uke ' + uke + ' →';
    felt('lenke').href = rad.querySelector('.c-tema a').getAttribute('href');
  }

  // ------------------------------------------------------------------------
  // Kopier-knapp på hver kodeblokk
  // ------------------------------------------------------------------------
  function kopierKnapper() {
    document.querySelectorAll('pre').forEach(pre => {
      const knapp = document.createElement('button');
      knapp.type = 'button';
      knapp.className = 'kopier';
      knapp.textContent = 'Kopier';
      knapp.addEventListener('click', () => {
        const tekst = (pre.querySelector('code') || pre).innerText.replace(/\n$/, '');
        kopier(tekst).then(
          () => { knapp.textContent = 'Kopiert'; },
          () => { knapp.textContent = 'Merk og kopier selv'; }
        ).finally(() => setTimeout(() => { knapp.textContent = 'Kopier'; }, 1500));
      });
      pre.appendChild(knapp);
    });
  }

  function kopier(tekst) {
    if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(tekst);
    return new Promise((ok, feil) => {
      const felt = document.createElement('textarea');
      felt.value = tekst;
      felt.style.position = 'fixed';
      felt.style.opacity = '0';
      document.body.appendChild(felt);
      felt.select();
      const lyktes = document.execCommand('copy');
      felt.remove();
      lyktes ? ok() : feil();
    });
  }

  nesteOkt();
  kopierKnapper();
})();

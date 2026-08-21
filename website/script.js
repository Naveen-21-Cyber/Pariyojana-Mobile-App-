'use strict';

/* ═══════════════════════════════════════════════════════════════════
   PARIYOJANA — Website Script
   Preloader → Cinematic zoom-out → GSAP reveals → Carousel removed
   All interactions, timer demo, BYOK demo, nav, GitHub stars
═══════════════════════════════════════════════════════════════════ */

/* ── GLOBAL STATE ───────────────────────────────────────────────── */
let timerInterval = null;
let timerRunning  = false;
let timerTotal    = 25 * 60;
let timerLeft     = 25 * 60;
let shlokaIdx     = 0;

const SHLOKAS = [
  { s:'योगः कर्मसु कौशलम्',           e:'Excellence in action is true Yoga. — BG 2.50' },
  { s:'कर्मण्येवाधिकारस्ते',             e:'You have a right to your duty, not its fruits. — BG 2.47' },
  { s:'उद्धरेदात्मनात्मानं',              e:'Elevate yourself; do not degrade yourself. — BG 6.5' },
  { s:'नैनं छिन्दन्ति शस्त्राणि',       e:'The soul is unbreakable. Stay resilient. — BG 2.23' },
  { s:'सर्वधर्मान्परित्यज्य',            e:'Surrender doubt and step forward without fear. — BG 18.66' },
];

/* ═══════════════════════════════════════════════════════════════════
   ENTRY POINT — Instant App Initialization
═══════════════════════════════════════════════════════════════════ */
let appInitialized = false;

function launchApp() {
  if (appInitialized) return;
  appInitialized = true;
  initApp();
}

if (document.readyState === 'interactive' || document.readyState === 'complete') {
  launchApp();
} else {
  document.addEventListener('DOMContentLoaded', launchApp);
  window.addEventListener('load', launchApp);
}

/* ═══════════════════════════════════════════════════════════════════
   1. APP INITIALIZATION & GSAP SETUP
═══════════════════════════════════════════════════════════════════ */
function initApp() {
  // Trigger cinematic reveal animation on hero text
  const zoomTarget = document.querySelector('.hero-zoom-target');
  if (zoomTarget) {
    setTimeout(() => {
      zoomTarget.classList.add('zoom-animate');
    }, 60);
  }

  // Initialize all interactive components
  initLenis();
  initGSAP();
  initNav();
  initGitHubStars();
  initGitHubReleases();
  initTimerDemo();
  initNavToggle();
}

/* ═══════════════════════════════════════════════════════════════════
   3. LENIS SMOOTH SCROLL (Ultra-Smooth 120fps Hardware-Accelerated)
═══════════════════════════════════════════════════════════════════ */
function initLenis() {
  if (typeof Lenis === 'undefined') return;
  const lenis = new Lenis({
    duration: 1.0,
    lerp: 0.1,
    smoothWheel: true,
    wheelMultiplier: 1.0,
    touchMultiplier: 1.0,
    infinite: false,
  });

  window.lenis = lenis;

  // Single unified RAF loop via GSAP ticker
  if (typeof gsap !== 'undefined') {
    gsap.ticker.add((time) => {
      lenis.raf(time * 1000);
    });
    gsap.ticker.lagSmoothing(0);
  } else {
    function raf(time) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);
  }
}

/* ═══════════════════════════════════════════════════════════════════
   4. GSAP SCROLL REVEALS
═══════════════════════════════════════════════════════════════════ */
function initGSAP() {
  if (typeof gsap === 'undefined' || typeof ScrollTrigger === 'undefined') {
    // Fallback: reveal all elements immediately
    document.querySelectorAll('.reveal-up,.reveal-left,.reveal-right').forEach(el => {
      el.classList.add('revealed');
    });
    return;
  }

  gsap.registerPlugin(ScrollTrigger);

  // Sync GSAP ScrollTrigger with Lenis smooth scroll
  if (window.lenis) {
    window.lenis.on('scroll', ScrollTrigger.update);
  }

  // Scroll-reveal for .reveal-up, .reveal-left, .reveal-right
  const revealEls = document.querySelectorAll('.reveal-up,.reveal-left,.reveal-right');
  revealEls.forEach((el, i) => {
    ScrollTrigger.create({
      trigger: el,
      start: 'top 88%',
      onEnter: () => {
        gsap.to(el, {
          opacity: 1, y: 0, x: 0, scale: 1,
          duration: 0.75,
          delay: (i % 4) * 0.06,
          ease: 'power3.out',
          force3D: true,
          onStart: () => el.classList.add('revealed'),
        });
      },
      once: true,
    });
  });

  // Stagger feat-cards within grid
  document.querySelectorAll('.feat-grid').forEach(grid => {
    const cards = grid.querySelectorAll('.feat-card');
    ScrollTrigger.create({
      trigger: grid,
      start: 'top 85%',
      onEnter: () => {
        gsap.fromTo(cards,
          { opacity: 0, y: 35, scale: 0.97 },
          { opacity: 1, y: 0, scale: 1, duration: 0.68, stagger: 0.06, ease: 'power3.out', force3D: true }
        );
      },
      once: true,
    });
  });

  // Hero elements stagger after zoom animation settles
  setTimeout(() => {
    const heroEls = document.querySelectorAll('.hero-status-pill,.hero-title-sub,.motto-strip,.hero-sub,.hero-actions,.hero-metrics-bar,.hero-offline-notice,.hero-mockup');
    gsap.fromTo(heroEls,
      { opacity: 0, y: 18 },
      { opacity: 1, y: 0, duration: 0.65, stagger: 0.08, ease: 'power3.out', force3D: true }
    );
  }, 450);
}

/* ═══════════════════════════════════════════════════════════════════
   5. NAVIGATION — scroll-shrink + active link
═══════════════════════════════════════════════════════════════════ */
function initNav() {
  const nav = document.getElementById('nav');
  if (!nav) return;

  // Scroll-shrink effect
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 60);
  }, { passive: true });

  // Active nav link highlighting
  const sections = document.querySelectorAll('section[id], div[id]');
  const navLinks  = document.querySelectorAll('.nav-links a');

  const obs = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        const id = e.target.id;
        navLinks.forEach(a => {
          const href = a.getAttribute('href');
          a.style.color = href === `#${id}` ? 'var(--coral)' : '';
          a.style.background = href === `#${id}` ? 'rgba(255,82,43,0.15)' : '';
        });
      }
    });
  }, { threshold: 0.35 });

  sections.forEach(s => obs.observe(s));
}

/* ── Mobile nav toggle ─────────────────────────────────────────── */
function initNavToggle() {
  const toggle = document.getElementById('navToggle');
  const links  = document.getElementById('navLinks');
  if (!toggle || !links) return;

  toggle.addEventListener('click', () => {
    const open = links.classList.toggle('open');
    toggle.setAttribute('aria-expanded', open);
    // Animate hamburger → X
    const spans = toggle.querySelectorAll('span');
    if (open) {
      spans[0].style.transform = 'rotate(45deg) translate(5px,5px)';
      spans[1].style.opacity   = '0';
      spans[2].style.transform = 'rotate(-45deg) translate(5px,-5px)';
    } else {
      spans.forEach(s => { s.style.transform = ''; s.style.opacity = ''; });
    }
  });

  // Close on link click
  links.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => {
      links.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
      toggle.querySelectorAll('span').forEach(s => { s.style.transform = ''; s.style.opacity = ''; });
    });
  });

  // Close on outside click
  document.addEventListener('click', (e) => {
    if (!toggle.contains(e.target) && !links.contains(e.target)) {
      links.classList.remove('open');
    }
  });
}

/* ═══════════════════════════════════════════════════════════════════
   6. GITHUB STARS & DYNAMIC RELEASES CHANGELOG
═══════════════════════════════════════════════════════════════════ */
function initGitHubStars() {
  const el = document.getElementById('starCount');
  if (!el) return;
  fetch('https://api.github.com/repos/Naveen-21-Cyber/Pariyojana-Mobile-App-', {
    headers: { 'Accept': 'application/vnd.github.v3+json' }
  })
    .then(r => r.json())
    .then(d => {
      if (d.stargazers_count !== undefined) {
        el.textContent = `⭐ ${d.stargazers_count}`;
      }
    })
    .catch(() => { el.textContent = '⭐ Star'; });
}

let cachedReleases = [];

function initGitHubReleases() {
  fetch('https://api.github.com/repos/Naveen-21-Cyber/Pariyojana-Mobile-App-/releases', {
    headers: { 'Accept': 'application/vnd.github.v3+json' }
  })
    .then(r => r.json())
    .then(releases => {
      if (Array.isArray(releases) && releases.length > 0) {
        cachedReleases = releases;

        // Find the latest release that contains a valid .apk binary asset
        const releaseWithApk = releases.find(r => r.assets && r.assets.some(a => a.name && a.name.endsWith('.apk'))) || releases[0];
        const latest = releaseWithApk;
        const verTag = latest.tag_name || latest.name || 'v1.2.1';
        const pubDate = latest.published_at
          ? new Date(latest.published_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
          : 'Latest Release';

        // Update Nav & Badges
        document.querySelectorAll('.nav-version-tag').forEach(el => el.textContent = verTag);

        const releaseVer = document.getElementById('releaseVersion');
        if (releaseVer) releaseVer.textContent = `${verTag} Live`;

        const releaseDate = document.getElementById('releaseDate');
        if (releaseDate) releaseDate.textContent = `Released ${pubDate}`;

        // Find APK download asset if present
        const apkAsset = latest.assets ? latest.assets.find(a => a.name && a.name.endsWith('.apk')) : null;
        const apkUrl = apkAsset ? apkAsset.browser_download_url : `https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/releases/download/${verTag}/Pariyojana-${verTag}.apk`;

        const releaseDlBtn = document.getElementById('releaseDownloadBtn');
        if (releaseDlBtn) {
          releaseDlBtn.href = apkUrl;
          if (apkAsset && apkAsset.size) {
            const sizeMb = (apkAsset.size / (1024 * 1024)).toFixed(1);
            const span = releaseDlBtn.querySelector('span');
            if (span) span.textContent = `Direct APK Download (${sizeMb} MB)`;
          }
        }

        const heroPrimaryBtn = document.getElementById('heroPrimaryBtn');
        if (heroPrimaryBtn) heroPrimaryBtn.href = apkUrl;

        const navCta = document.getElementById('navCta');
        if (navCta) navCta.href = apkUrl;

        // Parse and render release summary in the card
        const previewEl = document.getElementById('releaseBodyPreview');
        if (previewEl && latest.body) {
          const cleanBody = latest.body
            .split('\n')
            .filter(l => l.trim().length > 0 && !l.startsWith('#'))
            .slice(0, 3)
            .map(l => `<div class="release-bullet">⚡ ${escapeHtml(l.replace(/^[-*•]\s*/, ''))}</div>`)
            .join('');
          previewEl.innerHTML = cleanBody || '<div class="release-bullet">⚡ Full production release with cryptographic vault & zero-trust offline storage.</div>';
        }
      }
    })
    .catch(err => {
      console.log('GitHub Releases API fallback to v1.2.1:', err);
    });
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function toggleChangelogModal() {
  const modal = document.getElementById('changelogModal');
  if (!modal) return;
  const isOpen = modal.classList.contains('modal--open');
  if (isOpen) {
    modal.classList.remove('modal--open');
    document.body.style.overflow = '';
  } else {
    modal.classList.add('modal--open');
    document.body.style.overflow = 'hidden';
    renderChangelogModal();
  }
}

function renderChangelogModal() {
  const container = document.getElementById('changelogModalContent');
  if (!container) return;

  if (cachedReleases.length === 0) {
    container.innerHTML = `
      <div class="changelog-item cl-item--current">
        <div class="cl-ver-row">
          <div class="cl-title-group">
            <span class="cl-ver-tag">v1.2.1</span>
            <span class="cl-current-pill">🟢 Current Running</span>
          </div>
          <span class="cl-ver-date">Latest Stable</span>
        </div>
        <ul class="cl-notes-list">
          <li>🧭 <strong>Feature Compass Overhaul:</strong> Interactive 1-tap goal recipes, quick filters, and 3-step action cards.</li>
          <li>💻 <strong>Cyber Command Terminal Guard:</strong> Exposed directly outside in Dynamic Island Cockpit with zero UI overflow.</li>
          <li>⚙️ <strong>Settings Stabilization:</strong> Eliminated 2-second layout shift glitch upon screen opening.</li>
          <li>🔒 <strong>Zero-Trust Security:</strong> SQLCipher 256-bit AES encryption & Biometric KeyStore hardware protection.</li>
        </ul>
        <div class="cl-footer-row">
          <a href="https://github.com/Naveen-21-Cyber/Pariyojana-Mobile-App-/releases" target="_blank" rel="noopener noreferrer" class="cl-link">View Repository on GitHub →</a>
        </div>
      </div>
    `;
    return;
  }

  container.innerHTML = cachedReleases.map((rel, idx) => {
    const isCurrent = idx === 0;
    const tag = rel.tag_name || rel.name || `v1.${idx}`;
    const pubDate = new Date(rel.published_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    const formattedNotes = (rel.body || 'Production release improvements and security updates.')
      .split('\n')
      .filter(l => l.trim().length > 0)
      .map(l => `<li>${escapeHtml(l.replace(/^[#*-]+\s*/, ''))}</li>`)
      .join('');

    return `
      <div class="changelog-item ${isCurrent ? 'cl-item--current' : ''}">
        <div class="cl-ver-row">
          <div class="cl-title-group">
            <span class="cl-ver-tag">${escapeHtml(tag)}</span>
            ${isCurrent ? '<span class="cl-current-pill">🟢 Current Running</span>' : ''}
          </div>
          <span class="cl-ver-date">${pubDate}</span>
        </div>
        <ul class="cl-notes-list">
          ${formattedNotes}
        </ul>
        <div class="cl-footer-row">
          <a href="${rel.html_url}" target="_blank" rel="noopener noreferrer" class="cl-link">View Release on GitHub →</a>
        </div>
      </div>
    `;
  }).join('');
}

/* ═══════════════════════════════════════════════════════════════════
   7. SIM TAB SWITCHER
═══════════════════════════════════════════════════════════════════ */
function simTab(id) {
  document.querySelectorAll('.sv').forEach(v => v.classList.remove('sv--on'));
  document.querySelectorAll('.stab').forEach(b => b.classList.remove('stab--on'));
  const view = document.getElementById('v-' + id);
  const btn  = document.getElementById('t-' + id);
  if (view) view.classList.add('sv--on');
  if (btn)  btn.classList.add('stab--on');
}

/* ═══════════════════════════════════════════════════════════════════
   8. FOCUS TIMER DEMO
═══════════════════════════════════════════════════════════════════ */
function initTimerDemo() {
  updateTimerDisplay();
  updateShloka();
}

function setDur(mins) {
  if (timerRunning) return;
  timerTotal = mins * 60;
  timerLeft  = timerTotal;
  document.querySelectorAll('.dur').forEach(b => {
    b.classList.toggle('dur--on', b.textContent.trim() === mins + 'm');
  });
  updateTimerDisplay();
}

function toggleTimer() {
  if (timerRunning) { pauseTimer(); } else { startTimer(); }
}

function startTimer() {
  timerRunning = true;
  document.getElementById('playBtn').textContent = '⏸';
  timerInterval = setInterval(() => {
    if (timerLeft > 0) {
      timerLeft--;
      updateTimerDisplay();
    } else {
      clearInterval(timerInterval);
      timerRunning = false;
      document.getElementById('playBtn').textContent = '▶';
      nextShloka();
    }
  }, 1000);
}

function pauseTimer() {
  clearInterval(timerInterval);
  timerRunning = false;
  document.getElementById('playBtn').textContent = '▶';
}

function resetTimer() {
  clearInterval(timerInterval);
  timerRunning = false;
  timerLeft = timerTotal;
  document.getElementById('playBtn').textContent = '▶';
  updateTimerDisplay();
}

function updateTimerDisplay() {
  const m = String(Math.floor(timerLeft / 60)).padStart(2,'0');
  const s = String(timerLeft % 60).padStart(2,'0');
  const el = document.getElementById('timerTime');
  if (el) el.textContent = `${m}:${s}`;

  // Update SVG ring
  const fill = document.getElementById('trFill');
  if (fill) {
    const pct = timerLeft / timerTotal;
    fill.style.strokeDashoffset = 314.16 * (1 - pct);
  }
}

function nextShloka() {
  shlokaIdx = (shlokaIdx + 1) % SHLOKAS.length;
  updateShloka();
}

function updateShloka() {
  const s = SHLOKAS[shlokaIdx];
  const sEl = document.getElementById('svSanskrit');
  const eEl = document.getElementById('svTrans');
  if (sEl) sEl.textContent = s.s;
  if (eEl) eEl.textContent = s.e;
}

/* ═══════════════════════════════════════════════════════════════════
   9. BYOK TOKEN CALC DEMO
═══════════════════════════════════════════════════════════════════ */
function calcTokens() {
  const text = document.getElementById('byokInput')?.value || '';
  const orig = Math.ceil(text.length / 4); // rough token estimate
  const saved_pct = 0.62;
  const compressed = Math.ceil(orig * (1 - saved_pct));
  const saved = orig - compressed;

  const fmt = n => n.toLocaleString() + ' tokens';
  const origEl = document.getElementById('bOrig');
  const compEl = document.getElementById('bComp');
  const savedEl= document.getElementById('bSaved');

  if (origEl)  origEl.textContent  = fmt(orig);
  if (compEl)  compEl.textContent  = fmt(compressed);
  if (savedEl) savedEl.textContent = fmt(saved) + ` (${Math.round(saved_pct * 100)}% saved)`;
}

/* ═══════════════════════════════════════════════════════════════════
   10. CONTACT FORM CSRF GUARD
═══════════════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
  const tok = document.getElementById('csrfTokenVal');
  if (tok) {
    const arr = new Uint8Array(16);
    crypto.getRandomValues(arr);
    tok.value = Array.from(arr, b => b.toString(16).padStart(2,'0')).join('');
  }

  // Auto-close success message banner
  const params = new URLSearchParams(window.location.search);
  if (params.get('msg') === 'sent') {
    const banner = document.createElement('div');
    banner.style.cssText = `
      position:fixed;bottom:24px;left:50%;transform:translateX(-50%);
      background:#10B981;color:#fff;padding:14px 28px;border-radius:50px;
      font-weight:700;font-size:0.9rem;z-index:9998;
      box-shadow:0 8px 30px rgba(16,185,129,0.5);
    `;
    banner.textContent = '✅ Message sent successfully! Naveen will respond soon.';
    document.body.appendChild(banner);
    setTimeout(() => banner.remove(), 5000);
  }
});

